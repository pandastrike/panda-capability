import {isString, isDefined, isType, toJSON, fromJSON, include} from "panda-parchment"
import {Method} from "panda-generics"

assert = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate

Container = (library, confidential) ->
  {convert, verify, Declaration} = confidential

  class Assertion
    constructor: (@declaration) ->

    to: (hint) -> @declaration.to hint

    read: ->
      # Parse client declaration
      {message, signatories} = @declaration
      {parameters={}, issuerDeclaration} = fromJSON message.to "utf8"
      [useKey, clientKey] = signatories.list "base64"

      # Parse issuer declaration
      issuerDeclaration = Declaration.from "base64", issuerDeclaration
      {message, signatories} = issuerDeclaration
      capability = fromJSON message.to "utf8"
      [issuerKey] = signatories.list "base64"

      {parameters, issuerDeclaration, capability, useKey, clientKey, issuerKey}

    # Validates internal consistency of assertion; adds unpacked properties
    verify: ->
      data = @read()
      {issuerDeclaration, capability, useKey, clientKey} = data

      assert (verify @declaration), "client signature is invalid"
      assert (verify issuerDeclaration), "issuer signature is invalid"
      assert useKey? && clientKey?, "client or use key is not present"
      assert capability.use[0] == useKey, "use key is invalid"
      assert capability.recipient == clientKey, "client key is invalid"
      data

    @create: (value) -> new Assertion value

    @from: (hint, value) -> new Assertion Declaration.from hint, value

    @isType: isType @

export default Container
