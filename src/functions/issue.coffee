import {toJSON, isObject, isArray, merge} from "panda-parchment"
import Method from "panda-generics"
import AJV from "ajv"
import schema from "../schema/capability"

ajv = new AJV()

Issue = (library, confidential) ->
  {Directory, Contract, Grant} = library
  {SignatureKeyPair, sign, Message, PublicKey} = confidential

  issue = Method.create
    name: "issue"
    description: "Issues a Directory of Contracts to a claimant PublicKey."

  Method.define issue,
    SignatureKeyPair.isType, isObject, isArray,
    (issuerKeyPair, authorities, stubs) ->
      directory = {}

      for stub in stubs
        capability = merge stub, authorities

        unless ajv.validate schema, capability
          console.error toJSON ajv.errors, true
          throw new Error "Unable to issue directory. Capability failed validation."

        # Sign the populated capability to issue a grant.
        declaration = sign issuerKeyPair,
          Message.from "utf8", toJSON capability

        # Place grant into directory of contracts.
        {template, methods} = capability

        directory[template] = {}
        for method in methods
          directory[template][method] =
            Contract.create grant: Grant.create declaration

      Directory.create directory

  issue

export default Issue
