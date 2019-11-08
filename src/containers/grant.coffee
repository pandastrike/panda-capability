import {isType, isObject, fromJSON, toJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Declaration, verify} = confidential

  class Grant
    constructor: (@declaration) ->
      {@message, @signatories, @signatures} = @declaration
      {@template, @methods, @constraints} = @message.json()

    to: (hint) -> @declaration.to hint

    verify: -> verify @declaration

    @create: (value) -> new Grant value

    @from: (hint, value) -> new Grant Declaration.from hint, value

    @isType: isType @

export default Container
