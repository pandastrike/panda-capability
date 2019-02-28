import assert from "assert"
import {print, test} from "amen"
import {confidential} from "panda-confidential"
import {toJSON, clone} from "panda-parchment"
import PandaCapability from "../src"

do ->
  await print await test "Panda Capability", ->
    Confidential = confidential()
    {SignatureKeyPair, PrivateKey} = Confidential
    {issue, Directory, lookup, exercise, parse, challenge} =
      PandaCapability Confidential

    # The API has its own signature key pair for issuing capabilites to people
    APIKeyPair = await SignatureKeyPair.create()

    # Alice creates her profile signing key pair and sends the public key to
    # the API when she asks it to create a profile for her.
    Alice = await SignatureKeyPair.create()
    alice = Alice.publicKey


    #==========================================

    # API creates a profile for Alice and
    # issues a directory of granted capabilities for her resources.
    directory = await issue APIKeyPair, alice, [
        template: "/profiles/alice/dashes"
        methods: ["OPTIONS", "POST"]
      ,
        template: "/profiles/alice/dashes/{id}"
        methods: ["OPTIONS", "GET", "PUT"]
    ]

    # API serializes the directory for transport to alice.
    serializedDirectory = directory.to "utf8"


    #======================================

    # Later, when the alice wants to excercise one of the capabilities in
    # her directory by creating a new dash.

    # alice hydrates her directory from serialized storage
    directory = Directory.from "utf8", serializedDirectory

    # alice looks up the relevant grant matching the capability she wants
    # to exercise. (URL could come from panda-sky-client)
    methods = lookup directory, "/profiles/alice/dashes"
    {grant, useKeyPairs} = methods.POST

    # alice specifies the parameters for the grant; none for this request.
    parameters = {}

    # alice exercises the seal and populates the AUTHORIZATION header.
    assertion = exercise Alice, useKeyPairs, grant, parameters
    request =
      url: "/profiles/alice/dashes"
      method: "POST"
      headers:
        authorization: "Capability #{assertion.to "base64"}"
        date: new Date().toISOString()  # added by Fetch agent automatically.

    # Alternate request with different cased authorization scheme name.
    request2 = clone request
    request2.headers.authorization = "capability #{assertion.to "base64"}"


    #=======================================


    # Back over in the API, it recieves the request from alice
    try
      # API challenges the request's assertion
      assertion = parse request
      parse request2  # case insenstivity check
      challenge request, assertion
    catch e
      console.error e
      assert.fail "challenge should have passed."

    #========================================
    # Revocation Check
    #
    # The request passes this challenge and is internally consistent.
    # The API gets back an instaciated assertion of that passed, including
    # a dictionary of public signing keys used in its construction.
    # The API is responsible for a revocation check on those keys

    # For now, the API compares the assertion's keys against its copy of
    # alice's directory.
    {capability, publicKeys} = assertion

    apiKey = APIKeyPair.publicKey.to "base64"
    directory = Directory.from "utf8", serializedDirectory
    {publicUseKeys, recipient} = directory[capability.template][request.method]
      .grant.message
      .json()

    # Assertion public key vs authoritative source
    assert.equal publicKeys.issuer, apiKey, "issuer key does not match"
    assert.equal publicKeys.use, publicUseKeys[0], "use key does not match"
    assert.equal publicKeys.recipient, recipient, "recipient key does not match"
