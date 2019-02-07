import URLTemplate from "url-template"
import {toJSON} from "panda-parchment"

assert = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate

Challenge = (library, confidential) ->

  (request, assertion) ->
    # Validate the assertion's internal consistency
    assertion.verify()

    # Compare the request to the assertion parameters

    ## URL
    claimedURL = URLTemplate
      .parse assertion.capability.template
      .expand assertion.parameters.url ? {}

    assert request.url == claimedURL,
      "url \"#{toJSON request.url}\" does not match capability"

    ## HTTP Method
    {methods} = assertion.capability

    assert request.method in methods,
      "HTTP method \"#{toJSON request.method}\" does not match capability"

export default Challenge
