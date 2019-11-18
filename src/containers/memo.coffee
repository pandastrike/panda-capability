import {isType, fromJSON, toJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Message, hash} = confidential

  class Memo
    constructor: ({@integrity, @content, @claim}) ->

    to: (hint) ->
      memo = {@integrity, @content, @claim}
      if hint == "utf8"
        toJSON memo
      else
        convert from: "utf8", to: hint, toJSON memo

    # Verifies the integrity of the memo, given the anchoring secret.
    verify: (secret) ->
      claim = hash Message.from "utf8", toJSON merge {secret}, content
      .to "base64"

      unless claim == @integrity
        throw new Error "Invalid memo. Integrity hash failure."

    @create: (value) -> new Memo value

    @from: (hint, value) ->
      new Memo do ->
        if hint == "utf8"
          fromJSON value
        else
          fromJSON convert from: hint, to: "utf8", value

    @isType: isType @

export default Container
