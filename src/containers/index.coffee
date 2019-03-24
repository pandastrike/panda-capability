import {include} from "panda-parchment"
import Assertion from "./assertion"
import Directory from "./directory"
import Grant from "./grant"
import PublicDirectory from "./public-directory"

containers = (library, confidential) ->
  include library, Assertion: Assertion library, confidential
  include library, Grant: Grant library, confidential
  include library, Directory: Directory library, confidential
  include library, PublicDirectory: PublicDirectory library, confidential


export default containers
