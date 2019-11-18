import Method from "panda-generics"

Bundle = (library, confidential) ->
  {Directory, Contract} = library

  bundle = Method.create
    name: "bundle"
    description: "Bundles and array of Contracts into a Directory, with duplicates for each method on a given resource."

  Method.define bundle, Contract.areType, (contracts) ->

    directory = {}
    for contract in contracts
      {template, methods} = contract

      directory[template] = {}
      for method in methods
        directory[template][method] = Contract.create contract

    Directory.create directory

  bundle

export default Bundle
