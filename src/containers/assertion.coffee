import {isString, isDefined, isType, toJSON, fromJSON, include} from "panda-parchment"
import {Method} from "panda-generics"

assert = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate


Container = (library, confidential) ->
  {convert, verify, Declaration} = confidential

  toBase64 = (bytes) -> convert from:"bytes", to:"base64", bytes
  toUTF8 = (bytes) -> convert from:"bytes", to:"utf8", bytes

  _from = Method.create default: (args...) ->
    throw new Error "panda-capability::Assertion::from -
      no matches on #{toJSON args}"

  Method.define _from, Declaration.isType,
    (declaration) -> new Assertion declaration

  Method.define _from, isString, isDefined,
    (hint, value) -> new Assertion Declaration.from hint, value


  class Assertion
    constructor: (@declaration) ->

    to: (hint) -> @declaration.to hint

    # Validates the internal consistency of the assertion,
    # while also adding unpacked properties
    verify: ->
      {signatories, data} = @declaration

      [useKey, clientKey] = (toBase64 key for key in signatories)

      {@parameters, declaration} = fromJSON toUTF8 data
      issuerDeclaration = Declaration.from "base64", declaration
      @capability = fromJSON toUTF8 issuerDeclaration.data
      issuerKey = toBase64 issuerDeclaration.signatories[0]

      @publicKeys = {useKey, clientKey, issuerKey}

      assert (verify @declaration), "client signature is invalid"
      assert (verify issuerDeclaration), "issuer signature is invalid"
      assert useKey? && clientKey?, "client or use key is not present"
      assert @capability.use[0] == useKey, "use key is invalid"
      assert @capability.recipient == clientKey, "client key is invalid"
      true

    @from: _from

    @isType: isType @

export default Container
