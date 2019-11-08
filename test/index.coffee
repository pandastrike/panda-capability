import "source-map-support/register"
import {print, test} from "amen"
import {confidential} from "panda-confidential"
import PandaCapability from "../src"

import standard from "./standard"
#import memoized from './memoized'

do ->
  Confidential = confidential()
  Capability = PandaCapability Confidential

  await print await test "Panda Capability", [
    test
      description: "Standard - Issue, Claim, Verify"
      wait: false,
      standard Confidential, Capability
  ]
