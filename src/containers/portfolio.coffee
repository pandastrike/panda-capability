import {isType, include, toJSON, fromJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Grant} = library
  {convert} = confidential

  class Portfolio
    constructor: (portfolio) -> include @, portfolio

    to: (hint) ->
      portfolio = {}
      for template, methods of @
        portfolio[template] = {}
        for method, grant of methods
          portfolio[template][method] = grant.to "utf8"

      if hint == "utf8"
        toJSON portfolio
      else
        convert from: "utf8", to: hint, toJSON portfolio

    @create: (value) -> new Portfolio value

    @from: (hint, value) ->
      new Portfolio do ->
        portfolio =
          if hint == "utf8"
            fromJSON value
          else
            fromJSON convert from: hint, to: "utf8", value

        for template, methods of portfolio
          for method, grant of methods
            portfolio[template][method] = Grant.from "utf8", grant

        portfolio

    @isType: isType @

export default Container
