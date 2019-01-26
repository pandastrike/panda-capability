import {include, toJSON, fromJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Grant} = library
  {convert} = confidential

  class Portfolio
    constructor: (portfolio) -> include @, portfolio

    to: (hint) ->
      if hint == "utf8"
        toJSON @
      else
        convert from: "utf8", to: hint, toJSON @

    @from: (hint, value) ->
      portfolio = switch hint
        when "object" then value
        when "utf8" then fromJSON value
        else fromJSON convert from: hint, to: "utf8", value

      for template, methods of portfolio
        for method, capability of methods
          portfolio[template][method] = Grant.from "object", capability

      new Portfolio portfolio

    @isType: isType @

export default Container
