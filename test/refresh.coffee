import assert from "assert"
import {keys} from "panda-parchment"

Test = (Confidential, Capability) -> ->
  {SignatureKeyPair, PrivateKey} = Confidential
  {issue, Directory, publicize, refresh} = Capability

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

  # Later, alice wants to refresh her grants.  For example, she could seek to have the issuer provide a directory for a new device.

  # alice hydrates her directory from serialized storage
  directory = Directory.from "utf8", serializedDirectory

  # alice creates a version of directory containing only public information
  publicDirectory = publicize directory

  # Confirm only public information is available
  for template, methods of publicDirectory
    for method, entry of methods
      assert (keys entry).length == 1
      assert entry.grant?

  # sends this public directory off to the API for processing.
  #=======================================

  # Back over in the API, it recieves the request from alice.
  # It refreshes the directory for a second public key from Alice (device 2)
  Alice2 = await SignatureKeyPair.create()
  newDirectory = await refresh APIKeyPair, Alice2.publicKey, publicDirectory

  assert Directory.isType newDirectory, "unexpected refresh product"
  assert.equal (keys newDirectory).length, (keys directory).length,
    "unexpected directory size"

  # negative tests on self-consitency
  badIssuer = await SignatureKeyPair.create()
  try
    await refresh badIssuer, Alice2.publicKey, publicDirectory
    assert.fail "should not have refreshed successfully"
  catch


export default Test
