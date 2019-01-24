import {isType, isString, isArray, toJSON, fromJSON} from "panda-parchment"
import {isUse, allAllowedMethods} from "../utils"

# Sanity check on a grant object's structure.
ifValid = (capability) ->
  {methods, template, recipient, use} = capability
  unless allAllowedMethods methods
    throw new Error "Invalid capability: methods = #{methods}"
  unless isString template
    throw new Error "Invalid capability: template = #{template}"
  unless isString recipient
    throw new Error "Invalid capability: template = #{template}"
  unless isUse use
    throw new Error "Invalid capability: use = #{use}"
  capability

Container = (library, confidential) ->
  {convert} = confidential

  class Capability
    constructor: ({@methods, @template, @recipient, @use}) ->

    to: (hint) ->
      value = toJSON {@methods, @template, @recipient, @use}
      if hint == "utf8"
        value
      else
        convert from: "utf8", to: hint, value

    @from: (hint, value) ->
      new Capability ifValid do ->
        switch hint
          when "object" then value
          when "utf8" then fromJSON value
          else fromJSON convert from: hint, to: "utf8", value

    @isType: isType @

export default Container
