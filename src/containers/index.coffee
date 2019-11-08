import {include} from "panda-parchment"
import Claim from "./claim"
import Directory from "./directory"
import Grant from "./grant"

containers = (library, confidential) ->
  include library, Grant: Grant library, confidential
  include library, Directory: Directory library, confidential
  include library, Claim: Claim library, confidential

export default containers
