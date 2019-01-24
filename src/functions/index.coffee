import {include} from "panda-parchment"
import _issue from "./issue"

Functions = (library, confidential) ->
  issue = _issue library, confidential

  include library, {issue}

export default Functions
