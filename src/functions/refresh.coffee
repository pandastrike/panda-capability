import {toJSON} from "panda-parchment"
import {Method} from "panda-generics"

Refresh = (library, confidential) ->
  {PublicDirectory, Directory, Grant} = library
  {SignatureKeyPair, sign, Message, PublicKey} = confidential

  refresh = Method.create default: (args...) ->
    throw new Error "panda-capability::refresh no matches on #{toJSON args}"

  Method.define refresh,
    SignatureKeyPair.isType, PublicKey.isType, PublicDirectory.isType,
    (issuerKeyPair, recipient, publicDirectory) ->
      directory = {}

      for template, methods of publicDirectory
        directory[template] = {}
        for method, {grant} of methods
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
