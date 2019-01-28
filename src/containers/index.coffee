import {include} from "panda-parchment"
import Assertion from "./assertion"
#import Capability from "./capability"
import Grant from "./grant"
import Methods from "./methods"
import Portfolio from "./portfolio"
import Template from "./template"

containers = (library, confidential) ->
  include library, {Methods, Template}
  #include library, Capability: Capability library, confidential
  include library, Grant: Grant library, confidential
  include library, Portfolio: Portfolio library, confidential
  include library, Assertion: Assertion library, confidential

export default containers
