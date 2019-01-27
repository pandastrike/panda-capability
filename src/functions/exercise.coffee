import {isObject, toJSON, empty} from "panda-parchment"
import {Method} from "panda-generics"

Exercise = (library, confidential) ->
  {Grant, Assertion} = library
  {SignatureKeyPair, PublicKey, PrivateKey, sign} = confidential

  # Multiple signing key permutations are provided as convenience.
  exercise = Method.create default: (args...) ->
    throw new Error "panda-capability::exercise no matches on #{toJSON args}"

  Method.define exercise,
    Grant.isType, PublicKey.isType, PrivateKey.isType, isObject,
    (grant, publicKey, privateKey, parameters) ->
      Assertion.from sign publicKey, privateKey, grant.exercise parameters

  Method.define exercise,
    Grant.isType, PrivateKey.isType, PublicKey.isType, isObject,
    (grant, privateKey, publicKey, parameters) ->
      exercise grant, publicKey, privateKey, parameters

  Method.define exercise,
    Grant.isType, SignatureKeyPair.isType, isObject,
    (grant, {publicKey, privateKey}, parameters) ->
      exercise grant, publicKey, privateKey, parameters

  exercise

export default Exercise
