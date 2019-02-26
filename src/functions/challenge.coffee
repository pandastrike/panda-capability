import URLTemplate from "url-template"
import {toJSON} from "panda-parchment"

assert = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate

Challenge = (library, confidential) ->

  (request, assertion) ->
    # Check assertion nonce to mitigate replay attacks
    now = Date.now()
    tolerance = 30000  # tolerance is +/- 30 seconds
    claim = new Date assertion.nonce
    assert (new Date now - tolerance) < claim &&
      claim < (new Date now + tolerance),
      "Bad nonce.  Current time is #{new Date().toISOString()}"

    # Compare request to assertion parameters
    #= URL
    claim = URLTemplate
      .parse assertion.capability.template
      .expand assertion.parameters.url ? {}

    assert request.url == claim,
      "url \"#{toJSON request.url}\" does not match capability"

    #= HTTP Method
    {methods} = assertion.capability

    assert request.method in methods,
      "HTTP method \"#{toJSON request.method}\" does not match capability"

    # Validate the assertion's internal consistency via digital signature
    assertion.verify()


export default Challenge
