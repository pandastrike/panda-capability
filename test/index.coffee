import "source-map-support/register"
import {print, test} from "amen"

import literal from "./literal"

do ->
  await print await test "Panda Capability", [
    test
      description: "Literal Key Authorities"
      wait: false,
      literal
  ]
