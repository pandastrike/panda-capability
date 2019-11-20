import {resolve} from "path"
import http from "http"
import serveStatic from "serve-static"
import finalhandler from "finalhandler"

# Create server that pulls from the local key registry.
# TODO: P9K's preset compiles the tests in build, but the fixture keys are still in test uncompiled. Either format the registry as coffeescript, or change how the preset is being used.
start = ->
  root = resolve __dirname, "..", "..", "..", "test", "authority-fixture"
  serve = serveStatic root

  server = http.createServer (req, res) ->
    serve req, res, finalhandler req, res
  server.listen 8000
  server

export default {start}
