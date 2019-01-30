import {isString} from "panda-parchment"

assert = (predicate, message) ->
  throw new Error "authorization parse failure: #{message}" unless predicate

Parse = (library, confidential) ->
  {Assertion} = library

  (request) ->
    header = request?.headers?.authorization
    assert header?, "unable to locate authorization header"
    assert (isString header), "header value must be a string"

    start = header.indexOf " "
    scheme = header[0...start]
    assert scheme == "X-Capability", "invalid scheme #{scheme}"

    token = header[start...].trim()

    Assertion.from "base64", token


export default Parse
