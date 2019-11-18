import {isType} from "panda-parchment"

assert = (predicate, message) ->
  throw new Error "verify failure: #{message}" unless predicate

Container = (library, confidential) ->
  {verify, Declaration} = confidential

  class Claim
    constructor: (@declaration) ->
      @signatories = @declaration.signatories.list "base64"

      {@template={}, @method,
        @timestamp,
        @claimant} = @declaration.message.json()

    to: (hint) -> @declaration.to hint

    verify: -> verify @declaration

    @create: (value) -> new Claim value

    @from: (hint, value) -> new Claim Declaration.from hint, value

    @isType: isType @

export default Container
