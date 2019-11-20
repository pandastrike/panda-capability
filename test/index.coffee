import "source-map-support/register"
import {print, test} from "amen"
import {sleep} from "panda-parchment"

import Tests from "./tests"

do ->
  await print await test "Panda Capability", [
    test "Authorities", [
      test
        description: "Literal Key"
        wait: false,
        Tests.Authorities.literal

      test
        description: "URL Web Signature"
        wait: false,
        Tests.Authorities.url

      test
        description: "URL-Template Web Signature"
        wait: false,
        Tests.Authorities.template
    ]
  ]
