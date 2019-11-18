import {isType} from "panda-parchment"

Container = (library, confidential) ->
  {Declaration, verify} = confidential

  class Grant
    constructor: (@declaration) ->
      @signatories = @declaration.signatories.list "base64"

      {@message} = @declaration
      {@template, @methods,
        @expires, @tolerance,
        @issuer, @revocations=[], @claimant} = @message.json()

    to: (hint) -> @declaration.to hint

    verify: -> verify @declaration

    @create: (value) -> new Grant value

    @from: (hint, value) -> new Grant Declaration.from hint, value

    @isType: isType @

export default Container
