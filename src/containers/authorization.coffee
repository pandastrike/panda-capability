import {isType, toJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Plaintext, sign} = confidential

  class Authorization
    constructor: ({@clientKeys, @capabilityKeys, @issuerDeclaration,
      @parameters}) ->

    # Outputs an authorization header value for a given request.
    stamp: ->
      # Package request parameters and issued capability.
      plaintext = Plaintext.from "utf8",
        toJSON {@parameters, @issuerDeclaration}

      # Sign with client keys
      {publicKey, privateKey} = @clientKeys
      clientDeclaration = sign publicKey, privateKey, plaintext

      # Sign with use keys
      {publicKey, privateKey} = @capabilityKeys
      clientDeclaraton = sign publicKey, privateKey, clientDeclaration

      # Output AUTHORIZATION header.
      "X-Capability #{clientDeclaration.to "base64"}"

    @from: (value) -> new Authorization value

    @isType: isType @

export default Container
