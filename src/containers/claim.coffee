import {first, isString, isDefined, isType, toJSON, fromJSON, include} from "panda-parchment"

assert = (predicate, message) ->
  throw new Error "verify failure: #{message}" unless predicate

Container = (library, confidential) ->
  {Grant} = library
  {verify, Declaration} = confidential

  class Claim
    constructor: (@declaration) ->
      @signatories = @declaration.signatories.list "base64"

      {@parameters, grant, @nonce} = @declaration.message.json()
      @grant = Grant.from "base64", grant

    to: (hint) -> @declaration.to hint

    # Validates internal consistency of claim.
    verify: ->
      assert (verify @declaration), "invalid claim signature"
      assert @grant.verify(), "invalid grant signature"

    @create: (value) -> new Claim value

    @from: (hint, value) -> new Claim Declaration.from hint, value

    @isType: isType @

export default Container
