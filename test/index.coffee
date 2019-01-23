import assert from "assert"
import {print, test} from "amen"
import {confidential} from "panda-confidential"
import Capability from "../src"

do ->
  await print await test "Panda Capability", ->
    capability = Capability confidential()
    console.log capability
    assert capability.foo
