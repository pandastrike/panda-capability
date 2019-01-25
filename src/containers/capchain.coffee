import {include, toJSON, fromJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Grant} = library
  {convert} = confidential

  class Capchain
    constructor: (capchain) -> include @, capchain

    to: (hint) ->
      if hint == "utf8"
        toJSON @
      else
        convert from: "utf8", to: hint, toJSON @

    @from: (hint, value) ->
      capchain = switch hint
        when "object" then value
        when "utf8" then fromJSON value
        else fromJSON convert from: hint, to: "utf8", value

      for template, methods of capchain
        for method, capability of methods
          capchain[template][method] = Grant.from "object", capability

      new Capchain capchain

    @isType: isType @

export default Container
