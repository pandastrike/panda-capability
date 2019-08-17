import {toJSON} from "panda-parchment"
import Method from "panda-generics"

Refresh = (library, confidential) ->
  {PublicDirectory, Directory, Grant} = library
  {SignatureKeyPair, sign, Message, PublicKey, verify} = confidential

  refresh = Method.create
    name: "refresh"
    description: "Accepts a PublicDirectory, verifies the issuer issued each
      original grant, and then re-issues a Directory with new use key pairs."

  Method.define refresh,
    SignatureKeyPair.isType, PublicKey.isType, PublicDirectory.isType,
    (issuerKeyPair, recipient, publicDirectory) ->
      directory = {}
      issuer = issuerKeyPair.publicKey.to "base64"

      for template, methods of publicDirectory
        directory[template] = {}
        for method, {grant} of methods
          # Validate grant and confirm the issuer key pair was used before.
          unless grant.verify()
            throw new Error "invalid grant found at #{template} #{method}"
          unless issuer in (grant.signatories.list "base64")
            throw new Error "grant at #{template} #{method} not issued by
              #{issuer}"

          # Pull out the capability from this grant and refresh
          capability = grant.message.json()
          capability.recipient = recipient.to "base64"
          useKeyPair = await SignatureKeyPair.create()
          capability.publicUseKeys = [ useKeyPair.publicKey.to "base64" ]

          # Sign the refreshed capability
          declaration = sign issuerKeyPair,
            Message.from "utf8", toJSON capability

          # Place the finalized grant and use key pair into the directory
          directory[template][method] =
            grant: Grant.create declaration
            useKeyPairs: [ useKeyPair ]

      Directory.create directory

  refresh

export default Refresh
