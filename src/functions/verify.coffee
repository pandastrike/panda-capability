import URLTemplate from "url-template"
import Method from "panda-generics"
import {toJSON, isObject, isString} from "panda-parchment"

assert = (predicate, message) ->
  throw new Error "verify failure: #{message}" unless predicate

Verify = (library, confidential) ->

  {Contract, Memo} = library

  verify = Method.create
    name: "verify"
    description: "Verify a sealed Contract or Memo against a request."

  Method.define verify, isObject, Contract.isType,
    (request, contract) ->

      # Internal consistency checks.
      {parameters, methods} = await contract.verify()

      # Compare request URL to contract
      url = URLTemplate
        .parse contract.grant.template
        .expand parameters

      assert request.url == url,
        "url does not match grant"

      # Compare request method to contract
      assert request.method in methods,
        "HTTP method does not match grant"

      assert request.method == contract.claim.method,
        "HTTP method does not match claim"


  Method.define verify, isObject, Memo.isType, isString,
    (request, memo, secret) ->

      # Internal consistency checks.
      memo.verify secret

      # Compare request URL to memo.
      if (template = memo.content.resource.template)?
        url = URLTemplate
          .parse template
          .expand memo.claim.template ? {}
      else
        url = memo.content.resource.url

      assert request.url == url,
        "url does not match memo"

      # Compare request method to memo
      assert request.method in memo.content.methods,
        "HTTP method does not match memo"

  verify

export default Verify
