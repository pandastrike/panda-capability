import URLTemplate from "url-template"
import {isType} from "panda-parchment"

Container = (library, confidential) ->
  {convert} = confidential

  class Template
    constructor: (@template) ->

    expand: (parameters) ->
      URLTemplate.parse @template
      .expand parameters

    to: (hint) ->
      if hint == "utf8"
        @template
      else
        convert from: "utf8", to: hint, @template

    @from: (hint, value) ->
      new Template do ->
        if hint == "utf8"
          value
        else
          convert from: hint, to: "utf8", value

    @isType: isType @

export default Container
