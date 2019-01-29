import {isType, isObject, fromJSON, toJSON} from "panda-parchment"
import {Method} from "panda-generics"

Container = (library, confidential) ->
  {Assertion} = library
  {PublicKey, PrivateKey, Message, sign, Declaration, verify,
    SignatureKeyPair} = confidential

  # Exercise a grant by packaging it and its parameters into an assertion.
  # Signing key permutations are provided as convenience.
  exercise = Method.create default: (args...) =>
    throw new Error "panda-capability::grant::exercise -
      no matches on #{toJSON args}"

  Method.define exercise,
    PrivateKey.isType, PublicKey.isType, PrivateKey.isType, isObject,
    (privateKey, publicKey, privateUse, parameters) =>
      console.log "exercise", {data:@}
      message = Message.from "utf8", toJSON
        parameters: parameters
        grant: @declaration.to "base64"

      declaration = sign privateUse, @publicUse, message
      declaration = sign privateKey, publicKey, declaration
      Assertion.create declaration


  Method.define exercise,
    PublicKey.isType, PrivateKey.isType, PrivateKey.isType, isObject,
    (publicKey, privateKey, privateUse, parameters) =>
      exercise privateKey, publicKey, privateUse, parameters

  Method.define exercise,
    SignatureKeyPair.isType, PrivateKey.isType, isObject,
    ({publicKey, privateKey}, privateUse, parameters) =>
      exercise privateKey, publicKey, privateUse, parameters


  class Grant
    constructor: (@declaration) ->
      {@template, @methods, @recipient, @publicUse} =
        @declaration.message.json()

    to: (hint) -> @declaration.to hint

    verify: -> verify @declaration

    @create: (value) -> new Grant value

    @from: (hint, value) -> new Grant Declaration.from hint, value

    @isType: isType @

export default Container
