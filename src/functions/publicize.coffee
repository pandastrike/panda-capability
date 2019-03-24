import {toJSON} from "panda-parchment"
import {Method} from "panda-generics"

Publicize = (library, confidential) ->
  {Directory, PublicDirectory} = library

  publicize = Method.create default: (args...) ->
    throw new Error "panda-capability::publcize -
      no matches on #{toJSON args}"

  Method.define publicize, Directory.isType, (directory) ->
    # Return an instance of PublicDirectory by extracting the grants from input
    output = {}
    for template, methods of directory
      output[template] = {}
      for method, {grant} of methods
        output[template][method] = {grant}

    PublicDirectory.create output

  publicize

export default Publicize
