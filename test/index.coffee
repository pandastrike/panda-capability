import "source-map-support/register"
import {print, test} from "amen"

import Tests from "./tests"

# local HTTP server that serves public keys encoded as base64 strings so the verify flow can use a real localhost URL.
import AuthorityServer from "./authority-server"

do ->
  server = AuthorityServer.start()

  try
    await print await test "Panda Capability", [
      test "Authorities", [
        test
          description: "Literal Key"
          wait: false,
          Tests.Authorities.literal

        test
          description: "URL Web Signature"
          wait: false,
          Tests.Authorities.url

        # test
        #   description: "URL-Template Web Signature"
        #   wait: false,
        #   Authorities.template
      ]
    ]

    server.close()

  catch
    server.close()
