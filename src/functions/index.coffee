import {include} from "panda-parchment"
import _issue from "./issue"
import _challenge from "./challenge"

Functions = (library, confidential) ->
  issue = _issue library, confidential
  challenge = _challenge library, confidential

  include library, {issue, challenge}

export default Functions
