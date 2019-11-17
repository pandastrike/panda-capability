import {toJSON, isObject, isArray, merge} from "panda-parchment"
import Method from "panda-generics"
import AJV from "ajv"
import schema from "../schema/capability"

ajv = new AJV()

Issue = (library, confidential) ->
  {Directory, Contract, Grant} = library
  {SignatureKeyPair, sign, Message} = confidential

  issue = Method.create
    name: "issue"
    description: "Issues a Contract to a claimant."

  Method.define issue,
    SignatureKeyPair.isType, isObject,
    (issuerKeyPair, capability) ->

      unless ajv.validate schema, capability
        console.error toJSON ajv.errors, true
        throw new Error "Capability failed validation."

      # Sign the populated capability to issue a grant.
      Contract.create
        grant: Grant.create sign issuerKeyPair,
          Message.from "utf8", toJSON capability


  Method.define issue,
    SignatureKeyPair.isType, SignatureKeyPair.areType, isObject, isArray,
    (issuerKeyPair, revocationArray, capability) ->

      contract = issue issuerKeyPair, capability

      unless revocationArray.length == contract.grant.revocations.length
        throw new Error "mismatch in number of revocation key pairs and authority definitions"

      for keyPair in revocationArray
        sign keyPair, contract.grant.declaration

      contract


  issue

export default Issue


#   # Place grant into directory of contracts.
#   {template, methods} = capability
#
#   directory[template] = {}
#   for method in methods
#     directory[template][method] =
#       Contract.create grant:
#
# Directory.create directory
