import {isString, toJSON} from "panda-parchment"
import {Method} from "panda-generics"
import T from "url-template"

assert = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate

parse = (string) ->
  assert (isString string), "header value must be a string"
  start = string.indexOf " "
  scheme = string[0...start]
  assert scheme == "X-Capability", "invalid scheme #{scheme}"
  string[start...].trim()

Challenge = (library, confidential) ->
  {Assertion} = library

  (request) ->
    results = Assertion.from "base64", parse request?.headers?.authorization
    .verify()

    {parameters, capability:{template, methods}} = results
    {url, method} = request

    claimedURL = T.parse(template).expand parameters.url ? {}

    assert url == claimedURL, "url does not match capability"
    assert method in methods, "HTTP method does not match capability"

    results

export default Challenge
