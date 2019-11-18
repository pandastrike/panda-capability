import {toJSON, isString, isObject, merge} from "panda-parchment"
import Method from "panda-generics"
import AJV from "ajv"
import schema from "../schema/memo"

ajv = new AJV()

Memoize = (library, confidential) ->
  {Memo} = library
  {Message, hash} = confidential

  memoize = Method.create
    name: "memoize"
    description: "Issues a Memo to a claimant in place of a grant to be more performantly validated."

  Method.define memoize,
    isString, isObject,
    (secret, content) ->

      integrity = hash Message.from "utf8", toJSON merge {secret}, content
      .to "base64"

      memo = {integrity, content}

      unless ajv.validate schema, memo
        console.error toJSON ajv.errors, true
        throw new Error "Memo failed validation."

      # Sign the populated capability to issue a grant.
      Memo.create memo

  memoize

export default Memoize
