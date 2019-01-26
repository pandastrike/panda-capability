import {include} from "panda-parchment"
import _issue from "./issue"
import _exercise from "./exercise"
import _challenge from "./challenge"

Functions = (library, confidential) ->
  issue = _issue library, confidential
  exercise = _exercise library, confidential
  challenge = _challenge library, confidential

  include library, {issue, exercise, challenge}

export default Functions
