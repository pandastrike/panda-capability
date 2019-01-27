import Containers from "./containers"
import Functions from "./functions"

Capability = (confidential) ->
  library = {}
  Containers library, confidential
  Functions library, confidential

export default Capability
