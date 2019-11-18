import {isType} from "panda-parchment"

Container = (library, confidential) ->
  {Declaration, verify} = confidential

  class Delegation
    constructor: (@declaration) ->
      @signatories = @declaration.signatories.list "base64"

      {@message} = @declaration
      {@template, @methods,
        @integrity, @expires,
        @claimant, @revocations=[], @delegate} = @message.json()

    to: (hint) -> @declaration.to hint

    verify: -> verify @declaration

    @create: (value) -> new Delegation value

    @from: (hint, value) -> new Delegation Declaration.from hint, value

    @isType: isType @

export default Container
