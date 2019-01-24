import assert from "assert"
import {print, test} from "amen"
import {confidential} from "panda-confidential"
import {toJSON} from "panda-parchment"
import PandaCapability from "../src"

import {APIKeyPair, getProfile} from "my-library"

do ->
  await print await test "Panda Capability", ->
    Confidential = confidential()
    {SignatureKeyPair, Plaintext, sign} = Confidential
    {issue} = PandaCapability Confidential

    # API creates a profile for Alice.
    {publicKey:alice} = getProfile "alice"

    # Issue capabilities for her resources.
    capchain = await issue APIKeyPair, alice, [{
      template: "root/alice"
      methods: ["OPTIONS", "GET", "PUT", "DELETE"]
      },{
      template: "/profiles/alice"
      methods: ["OPTIONS", "GET", "PUT"]
      },{
      template: "/profiles/alice/devices/{device}"
      methods: ["OPTIONS", "POST"]
      },{
      template: "/profiles/alice/devices/{device}"
      methods: ["OPTIONS", "GET", "PUT", "POST", "DELETE"]
      },{
      template: "/profiles/alice/dashes{?page}"
      methods: ["OPTIONS", "GET", "POST"]
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
