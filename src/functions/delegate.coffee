import {toJSON, isObject, merge} from "panda-parchment"
import Method from "panda-generics"
import AJV from "ajv"
import schema from "../schema/delegation"

ajv = new AJV()

Delegate = (library, confidential) ->
  {Delegation, Contract} = library
  {SignatureKeyPair, sign, Message} = confidential

  delegate = Method.create
    name: "delegate"
    description: "Delegates a given Grant to a third party claimant."

  Method.define delegate,
    SignatureKeyPair.isType, Contract.isType, isObject,
    (claimantKeyPair, contract, delegation}) ->

      contract = Contract.create contract

      unless ajv.validate schema, delegation
        console.error toJSON ajv.errors, true
        throw new Error "Unable to delegate grant. Claim failed validation."

      # Add a claim to the contract including the claimant's countersignature.
      contract.delegations.push Delegation.create sign claimantKeyPair,
        Message.from "utf8", toJSON claim

      contract


  delegate

export default Delegate
