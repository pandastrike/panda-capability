import {include} from "panda-parchment"
import _issue from "./issue"

Functions = (library, confidential) ->
  issue = _issue library, confidential
  exercise = _exercise library, confidential
  include library, {issue, exercise}

export default Functions
