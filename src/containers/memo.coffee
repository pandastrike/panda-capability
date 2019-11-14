import {isType, isObject, fromJSON, toJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Declaration, verify} = confidential

  class Memo
    constructor: (@declaration) ->
      {@message, @signatories, @signatures} = @declaration
      {@template, @methods, @issuer, @claimant} = @message.json()

    to: (hint) -> @declaration.to hint

    verify: -> verify @declaration

    @create: (value) -> new Memo value

    @from: (hint, value) -> new Memo Declaration.from hint, value

    @isType: isType @

export default Container
