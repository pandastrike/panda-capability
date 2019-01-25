import assert from "assert"
import {print, test} from "amen"
import {confidential} from "panda-confidential"
import {toJSON} from "panda-parchment"
import PandaCapability from "../src"

import {APIKeyPair, newProfile, getCapchain} from "api-library"
import {LocalKeyPair} from "local-library"

do ->
  await print await test "Panda Capability", ->
    Confidential = confidential()
    {SignatureKeyPair, Plaintext, sign} = Confidential
    {issue} = PandaCapability Confidential

    # API creates a profile for Alice.
    alice = newProfile "alice"

    # API Issues capabilities for her resources.
    capchain = await issue APIKeyPair, alice, [
        template: "root/alice"
        methods: ["OPTIONS", "GET", "PUT", "DELETE"]
      ,
        template: "/profiles/alice"
        methods: ["OPTIONS", "GET", "PUT"]
      ,
      template: "/profiles/alice/devices/{device}"
      methods: ["OPTIONS", "POST"]
      },{
      template: "/profiles/alice/devices/{device}"
      methods: ["OPTIONS", "GET", "PUT", "POST", "DELETE"]
      },{
      template: "/profiles/alice/dashes"
      methods: ["OPTIONS", "POST"]
      },{
      template: "/profiles/alice/dashes/{id}"
      methods: ["OPTIONS", "GET", "PUT"]
      },{
      template: "/profiles/alice/shares/{id}"
      methods: ["OPTIONS", "POST"]
      },{
      template: "/profiles/alice/replies/{id}"
      methods: ["OPTIONS", "POST"]
      },{
      template: "/profiles/alice/contributors/{target}"
      methods: ["OPTIONS", "POST", "DELETE"]
      },{
      template: "/profiles/alice/blocks/{target}"
      methods: ["OPTIONS", "POST", "DELETE"]
      },{
      template: "/profiles/alice/upload"
      methods: ["OPTIONS", "POST"]
      },{
      template: "/profiles/alice/media/{id}"
      methods: ["OPTIONS", "POST", "DELETE"]
    }]

    # Serialize the capchain for transport to alice.
    serializedCapchain = capchain.to "utf8"


    #======================================


    # Later, when the alice wants to excercise one of the capabilities in
    # her capchain by creating a new dash.

    # alice hydrates her capchain from serialized storage
    capchain = Capchain.from "utf8", serializedCapchain

    # alice grabs relevant grant.
    # (Template could come from panda-sky-client)
    grant = capchain["/profiles/alice/dashes"]["POST"]

    # alice specifies the parameters for the template; none for this request.
    parameters =
      template: {id}
      body: "Hello, World!"

    # alice exercises her capability. This is an instanciated class because
    # it may be reused and adopt other request parameters:
    # template, body, nonce, timestamp, etc.
    authority = exercise grant, localKeyPair, parameters

    # As the HTTP request is formed, alice uses the authorization to populate
    # the AUTHORIZATION header.
    # yields "X-Capability base64StringRFfBy/1mioLtrsxk2....."

    headers = authorization: authority.stamp()



    #=======================================


    # Back over in the API, it recieves the request from alice and must validate
    # the capability assertion.

    # API instanciates a Request class to parse the capability assertion and
    # the request properties.
    request = Request.from APIHandler

    # API hydrates alice's capchain from serialized storage
    capchain = Capchain.from "utf8", getCapchain "alice"

    # API uses it to verify the authorization header.
    if result = verify capchain, authorization
      ## free to proceed
    else
      # verficiation failed
