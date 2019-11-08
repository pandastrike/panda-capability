import {toJSON, isString, isArray} from "panda-parchment"
import Method from "panda-generics"
import AJV from "ajv"
import schema from "../schema/capability"

ajv = new AJV()

Issue = (library, confidential) ->
  {Directory, Grant} = library
  {SignatureKeyPair, sign, Message, PublicKey} = confidential

  issue = Method.create
    name: "issue"
    description: "Issues a Directory of Grants to a recipient PublicKey."

  Method.define issue, SignatureKeyPair.isType, isString, isString, isArray,
    (issuerKeyPair, issuer, recipient, capabilities) ->
      directory = {}

      unless ajv.validate schema, capabilities
        console.error toJSON ajv.errors, true
        throw new Error "Unable to issue directory. Capability failed validation."

      for capability in capabilities
        # Add in key registry URLs where one may confirm key validity.
        capability.constraints ?= []

        capability.constraints.push
          type: "web signature"
          name: "issuer"
          url: issuer

        capability.constraints.push
          type: "web signature"
          name: "recipient"
          url: recipient

        # Sign the populated capability to issue a grant.
        declaration = sign issuerKeyPair,
          Message.from "utf8", toJSON capability

        # Place grant into directory.
        {template, methods} = capability

        directory[template] = {}
        for method in methods
          directory[template][method] = Grant.create declaration

      Directory.create directory

  issue

export default Issue
