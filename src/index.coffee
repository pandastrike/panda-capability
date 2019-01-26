import Containers from "./containers"
import Functions from "./functions"

Capability = (confidential) ->
  library = {confidential}
  Containers library
  Functions library

export default Capability
