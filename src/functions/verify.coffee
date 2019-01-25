import {isBoolean, toJSON, isObject, fromJSON} from "panda-parchment"
import {Method} from "panda-generics"

Verify = (library, confidential) ->
  {Capchain, Request} = library
  {verfiy: _verify, Declaration, PublicKey} = confidential

  verify = Method.create default: (args...) ->
    throw new Error "panda-capability::verify no matches on #{toJSON args}"

  Method.define verify,
    PubicKey.isType, Capchain.isType, Request.isType, isBoolean,
    (issuerKey, capchain, request, debugFlag) ->
      try
        claim = request.extractClaim()
        grant = capchain.match claim, request.method
        grant.verifyRequest request
        grant.verifyIdentities claim, issuerKey
        true
      catch e
        console.error e if debugFlag
        false

  Method.define verify, PubicKey.isType, Capchain.isType, Request.isType,
    (issuerKey, capchain, request) ->
      verify issuerKey, capchain, request, false

export default Verify
