import {toJSON, isArray} from "panda-parchment"
import {Method} from "panda-generics"

Issue = (library, confidential) ->
  {Portfolio, Grant} = library
  {SignatureKeyPair, sign, Message, PublicKey} = confidential

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
          Message.from "utf8", toJSON capability

        grant = Grant.create
          capability: capability
          declaration: declaration
          use: [ privateKey ]

        portfolio[capability.template] = {}

        for method in capability.methods
          portfolio[capability.template][method] = grant

      Portfolio.create portfolio

  issue

export default Issue
