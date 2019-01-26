import {isString} from "panda-parchment"
import {Method} from "panda-generics"
import T from "url-template"

check = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate

parse = (string) ->
  check (isString string), "header value must be a string"
  start = string.indexOf " "
  scheme = string[0...start]
  check scheme == "X-Capability", "invalid scheme #{scheme}"
  string[start...].trim()


Challenge = (library, confidential) ->
  {Assertion} = library
  {verify, Declaration, PublicKey} = confidential

  (request) ->
    check request?.headers?.authorization?, "authorization header not set"

    assertion = Assertion.from "base64", parse headers.authorization
    check assertion.verify(), "invalid grant assertion"

    {parameters, capability:{template, method}} = assertion
    {template, methods} = capability
    {url, method, headers} = request

    claimedURL = T.parse(template).expand parameters.url ? {}

    check url == claimedURL, "url does not match capability"
    check method in methods, "HTTP method does not match capability"

    assertion

export default Challenge
