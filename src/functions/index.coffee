import {include} from "panda-parchment"
import delegate from "./delegate"
import exercise from "./exercise"
import issue from "./issue"
import lookup from "./lookup"
import parse from "./parse"
import verify from "./verify"


Functions = (library, confidential) ->
  include library, delegate: delegate library, confidential
  include library, exercise: exercise library, confidential
  include library, issue: issue library, confidential
  include library, lookup: lookup library, confidential
  include library, parse: parse library, confidential
  include library, verify: verify library, confidential

export default Functions
