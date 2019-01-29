import {isType, include, toJSON, fromJSON} from "panda-parchment"

Container = (library, confidential) ->
  {Grant} = library
  {convert, PrivateKey} = confidential

  class Directory
    constructor: (directory) -> include @, directory

    to: (hint) ->
      directory = {}
      for template, methods of @
        directory[template] = {}
        for method, {grant, privateUse} of methods
          directory[template][method] =
            grant: grant.to "base64"
            privateUse: (key.to "base64" for key in privateUse)

      if hint == "utf8"
        toJSON directory
      else
        convert from: "utf8", to: hint, toJSON directory

    @create: (value) -> new Directory value

    @from: (hint, value) ->
      new Directory do ->
        directory =
          if hint == "utf8"
            fromJSON value
          else
            fromJSON convert from: hint, to: "utf8", value

        for template, methods of directory
          for method, {grant, privateUse} of methods
            directory[template][method] =
              grant: Grant.from "base64", grant
              privateUse: (PrivateKey.from "base64", key for key in privateUse)

        directory

    @isType: isType @

export default Container
