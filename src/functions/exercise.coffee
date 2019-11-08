import {toJSON, isObject, isArray} from "panda-parchment"
import Method from "panda-generics"

Exercise = (library, confidential) ->
  {Claim, Grant} = library
  {SignatureKeyPair, sign, Message} = confidential

  exercise = Method.create
    name: "exercise"
    description: "Excercises a given Grant to return an Claim"

  Method.define exercise,
    SignatureKeyPair.isType, Grant.isType, isObject,
    (recipientKeyPair, grant, parameters) ->

      # Sign the grant with the recipient key pair.
      Claim.create sign recipientKeyPair,
        Message.from "utf8", toJSON
          grant: grant.to "base64"
          parameters: parameters
          nonce: new Date().toISOString()

  exercise

export default Exercise
