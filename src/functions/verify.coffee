import URLTemplate from "url-template"
import Method from "panda-generics"
import {toJSON, isObject} from "panda-parchment"

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
      contract.verify()

      # Compare request URL to contract
      url = URLTemplate
        .parse contract.grant.template
        .expand contract.claim.url

      assert request.url == url,
        "url does not match grant"

      # Compare request method to contract
      assert request.method in contract.grant.methods,
        "HTTP method does not match grant"

      assert request.method == contract.claim.method,
        "HTTP method does not match claim"


  # Method.define verify, isObject, Memo.isType,
  #   (request, memo) ->
  #
  #     # Check claim expiration
  #     assert new Date().toISOString() < memo.expires,
  #       "The memo is expired."
  #
  #     # Compare request to claim parameters
  #
  #     #= URL
  #     url = URLTemplate
  #       .parse memo.template
  #       .expand memo.parameters
  #
  #     assert request.url == url,
  #       "url does not match memo"
  #
  #     #= HTTP Method
  #     assert request.method == method,
  #       "HTTP method does not match memo"


export default Verify
