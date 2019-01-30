import {toJSON, isObject, isArray} from "panda-parchment"
import {Method} from "panda-generics"

Exercise = (library, confidential) ->
  {Assertion, Grant} = library
  {SignatureKeyPair, sign, Message} = confidential

  # Multiple signing key permutations are provided as convenience.
  exercise = Method.create default: (args...) ->
    throw new Error "panda-capability::exercise -
      no matches on #{toJSON args}"

  Method.define exercise,
    SignatureKeyPair.isType, isArray, Grant.isType, isObject,
    (clientKeyPair, useKeyPairs, grant, parameters) ->

      # Sign first with use key pair
      declaration = sign useKeyPairs[0],
        Message.from "utf8", toJSON
          grant: grant.to "base64"
          parameters: parameters

      # Then sign with the client key pair
      declaration = sign clientKeyPair, declaration

      # Output an assertion instance of this grant exercise
      Assertion.create declaration


  exercise

export default Exercise
