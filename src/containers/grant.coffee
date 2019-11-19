import {isType, areType} from "panda-parchment"
import AJV from "ajv"
import schema from "../schema/grant"

ajv = new AJV()

Container = (library, confidential) ->
  {Declaration, verify} = confidential

  class Grant
    constructor: (@declaration) ->
      @validate()
      @signatories = @declaration.signatories.list "base64"

      {@template, @methods,
        @expires, @tolerance,
        @issuer, @revocations=[], @claimant} = @declaration.message.json()

    to: (hint) -> @declaration.to hint

    verify: -> verify @declaration

    # Compares the contents to a schema.
    validate: ->
      unless Declaration.isType @declaration
        throw new Error "Grant must be a signature declaration"

      unless ajv.validate schema, @declaration.message.json()
        console.error toJSON ajv.errors, true
        throw new Error "Unable to create grant: failed validation."

    @create: (value) -> new Grant value

    @from: (hint, value) -> new Grant Declaration.from hint, value

    @isType: isType @
    @areType: areType @

export default Container
