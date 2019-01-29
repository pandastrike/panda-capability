import {include} from "panda-parchment"
import Assertion from "./assertion"
import Grant from "./grant"
import Methods from "./methods"
import Directory from "./directory"
import Template from "./template"

containers = (library, confidential) ->
  include library, {Methods, Template}
  include library, Assertion: Assertion library, confidential
  include library, Grant: Grant library, confidential
  include library, Directory: Directory library, confidential


export default containers
