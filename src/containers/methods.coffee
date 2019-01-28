import {isType, toJSON, fromJSON} from "panda-parchment"

allowedMethods = ["HEAD", "OPTIONS", "GET", "PUT", "PATCH", "POST", "DELETE"]

Container = (library, confidential) ->
  {convert} = confidential

  class Methods
    constructor: (@methods) ->

    to: (hint) ->
      value = toJSON value
      if hint == "utf8"
        value
      else
        convert from: "utf8", to: hint, value

    @from: (hint, value) ->
      new Methods do ->
        methods =
          if hint == "utf8"
            fromJSON value
          else
            convert from: hint, to: "utf8", value

        for method in methods
          unless method in allowedMethods
            throw new Error "HTTP method #{method} is invalid"

        methods

    @isType: isType @

export default Container
