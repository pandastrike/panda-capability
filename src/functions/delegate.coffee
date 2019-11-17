import {toJSON, isObject, merge, isEmpty, last, keys} from "panda-parchment"
import Method from "panda-generics"
import AJV from "ajv"
import schema from "../schema/delegation"

ajv = new AJV()

Delegate = (library, confidential) ->
  {Delegation, Contract} = library
  {SignatureKeyPair, sign, Message, hash} = confidential

  delegate = Method.create
    name: "delegate"
    description: "Delegates a given Grant to a third party claimant."

  Method.define delegate,
    SignatureKeyPair.isType, Contract.isType, isObject,
    (claimantKeyPair, contract, delegation}) ->

      contract = Contract.create contract

      delegation.integrity = hash Message.from "utf8", toJSON
        grant: contract.grant.to "utf8"
        delegations: (d.to "utf8" for d in contract.delegations)
      .to "base64"

      unless ajv.validate schema, delegation
        console.error toJSON ajv.errors, true
        throw new Error "Delegation description failed validation."

      if delegation.template?
        for d in contract.delegations
          if d.template?
            throw new Error "Cannot rebind grant URL template."

      for method in delegation.methods
        if !isEmpty contract.delegations
          unless method in (last contract.delegations).methods
            throw new Error "Delegatation method is beyond granted scope."
        else
          unless method in contract.grant.methods
            throw new Error "Delegatation method is beyond granted scope."

      # Add a claim to the contract including the claimant's countersignature.
      contract.delegations.push Delegation.create sign claimantKeyPair,
        Message.from "utf8", toJSON claim

      contract

  Method.define delegate,
    SignatureKeyPair.isType,
    SignatureKeyPair.areType,
    Contract.isType,
    isObject,
    (claimantKeyPair, revocationArray, contract, delegation}) ->

      contract = delegate claimantKeyPair, contract, delegation

      unless revocationArray.length == delegation.revocations.length
        throw new Error "mismatch in number of revocation key pairs and authority definitions"

      for keyPair in revocationArray
        sign keyPair, last contract.delegations

      contract

  delegate

export default Delegate
