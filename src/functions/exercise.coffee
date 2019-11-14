import {toJSON, isObject, merge} from "panda-parchment"
import Method from "panda-generics"
import AJV from "ajv"
import schema from "../schema/claim"

ajv = new AJV()

Exercise = (library, confidential) ->
  {Claim, Contract} = library
  {SignatureKeyPair, sign, Message} = confidential

  exercise = Method.create
    name: "exercise"
    description: "Excercises a given Grant to add a Claim to the Contract"

  Method.define exercise,
    SignatureKeyPair.isType, Contract.isType, isObject,
    (claimantKeyPair, contract, parameters}) ->

      claim = merge parameters, timestamp: new Date().toISOString()

      unless ajv.validate schema, claim
        console.error toJSON ajv.errors, true
        throw new Error "Unable to exercise grant. Claim failed validation."

      # Add a claim to the contract including the claimant's countersignature.
      contract.claim = Claim.create sign claimantKeyPair,
        Message.from "utf8", toJSON claim

      contract


  exercise

export default Exercise
