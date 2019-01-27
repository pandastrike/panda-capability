import URLTemplate from "url-template"
import {isType, isString, isArray, empty, isObject,
  fromJSON, toJSON} from "panda-parchment"
import {isUse} from "../utils"

# Sanity check on a grant object's structure.
ifValid = (grant) ->
  {declaration, use} = grant
  unless isString declaration
    throw new Error "Invalid grant: declaration = #{toJSON declaration}"
  unless isUse use
    throw new Error "Invalid grant: use = #{toJSON use}"
  grant

Container = (library, confidential) ->
  {Capability} = library
  {convert, PublicKey, PrivateKey, Plaintext, sign} = confidential

  class Grant
    constructor: ({@capability, @declaration, @use}) ->

    to: (hint) ->
      value = toJSON {@capability, @declaration, @use}
      if hint == "utf8"
        value
      else
        convert from: "utf8", to: hint, value

    # Package request parameters and grant declaration into an authority.
    exercise: (parameters) ->
      publicKey = PublicKey.from "base64", @capability.use[0]
      privateKey = PrivateKey.from "base64", @use[0]

      sign publicKey, privateKey,
        Plaintext.from "utf8",
          toJSON {parameters, issuerDeclaration:@declaration}

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
