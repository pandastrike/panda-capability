import {isType, fromJSON, toJSON} from "panda-parchment"

Container = (library, confidential) ->
  {convert, PublicKey, PrivateKey, Message, sign, Declaration} = confidential

  class Grant
    constructor: ({@capability, @declaration, @use}) ->

    to: (hint) ->
      value = toJSON
        capability: @capability
        declaration: @declaration.to "base64"
        use: (key.to "base64", key for key in @use)

      if hint == "utf8"
        value
      else
        convert from: "utf8", to: hint, value

    # Package request parameters and grant declaration into an authority.
    exercise: (parameters) ->
      publicKey = PublicKey.from "base64", @capability.use[0]
      privateKey = @use[0]

      sign publicKey, privateKey,
        Message.from "utf8", toJSON
          parameters: parameters
          issuerDeclaration: @declaration.to "base64"

    @create: (value) -> new Grant value

    @from: (hint, value) ->
      new Grant do ->
        {capability, declaration, use} =
          if hint == "utf8"
            fromJSON value
          else
            fromJSON convert from: hint, to: "utf8", value

        capability: capability
        declaration: Declaration.from "base64", declaration
        use: (PrivateKey.from "base64", key for key in use)

    @isType: isType @

export default Container
