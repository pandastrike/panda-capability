import {isString, isArray, empty} from "panda-parchment"

allowedMethods = ["HEAD", "OPTIONS", "GET", "PUT", "PATCH", "POST", "DELETE"]
allAllowedMethods = (methods) ->
  return false unless isArray methods
  return false if empty use
  return false if method not in allowedMethods for method in methods
  true

isUse = (use) ->
  return false unless isArray array
  return false if empty use
  return false for item in array when (!isString item)
  true

export {isUse, allAllowedMethods}
