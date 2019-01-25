import {isType, fromJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Declaration, verify} = confidential

  class Request
    constructor: ({@url, @method, @headers, @body}) ->

    # Unpack the nested signature declarations within the authorization header.
    parse: ->
      @clientDeclaration = Declaration.from "base64",
        @headers.authorization.split(" ")[1]

      {parameters, issuerDeclaration} =
        fromJSON @clientDeclaration.data.to "utf8"

      @issuerDeclaration = Declaration.from "base64", issuerDeclaration

      issuerKey = @issuerDeclaration.signatories[0].to "base64"

      [clientKey, useKey] =
        for key in @clientDeclaration.signatories
          key.to "base64"

      @claim = {parameters, clientKey, useKey, issuerKey}

    # Verify the internal consistency fo the various declarations
    verifySignatures: ->
      unless verify @clientDeclaration
        throw new Error "verification failure: client signature invalid"
      unless verify @issuerDeclaration
        throw new Error "verification failure: issuer signature is invalid"

    # Extracts the specific capabilty exercised by the client.
    # However it first confirms the internal consistency of:
    #   - client signatures
    #   - issuer signature
    #   - request structure
    extractClaim: ->
      @parse()
      @verifySignatures()
      @verifyRequest()
      @claim

    # For now, just instanciate the request.  We perform checks with helper
    # methods used by the panda-capability:verify function.
    @from: (value) -> new Request value

    @isType: isType @

export default Container
