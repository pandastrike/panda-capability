import {isType, toJSON, fromJSON, isDefined, include} from "panda-parchment"
import {Method} from "panda-generics"

assert = (predicate, message) ->
  throw new Error "challenge failure: #{message}" unless predicate


Container = (library, confidential) ->
  {convert, verify, Declaration} = confidential

  _from = Method.create default: (args...) ->
    throw new Error "panda-capability::Assertion::from -
      no matches on #{toJSON args}"

  Method.define _from, Declaration.isType,
    (declaration) -> new Assertion declaration

  Method.define _from, isString, isDefined,
    (hint, value) -> new Assertion Declaration.from hint, value


  class Assertion
    constructor: (assertion) -> include @, assertion

    # Validates the internal consistency of the assertion,
    # while also adding unpacked properties
    verify: ->
      [useKey, clientKey] = (key.to "base64" for key in @signatories)
      {@parameters, declaration} = fromJSON @data.to "utf8"

      declaration = Declaration.from "base64", declaration
      issuerKey = declaration.signatories[0].to "base64"
      @publicKeys = {useKey, clientKey, issuerKey}
      @capability = fromJSON declaration.data.to "utf8"

      assert (verify @), "client signature is invalid"
      assert (verify declaration), "issuer signature is invalid"
      assert useKey? && clientKey?, "client or use key is not present"
      assert @capability.use[0] == useKey, "use key is invalid"
      assert @capability.recipient == clientKey, "client key is invalid"
      true

    @from: _from

    @isType: isType @

export default Container
