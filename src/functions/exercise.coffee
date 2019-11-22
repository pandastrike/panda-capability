import {toJSON, isObject, merge} from "panda-parchment"
import Method from "panda-generics"

Exercise = (library, confidential) ->
  {Claim, Contract, Memo} = library
  {SignatureKeyPair, sign, Message} = confidential

  exercise = Method.create
    name: "exercise"
    description: "Excercises a given Grant to add a Claim to the Contract"

  Method.define exercise,
    SignatureKeyPair.isType, Contract.isType, isObject,
    (claimantKeyPair, contract, parameters) ->

      claim = merge parameters, timestamp: new Date().toISOString()

      # Add a claim to the contract including the claimant's countersignature.
      Contract.create merge contract,
        claim: Claim.create sign claimantKeyPair,
          Message.from "utf8", toJSON claim

  Method.define exercise,
    Memo.isType, isObject,
    (memo, claim) ->

      # Add a claim stanze to the memo. Is not true claim with countersignature
      Memo.create merge memo, {claim}

  exercise

export default Exercise
