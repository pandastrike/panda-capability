import {isType, isObject, fromJSON, toJSON} from "panda-parchment"

assert = (predicate, message) ->
  throw new Error "verify failure: #{message}" unless predicate

Container = (library, confidential) ->
  {Grant, Delegation, Claim} = library
  {Declaration, verify} = confidential

  class Contract
    constructor: ({@grant, @delegations, @claim}) ->
      @delegations ?= []

    to: (hint) ->
      contract =
        grant: @grant.to "utf8"
        delegations: (delegation.to "utf8" for delegation in @delegations)
        claim: @claim.to "utf8" if @claim?

        if hint == "utf8"
          toJSON contract
        else
          convert from: "utf8", to: hint, toJSON contract

    verify: ->
      assert @grant?.verify(), "invalid grant signature"
      assert @claim?.verify(), "invalid claim signature"

      # Check claim expiration against grant tolerance
      @toleranceCheck contract

    @toleranceCheck: ->
      {tolerance} = @grant
      timestamp = new Date @claim.timestamp
      now = new Date()
      low = new Date()
      high = new Date()

      if (seconds = tolerance.seconds)?
        low.setSeconds now.getSeconds - seconds
        high.setSeconds now.getSeconds + seconds
      else if (minutes = tolerance.minutes)?
        low.setMinutes now.getMinutes - minutes
        high.setMinutes now.getMinutes + minutes
      else
        throw new Error "undefined grant tolerance"

      assert (low < timestamp < high), "The claim is expired."

    @create: (value) -> new Contract value

    @from: (hint, value) ->
      new Contract do ->
        {grant, delegations, claim} = do ->
          if hint == "utf8"
            fromJSON value
          else
            fromJSON convert from: hint, to: "utf8", value

        grant: Grant.from "utf8", grant
        delegations: do ->
          for delegation in delegations
            Delegation.from "utf8", delegation
        claim: Claim.from "utf8", claim if claim?

    @isType: isType @

export default Container
