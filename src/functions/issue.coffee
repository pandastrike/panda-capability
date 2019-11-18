import {toJSON, isObject} from "panda-parchment"
import Method from "panda-generics"

Issue = (library, confidential) ->
  {Contract, Grant} = library
  {SignatureKeyPair, sign, Message} = confidential

  issue = Method.create
    name: "issue"
    description: "Issues a Contract to a claimant."

  Method.define issue,
    SignatureKeyPair.isType, isObject,
    (issuerKeyPair, capability) ->

      # Sign the populated capability to issue a grant.
      Contract.create
        grant: Grant.create sign issuerKeyPair,
          Message.from "utf8", toJSON capability


  Method.define issue,
    SignatureKeyPair.isType, SignatureKeyPair.areType, isObject,
    (issuerKeyPair, revocationArray, capability) ->

      contract = issue issuerKeyPair, capability

      unless revocationArray.length == contract.grant.revocations.length
        throw new Error "mismatch in number of revocation key pairs and authority definitions"

      for keyPair in revocationArray
        sign keyPair, contract.grant.declaration

      contract


  issue

export default Issue
