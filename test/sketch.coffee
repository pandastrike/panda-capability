import assert from "assert"
import {toJSON, clone} from "panda-parchment"
import Template from "url-template"

Test = (Confidential, Capability) -> ->
  {SignatureKeyPair, PrivateKey} = Confidential
  {} = Capability


  # Alice creates her profile signing key pair and sends a URL or URL template to where a prospective validator may confirm her public signing key. This URL need not contain the key value directly, but the response body of a request to that URL must.
  Alice = await SignatureKeyPair.create()
  alice = "https://capability.test/profile-keys/{profile}"


  #==========================================

  # API creates a profile for Alice and issues a directory of granted capabilities for her resources.

  # The API has its own signature key pair for issuing capabilites to people

  # The issuer must include a URL where a prospective validator may confirm the public signing key. The final URL need not contain the key  value, but the response body must.

  APIKeyPair = await SignatureKeyPair.create()
  issuer = "https://application.test/keys/signature"


  contract = create new Date().toISOString()

  contract = append contract, delta
    addenda: [
      grant
        template: "/profiles/alice/dashes/{id}"
        methods: ["OPTIONS", "GET", "PUT"]
        to:
          type: "web signature public key"
        	url:
        		template: "/alice/devices/{name}/keys/signature"

      sign APISignatureKeyPair

    ]
    constraints: [
      request()

      signature
        type: "web signature"
        url: "/api/keys/signature"

      # This signature check relies on the bindings from processing during verification
      signature
        type: "web signature"
		    name: "claim"

      expiration
        name: "claim"
        duration:
          minutes: 5

    ]










# assuming a hash function and a secret
create = (nonce) ->
  tail: (hash secret, nonce), value: []

append = ({tail, value}, e) ->
	tail: (hash tail, e), value: push value, e

reconstruct = (nonce, value) ->
  reduce value, (create nonce), append

verify = (nonce, {tail, value}) ->
  tail == (reconstruct nonce, value).tail

# ---

nonce = Date.now()
chain = create nonce
chain = append chain, "apples"
chain = append chain, "oranges"
chain = append chain, "bananas"
assert verify nonce, chain



  grant = Grant.create
    template: "/profiles/alice/dashes/{id}"
    methods: ["OPTIONS", "GET", "PUT"]
    to:
      type: "web signature public key"
    	url:
    		template: "/alice/devices/{name}/keys/signature"

  apiSignature = Directive.create
    type: "web signature"
	  url: "/api/keys/signature"

  sign APIKeyPair, grant














  directory = await issue APIKeyPair, issuer, alice, [
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
  # her directory by editing an existing dash.

  # alice hydrates her directory from serialized storage
  directory = Directory.from "utf8", serializedDirectory

  # alice specifies the URL parameters for the request.
  parameters = id: "12345"

  # alice looks up the relevant grant matching the capability she wants
  # to exercise. (URL could come from panda-sky-client)
  methods = lookup directory, "/profiles/alice/dashes/12345", parameters
  grant = methods.PUT

  # alice specifies the parameters for this grant and its constraints.
  parameters =
    url: parameters
    constraints:
      recipient:
        profile: "alice"

  # alice exercises the grant and populates the Authorization header.
  claim = exercise Alice, grant, parameters
  request =
    url: "/profiles/alice/dashes/12345"
    method: "PUT"
    headers:
      authorization: "Capability #{claim.to "base64"}"
      date: new Date().toISOString()  # added by Fetch agent automatically.

  # Alternate request with different cased authorization scheme name.
  request2 = clone request
  request2.headers.authorization = "capability #{claim.to "base64"}"


  #=======================================


  # Back over in the API, it recieves the request from alice
  try
    # API verifies the request's claim
    claim = parse request
    parse request2  # case insenstivity check
    verify request, claim
  catch e
    console.error e
    assert.fail "verification should have passed."

  #========================================
  # Revocation Check
  #
  # Panda-capability confirms the *internal* consistency of a claim. However, a
  # validator is responsible for performing a revocation check on the grant's
  # constraints. What follows is a confirmation of the interface a validator
  # could use to perform that external check.

  {constraints} = claim.grant
  parameters = claim.parameters.constraints

  # Claim public key vs authoritative source
  assert.equal constraints[0].name, "issuer",
    "unexpected constraint in first element"
  assert.equal constraints[0].type, "web signature",
    "unexpected constraint type in first element"
  assert.equal constraints[0].url, issuer,
    "unexpected web signature URL in first element"

  assert.equal constraints[1].name, "recipient",
    "unexpected constraint in second element"
  assert.equal constraints[1].type, "web signature",
    "unexpected constraint type in second element"
  assert.equal(
    Template
    .parse constraints[1].url
    .expand(parameters.recipient)

    Template
    .parse constraints[1].url
    .expand profile: "alice"

    "unexpected web signature URL in second element"
  )

export default Test
