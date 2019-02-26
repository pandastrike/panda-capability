import {first, isString, isDefined, isType, toJSON, fromJSON, include} from "panda-parchment"
import {Method} from "panda-generics"

assert = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate

Container = (library, confidential) ->
  {verify, Declaration} = confidential

  class Assertion
    constructor: (@declaration) ->
      # Unpack recipient assertion
      [use, recipient] = @declaration.signatories.list "base64"
      @publicKeys = {use, recipient}

      {@parameters, grant, @nonce} = @declaration.message.json()
      @grant = Declaration.from "base64", grant

      # Unpack grant
      @publicKeys.issuer = first @grant.signatories.list "base64"
      @capability = @grant.message.json()

    to: (hint) -> @declaration.to hint

    # Validates internal consistency of assertion.
    verify: ->
      assert (verify @declaration), "invalid recipient signature"
      assert (verify @grant), "invalid issuer signature"

      assert @publicKeys.use? && @publicKeys.recipient?,
        "recipient or use public key is not present"
      assert @capability.publicUseKeys[0] == @publicKeys.use,
        "public use key is invalid"
      assert @capability.recipient == @publicKeys.recipient,
        "recipient key is invalid"

    @create: (value) -> new Assertion value

    @from: (hint, value) -> new Assertion Declaration.from hint, value

    @isType: isType @

export default Container
