import assert from "assert"
import {toJSON, clone} from "panda-parchment"

import {confidential as Confidential} from "panda-confidential"
import Capability from "../../../src"

confidential = Confidential()
{SignatureKeyPair, PrivateKey} = confidential
{issue, Directory, lookup, exercise, parse, verify} = Capability confidential

Test = ->
  # The API has its own signature key pair for issuing capabilites to people
  APIKeyPair = await SignatureKeyPair.create()

  # Alice creates her profile signing key pair.
  Alice = await SignatureKeyPair.create()


  #==========================================

  # API creates a profile for Alice and issues grants for her resources.
  # For this test, we purposefully set the grant to expire now.
  now = new Date().toISOString()

  directory = bundle [
    issuer APIKeyPair,
      template: "/profiles/alice/dashes/{id}/expired"
      methods: ["GET", "PUT"]
      tolerance:
        seconds: 5
      expires: now
      issuer:
        literal: APIKeyPair.publicKey.to "base64"
      claimant:
        literal: Alice.publicKey.to "base64"
  ]

  # API serializes the directory for transport to alice.
  serializedDirectory = directory.to "utf8"


  #======================================

  # Later, when the alice wants to excercise one of the contracts in
  # her directory by editing an existing dash.

  # alice hydrates her directory from serialized storage
  directory = Directory.from "utf8", serializedDirectory

  # alice specifies the URL parameters for the request.
  parameters = id: "12345"

  # alice looks up the relevant contract matching the capability she wants
  # to exercise. (URL could come from panda-sky-client)
  methods = lookup directory, "/profiles/alice/dashes/12345", parameters
  contract = methods.PUT

  assert contract?, "lookup failed"
  assert (Contract.isType contract), "lookup failed"

  # alice forms a claim against the contract and its constraints to exercise the grant.
  claim = exercise Alice, contract,
    template: parameters
    method: "PUT"
    claimant:
      literal: Alice.publicKey.to "base64"

  # The contract is ready to be serialized and placed into the Authorization header.
  request =
    url: "/profiles/alice/dashes/12345"
    method: "PUT"
    headers:
      authorization: "Capability #{contract.to "base64"}"
      date: new Date().toISOString()  # added by Fetch agent automatically.

  #=======================================


  # Back over in the API, it recieves the request from alice
  try
    # API verifies the request's claim
    contract = parse request
    parse request2  # case insenstivity check
    verify request, claim
    assert.fail "verification should NOT have passed because grant is expired."
  catch e

export default Test
