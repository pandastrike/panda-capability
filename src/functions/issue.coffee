import {toJSON, isArray} from "panda-parchment"
import {Method} from "panda-generics"

Issue = (library, confidential) ->
  {Capchain} = library
  {SignatureKeyPair, sign, Plaintext, PublicKey} = confidential

  issue = Method.create default: (args...) ->
    throw new Error "panda-capability::issue no matches on #{toJSON args}"

  Method.define issue, SignatureKeyPair.isType, PublicKey.isType, isArray,
    (issuerKeyPair, recipient, capabilities) ->
      capchain = {}
      for capability in capabilities
        capchain[capability.template] = {}

        capability.recipient = recipient
        {publicKey, privateKey} = await SignatureKeyPair.create()
        capability.use = [ publicKey.to "base64" ]

        declaration = sign issuerKeyPair,
          Plaintext.from "utf8", toJSON capability

        grant =
          capability: capability
          declaration: declaration.to "base64"
          use: [ privateKey.to "base64" ]

        for method in capability.methods
          capchain[capability.template][method] = grant

      Capchain.from "object", capchain
