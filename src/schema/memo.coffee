schema =
  type: "object"
  additionalProperties: false
  required: ["integrity", "body"]
  properties:

    integrity:
      description: "The SHA-512 hash of this memo's stringified body and a secret known only to the issuer. Given as a base64 encoded string. This hash ensures a validator may honor the claim against the memoized grant without fear of tampering."
      type: "string"

    content:
      description: "The description of the grant this memo stands for. Includes information about the resource to be accessed, how it may be accessed, and when the temporary authority this bearer credential represents expires."
      type: "object"
      additionalProperties: false
      required: ["resource", "methods", "expires"]
      properties:

        resource:
          description: "Describes the resource this memo authorizes. It may be specified narrowly as a URL or as a URL template that will authorize against multiple resources."
          oneOf: [
            type: "object"
            additionalProperties: false
            required: ["url"]
            properties:
              url:
                description: "A URL that the memo authorizes against. This form accepts no parameters and is limited to exactly the URL specified."
                type: "string"
                format: "uri"
          ,
            type: "object"
            additionalProperties: false
            required: ["template"]
            properties:
              template:
                description: "A URL template describing the possible resources this memo authorizes against. Parameters are specified in the memo's claim."
                type: "string"
                format: "uri-template"
          ]

        methods:
          description: "The set of HTTP methods this memo authorizes against the resource for the memo's bearer."
          type: "array"
          minItems: 1
          items:
            type: "string"
            enum: ["GET", "PUT", "DELETE", "PATCH", "POST", "OPTIONS"]

        expires:
          description: "Describes the datetime at which this memo expires. Given as an ISO 8601 timestamp."
          type: "string"
          format: "date-time"


    claim:
      description: "Describes parameters of the request as needed to fulfill the memo's contstraints."
      type: "object"
      additionalProperties: false
      properties:
        template:
          type: "object"
          description: "When a memo is used to authorize group of resources with a URL template, these parameters are required to fulfill that constriant on the bearer credential. The resultant URL must match the resource URL when validated."


export default schema
