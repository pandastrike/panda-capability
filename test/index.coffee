import assert from "assert"
import {print, test} from "amen"
import {confidential} from "panda-confidential"
import {toJSON} from "panda-parchment"
import PandaCapability from "../src"

do ->
  await print await test "Panda Capability", ->
    Confidential = confidential()
    {SignatureKeyPair} = Confidential
    {issue, Portfolio, exercise, challenge} = PandaCapability Confidential

    # The API has its own signature key pair for issuing capabilites to people
    APIKeyPair = await SignatureKeyPair.create()

    # Alice creates her profile signing key pair and sends the public key to
    # the API when she asks it to create a profile for her.
    Alice = await SignatureKeyPair.create()
    alice = Alice.publicKey


    #==========================================

    # API creates a profile for Alice and
    # issues a portfolio of granted capabilities for her resources.
    portfolio = await issue APIKeyPair, alice, [
        template: "/profiles/alice/dashes"
        methods: ["OPTIONS", "POST"]
      ,
        template: "/profiles/alice/dashes/{id}"
        methods: ["OPTIONS", "GET", "PUT"]
    ]

    # Serialize the portfolio for transport to alice.
    serializedPortfolio = portfolio.to "utf8"


    #======================================


    # Later, when the alice wants to excercise one of the capabilities in
    # her portfolio by creating a new dash.

    # alice hydrates her portfolio from serialized storage
    portfolio = Portfolio.from "utf8", serializedPortfolio

    # alice grabs relevant grant.
    # (Template could come from panda-sky-client)
    grant = portfolio["/profiles/alice/dashes"]["POST"]

    # alice specifies the parameters for the template; none for this request.
    parameters = {}

    # alice exercises her capability to populate the AUTHORIZATION header.
    # yields an assertion.
    assertion = exercise grant, Alice, parameters
    request =
      url: "/profiles/alice/dashes"
      method: "POST"
      headers:
        authorization: "X-Capability #{assertion.to "base64"}"


    #=======================================


    # Back over in the API, it recieves the request from alice
    try
      # API challenges the request's assertion
      assertion = challenge request
    catch e
      console.error e
      assert.fail "challenge should have passed."

    # The request passes this challenge and is internally consistent.
    # The API gets back an instaciated assertion of that passed, including
    # a dictionary of public signing keys used in its construction.
    # The API is responsible for a revocation check on those keys

    # For now, the API compares the assertion's keys against its copy of
    # alice's portfolio.
    apiKey = APIKeyPair.publicKey.to "base64"

    {publicKeys, capability} = assertion
    {useKey, clientKey, issuerKey} = publicKeys

    portfolio = Portfolio.from "utf8", serializedPortfolio
    grant = portfolio[capability.template][request.method]
    {capability:{use, recipient}} = grant

    assert.equal issuerKey, apiKey, "issuer key does not match"
    assert.equal useKey, use[0], "use key does not match"
    assert.equal clientKey, recipient, "client key does not match"
