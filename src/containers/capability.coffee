import {isType, isString, isArray, toJSON, fromJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Template, Methods} = library
  {convert} = confidential

  class Capability
    constructor: ({@methods, @template, @recipient, @use}) ->

    to: (hint) ->
      value = toJSON
        methods: @methods.to "utf8"
        template: @template.to "utf8"
        recipient: @recipient.to "base64"
        use: (key.to "base64" for key in @use)

      if hint == "utf8"
        value
      else
        convert from: "utf8", to: hint, value

    @from: (hint, value) ->
      new Capability do ->
        {methods, template, recipient, use} =
          if hint == "utf8"
            fromJSON value
          else
            fromJSON convert from: hint, to: "utf8", value

        methods: Methods.from "utf8", toJSON methods
        template: Template.from "utf8", template
        recipient: PublicKey.from "base64", recipient
        use: (PublicKey.from "base64", key for key in use)

    @isType: isType @

export default Container
