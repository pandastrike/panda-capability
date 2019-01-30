import {toJSON, isObject, isArray} from "panda-parchment"
import {Method} from "panda-generics"

Exercise = (library, confidential) ->
  {Assertion, Grant} = library
  {SignatureKeyPair, sign, Message} = confidential

  exercise = Method.create default: (args...) ->
    throw new Error "panda-capability::exercise -
      no matches on #{toJSON args}"

  Method.define exercise,
    SignatureKeyPair.isType, isArray, Grant.isType, isObject,
    (clientKeyPair, useKeyPairs, grant, parameters) ->

      # Sign first with use key pair, then the client key pair.
      Assertion.create sign [useKeyPairs[0], clientKeyPair],
        Message.from "utf8", toJSON
          grant: grant.to "base64"
          parameters: parameters

  exercise

export default Exercise
