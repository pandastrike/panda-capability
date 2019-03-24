import {toJSON, isArray} from "panda-parchment"
import {Method} from "panda-generics"

Issue = (library, confidential) ->
  {Directory, Grant} = library
  {SignatureKeyPair, sign, Message, PublicKey} = confidential

  issue = Method.create default: (args...) ->
    throw new Error "panda-capability::issue no matches on #{toJSON args}"

  Method.define issue, SignatureKeyPair.isType, PublicKey.isType, isArray,
    (issuerKeyPair, recipient, capabilities) ->
      directory = {}
      for capability in capabilities
        # Create the use key pair for this grant.
        useKeyPair = await SignatureKeyPair.create()

        capability.recipient = recipient.to "base64"
        capability.publicUseKeys = [ useKeyPair.publicKey.to "base64" ]

        # Sign the populated capability to issue a grant.
        declaration = sign issuerKeyPair,
          Message.from "utf8", toJSON capability

        # Assign a seal, with a copy of this grant, for every method.
        {template, methods} = capability
        directory[template] = {}
        for method in methods
          directory[template][method] =
            grant: Grant.create declaration
            useKeyPairs: [ useKeyPair ]

      Directory.create directory

  issue

export default Issue
