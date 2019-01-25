import {isObject, toJSON, empty} from "panda-parchment"
import {Method} from "panda-generics"

Exercise = (library, confidential) ->
  {Grant, Authorization} = library
  {SignatureKeyPair, PublicKey, PrivateKey} = confidential

  exercise = Method.create default: (args...) ->
    throw new Error "panda-capability::exercise no matches on #{toJSON args}"

  # Return an authorization instance to the client.  Multiple signing key
  # permutations are provided as convenience.
  Method.define exercise,
    Grant.isType, PublicKey.isType, PrivateKey.isType, isObject,
    (grant, publicKey, privateKey, parameters) ->

      Authorization.from "object",
        clientKeys:
          publicKey: publicKey
          privateKey: privateKey
        capabilityKeys:
          publicKey: PublicKey.from "base64", grant.capability.use[0]
          privateKey: PrivateKey.from "base64", grant.use[0]
        issuerDeclaration: grant.declaration
        parameters: parameters

  Method.define exercise,
    Grant.isType, PublicKey.isType, PrivateKey.isType,
    (grant, publicKey, privateKey) ->
      exercise grant, publicKey, privateKey, {}

  Method.define exercise,
    Grant.isType, PrivateKey.isType, PublicKey.isType, isObject,
    (grant, privateKey, publicKey, parameters) ->
      exercise grant, publicKey, privateKey, parameters

  Method.define exercise,
    Grant.isType, PrivateKey.isType, PublicKey.isType,
    (grant, privateKey, publicKey) ->
      exercise grant, publicKey, privateKey, {}

  Method.define exercise, Grant.isType, SignatureKeyPair.isType, isObject,
    (grant, {publicKey, privateKey}, parameters) ->
      exercise grant, publicKey, privateKey, parameters

  Method.define exercise, Grant.isType, SignatureKeyPair.isType,
    (grant, {publicKey, privateKey}) ->
      exercise grant, publicKey, privateKey, {}

export default Excercise
