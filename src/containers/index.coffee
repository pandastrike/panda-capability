import {include} from "panda-parchment"
import Capability from "./capability"
import Grant from "./grant"
import Capchain from "./capchain"

containers = (library, confidential) ->
  include library, Capability: Capability library, confidential
  include library, Grant: Grant library, confidential
  include library, Capchain: Capchain library, confidential

export default containers
