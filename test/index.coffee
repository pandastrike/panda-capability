import {print, test} from "amen"
import {confidential} from "panda-confidential"
import PandaCapability from "../src"

import mainline from "./mainline"
import refresh from "./refresh"

do ->
  Confidential = confidential()
  Capability = PandaCapability Confidential

  await print await test "Panda Capability", [
    test
      description: "Mainline - Issue, Assert, Challenge"
      wait: false,
      mainline Confidential, Capability

    test
      description: "Refresh Cycle",
      wait: false,
      refresh Confidential, Capability
  ]
