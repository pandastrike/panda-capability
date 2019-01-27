import {isString, isArray, empty} from "panda-parchment"

allowedMethods = ["HEAD", "OPTIONS", "GET", "PUT", "PATCH", "POST", "DELETE"]
allAllowedMethods = (methods) ->
  return false unless isArray methods
  return false if empty methods
  return false unless method in allowedMethods for method in methods
  true

isUse = (use) ->
  return false unless isArray use
  return false if empty use
  return false for item in use when !(isString item)
  true

export {isUse, allAllowedMethods}
