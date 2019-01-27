import {toJSON, isArray} from "panda-parchment"
import {Method} from "panda-generics"

Issue = (library, confidential) ->
  {Portfolio} = library
  {SignatureKeyPair, sign, Plaintext, PublicKey} = confidential

  issue = Method.create default: (args...) ->
    throw new Error "panda-capability::issue no matches on #{toJSON args}"

  Method.define issue, SignatureKeyPair.isType, PublicKey.isType, isArray,
    (issuerKeyPair, recipient, capabilities) ->
      portfolio = {}
      for capability in capabilities
        capability.recipient = recipient.to "base64"
        {publicKey, privateKey} = await SignatureKeyPair.create()
        capability.use = [ publicKey.to "base64" ]

        declaration = sign issuerKeyPair,
          Plaintext.from "utf8", toJSON capability

        grant =
          capability: capability
          declaration: declaration.to "base64"
          use: [ privateKey.to "base64" ]

        portfolio[capability.template] = {}

        for method in capability.methods
          portfolio[capability.template][method] = grant

      Portfolio.from "object", portfolio

  issue

export default Issue
