import URLTemplate from "url-template"
import {toJSON} from "panda-parchment"

assert = (predicate, message) ->
  throw new Error "verify failure: #{message}" unless predicate

Verify = (library, confidential) ->

  (request, claim) ->
    # Check claim nonce to mitigate replay attacks
    now = Date.now()
    tolerance = 30000  # tolerance is +/- 30 seconds
    nonce = new Date claim.nonce
    assert (new Date now - tolerance) < nonce < (new Date now + tolerance),
      "Bad nonce.  Current time is #{new Date().toISOString()}"

    # Compare request to claim parameters

    #= URL
    url = URLTemplate
      .parse claim.grant.template
      .expand claim.parameters.url ? {}

    assert request.url == url,
      "url #{request.url} does not match grant"

    #= HTTP Method
    assert request.method in claim.grant.methods,
      "HTTP method #{request.method} does not match grant"

    # Validate the claim's internal consistency via digital signature
    claim.verify()


export default Verify
