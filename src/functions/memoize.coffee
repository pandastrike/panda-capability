import {toJSON, isString, isObject, merge} from "panda-parchment"
import Method from "panda-generics"

Memoize = (library, confidential) ->
  {Memo} = library
  {Message, hash} = confidential

  memoize = Method.create
    name: "memoize"
    description: "Issues a Memo to a claimant in place of a grant to be more performantly validated."

  Method.define memoize,
    isString, isObject,
    (secret, content) ->

      # Link the content to an issuer-held secret with an integrity hash
      integrity = hash Message.from "utf8", toJSON merge {secret}, content
      .to "base64"

      # Issue memo
      Memo.create {integrity, content}

  memoize

export default Memoize
