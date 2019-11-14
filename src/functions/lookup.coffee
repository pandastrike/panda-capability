import {toJSON, isString, isObject} from "panda-parchment"
import Method from "panda-generics"
import URLTemplate from "url-template"

Lookup = (library, confidential) ->
  {Directory} = library

  lookup = Method.create
    name: "lookup"
    description: "Lookup a Contract whose template matches the given URL."

  Method.define lookup, Directory.isType, isString, isObject,
    (directory, path, description) ->
      for template, methods of directory
        if path == URLTemplate.parse(template).expand description
          return methods
      undefined

  Method.define lookup, Directory.isType, isString,
    (directory, path) ->
      lookup directory, path, {}

  lookup

export default Lookup
