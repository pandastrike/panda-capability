import {isType, include, toJSON, fromJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Grant} = library
  {convert, SignatureKeyPair} = confidential

  class Directory
    constructor: (directory) -> include @, directory

    to: (hint) ->
      directory = {}
      for template, methods of @
        directory[template] = {}
        for method, {grant, useKeyPairs} of methods
          directory[template][method] =
            grant: grant.to "utf8"
            useKeyPairs: (pair.to "base64" for pair in useKeyPairs)

      if hint == "utf8"
        toJSON directory
      else
        convert from: "utf8", to: hint, toJSON directory

    @create: (value) -> new Directory value

    @from: (hint, value) ->
      new Directory do ->
        directory = do ->
          if hint == "utf8"
            fromJSON value
          else
            fromJSON convert from: hint, to: "utf8", value

        for template, methods of directory
          for method, {grant, useKeyPairs} of methods
            directory[template][method] =
              grant: Grant.from "utf8", grant
              useKeyPairs:
                for pair in useKeyPairs
                  SignatureKeyPair.from "base64", pair

        directory

    @isType: isType @

export default Container
