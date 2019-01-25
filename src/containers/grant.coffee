import URLTemplate from "url-template"
import {isType, isString, isArray, empty,
  fromJSON, toJSON} from "panda-parchment"
import {isUse} from "../utils"

# Sanity check on a grant object's structure.
ifValid = (grant) ->
  {capability, declaration, use} = grant
  unless isObject capability
    throw new Error "Invalid grant: capability = #{capability}"
  unless isString declaration
    throw new Error "Invalid grant: declaration = #{declaration}"
  unless isUse use
    throw new Error "Invalid grant: use = #{use}"
  grant

Container = (library, confidential) ->
  {Capability} = library
  {convert} = confidential

  class Grant
    constructor: ({@capability, @declaration, @use}) ->

    to: (hint) ->
      value = toJSON {@capability, @declaration, @use}
      if hint == "utf8"
        value
      else
        convert from: "utf8", to: hint, value

    checkKeys = (issuerKey, grant, claim) ->
      # Confirm the issuer issued the claimed capability
      if claim.issuerKey != issuerKey.to "base64"
        throw new Error "verification failure: issuer key does not match"

      # Confirm the client and use keys are correct.
      if grant.use[0] != claim.useKey
        throw new Error "verification failure: use key does not match"

      if grant.capability.use[0] != claim.clientKey
        throw new Error "verification failure: client key does not match"

    matchCapability = (capchain, {template}, method) ->
      # Confirm the claimed capability belongs to the client.
      if grant = capchain[template][method]
        grant
      else
        throw new Error "verification failure: client does not have a
          capability on #{template} #{method}"

    checkRequest = (claim, grant, request) ->
      {parameters} = claim
      {template, methods} = grant.capability
      {url, method} = request

      # Confirm the url template parameters match the acutal URL
      urlTemplate = URLTemplate.parse template

      if (urlTemplate.expand parameters.template ? {}) != url
        throw new Error "verification failure: url parameters do not match"

      if method not in methods
        throw new Error "verification failure: HTTP method does not match"

    # Confirms this request matches the specifications of the authorization.
    verifyRequest: ->
      {parameters} = @claim
      {template, methods} = grant.capability
      {url, method} = request

      # Confirm the url template parameters match the acutal URL
      urlTemplate = URLTemplate.parse template

      if (urlTemplate.expand parameters.template ? {}) != url
        throw new Error "verification failure: url parameters do not match"

      if method not in methods
        throw new Error "verification failure: HTTP method does not match"

    @from: (hint, value) ->
      grant = ifValid do ->
        switch hint
          when "object" then value
          when "utf8" then fromJSON value
          else fromJSON convert from: hint, to: "utf8", value

      grant.capability = Capability.from "object", value.capability
      new Grant value

    @isType: isType @

export default Container
