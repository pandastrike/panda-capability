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
        capability.recipient = recipient.to "base64"
        {publicKey, privateKey} = await SignatureKeyPair.create()
        capability.publicUse = [ publicKey.to "base64" ]

        declaration = sign issuerKeyPair,
          Message.from "utf8", toJSON capability

        directory[capability.template] = {}
        for method in capability.methods
          directory[capability.template][method] =
            grant: Grant.create declaration
            privateUse: [ privateKey ]

      Directory.create directory

  issue

export default Issue
