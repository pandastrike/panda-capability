import {include} from "panda-parchment"
import Capability from "./capability"
import Grant from "./grant"
import Portfolio from "./portfolio"
import Assertion from "./assertion"

containers = (library, confidential) ->
  include library, Capability: Capability library, confidential
  include library, Grant: Grant library, confidential
  include library, Portfolio: Portfolio library, confidential
  include library, Assertion: Assertion library, confidential

export default containers
