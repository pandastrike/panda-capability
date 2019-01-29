import {first, isString, isDefined, isType, toJSON, fromJSON, include} from "panda-parchment"
import {Method} from "panda-generics"

assert = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate

Container = (library, confidential) ->
  {verify, Declaration} = confidential

  class Assertion
    constructor: (@declaration) ->
      # Unpack client assertion
      [use, client] = @declaration.signatories.list "base64"
      @publicKeys = {use, client}

      {@parameters, grant} = @declaration.message.json()
      grant = Declaration.from "base64", grant

      # Unpack grant
      @publicKeys.issuer = first grant.signatories.list "base64"
      @capability = grant.message.json()

    to: (hint) -> @declaration.to hint

    # Validates internal consistency of assertion; adds unpacked properties
    verify: ->
      assert (verify @declaration),
        "client signature is invalid"
      assert (verify grant),
        "issuer signature is invalid"
      assert @publicKeys.use? && @publicKeys.client?,
        "client or use public key is not present"
      assert @capability.publicUse[0] == @publicKeys.use,
        "public use key is invalid"
      assert @capability.recipient == @publicKeys.client,
        "client key is invalid"

    @create: (value) -> new Assertion value

    @from: (hint, value) -> new Assertion Declaration.from hint, value

    @isType: isType @

export default Container
