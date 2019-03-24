import {isType, include, toJSON, fromJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Grant} = library
  {convert} = confidential

  class PublicDirectory
    constructor: (directory) -> include @, directory

    to: (hint) ->
      directory = {}
      for template, methods of @
        directory[template] = {}
        for method, {grant} of methods
          directory[template][method] =
            grant: grant.to "utf8"

      if hint == "utf8"
        toJSON directory
      else
        convert from: "utf8", to: hint, toJSON directory

    @create: (value) -> new PublicDirectory value

    @from: (hint, value) ->
      new PublicDirectory do ->
        directory = do ->
          if hint == "utf8"
            fromJSON value
          else
            fromJSON convert from: hint, to: "utf8", value

        for template, methods of directory
          for method, {grant} of methods
            directory[template][method] =
              grant: Grant.from "utf8", grant

        directory

    @isType: isType @

export default Container
