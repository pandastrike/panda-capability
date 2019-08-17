import {toJSON} from "panda-parchment"
import Method from "panda-generics"

Publicize = (library, confidential) ->
  {Directory, PublicDirectory} = library

  publicize = Method.create
    name: "publicize"
    description: "Converts a given Directory into a PublicDirectory that's
      safe to share."

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
