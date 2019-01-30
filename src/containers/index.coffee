import {include} from "panda-parchment"
import Assertion from "./assertion"
import Directory from "./directory"
import Grant from "./grant"

containers = (library, confidential) ->
  include library, Assertion: Assertion library, confidential
  include library, Grant: Grant library, confidential
  include library, Directory: Directory library, confidential


export default containers
