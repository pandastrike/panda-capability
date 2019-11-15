import {isType, isObject, fromJSON, toJSON, isEmpty, last} from "panda-parchment"

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
      @verifySignatures()
      @verifyTolerance()
      parameters = @verifyTemplate()
      methods = @verifyMethods()

      {parameters, methods}

    verifySignatures: ->
      assert @grant?.verify(), "invalid grant signature"
      assert @claim?.verify(), "invalid claim signature"

      for delegation in contract.delegations
        assert delegation.verify(), "invalid delegation signature"

    verifyToleranceCheck: ->
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

    # URL template parameters in a claim may be specified directly in a claim or indirectly by being bound in a delegation. This validates the possible parameter binding delegation and returns the ultimate URL template parameters.
    verifyTemplate: ->
      parameters = {}
      for delegation in @delegations
        if delegation.template?
          if isEmpty parameters
            parameters = delegation.template
          else
            throw new Error "Invalid delegation. May not bind URL template in multiple delegations."

      if @claim.template?
        if isEmpty parameters
        else
          throw new Error "Invalid claim. May not re-bind URL template when bound by a delegation."

      parameters

    # Allowed HTTP methods are specified in the grant and possibly narrowed in  delegation. This returns the array of ultimately allowed
    verifyMethods: ->
      methods = @grant.methods

      for delegation in @delegations
        _methods = []

        for method in delegation.methods
          if method in methods
            _methods.push method
          else
            throw new Error "Invalid delegatation. Method is beyond scope."

        methods = _methods

      methods

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
