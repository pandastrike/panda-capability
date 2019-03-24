import {include} from "panda-parchment"
import challenge from "./challenge"
import exercise from "./exercise"
import issue from "./issue"
import lookup from "./lookup"
import parse from "./parse"
import publicize from "./publicize"
import refresh from "./refresh"


Functions = (library, confidential) ->
  include library, challenge: challenge library, confidential
  include library, exercise: exercise library, confidential
  include library, issue: issue library, confidential
  include library, lookup: lookup library, confidential
  include library, parse: parse library, confidential
  include library, publicize: publicize library, confidential
  include library, refresh: refresh library, confidential

export default Functions
