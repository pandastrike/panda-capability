import {isString, isDefined, isType, toJSON, fromJSON, include} from "panda-parchment"
import {Method} from "panda-generics"

assert = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate


Container = (library, confidential) ->
  {convert, verify, Declaration} = confidential

  toBase64 = (bytes) -> convert from:"bytes", to:"base64", bytes
  toUTF8 = (bytes) -> convert from:"bytes", to:"utf8", bytes

  extractKeys = ({signatories}) -> toBase64 key for key in signatories
  extractDocument = ({data}) -> fromJSON toUTF8 data

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

    # Validates internal consistency of assertion; adds unpacked properties
    verify: ->
      [useKey, clientKey] = extractKeys @declaration
      {@parameters, issuerDeclaration} = extractDocument @declaration

      issuerDeclaration = Declaration.from "base64", issuerDeclaration
      @capability = extractDocument issuerDeclaration
      [issuerKey] = extractKeys issuerDeclaration

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
