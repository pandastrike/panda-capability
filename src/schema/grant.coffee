schema =
  type: "object"
  additionalProperties: false
  required: ["template", "methods", "tolerance", "issuer", "claimant"]
  properties:

    template:
      description: "The URL template that describes the resources this capability grants to the claimant."
      type: "string"
      format: "uri-template"

    methods:
      description: "The set of HTTP methods this capability allows the claimant to use on this resource."
      type: "array"
      minItems: 1
      items:
        type: "string"
        enum: ["GET", "PUT", "DELETE", "PATCH", "POST", "OPTIONS"]

    tolerance:
      description: "Mitigates potential replay attacks by describing the window of time a claim on a grant will be accepted after being signed. The server time is compared with this tolernce and the claim's timetamp."
      oneOf: [
          type: "object"
          additionalProperties: false
          required: ["seconds"]
          properties:
            seconds:
              description: "The size, in seconds, of this tolerence window."
              type: "integer"
              minimum: 1
        ,
          type: "object"
          additionalProperties: false
          required: ["minutes"]
          properties:
            minutes:
              description: "The size, in minutes, of this tolerence window."
              type: "integer"
              minimum: 1
      ]

    expires:
      description: "Optional. Describes the datetime at which this grant expires. Therefore, this field allows the issuer to issue grants that self-revoke at an arbitrarily specified time in the future. Given as an ISO 8601 timestamp."
      type: "string"
      format: "date-time"

    issuer:
      description: "Describes the authority issuing the grant. May be either  a key literal or a URL reference."
      oneOf: [
          type: "object"
          additionalProperties: false
          required: ["literal"]
          properties:
            literal:
              description: "The literal public signature key of the issuer authority, given as a base64 encoded string."
              type: "string"
        ,
          type: "object"
          additionalProperties: false
          required: ["url"]
          properties:
            url:
              description: "A URL where one may find the public signature key for the issuer authority for validation."
              type: "string"
              format: "uri"
      ]

    revocations:
      description: "Optional. List that describes the issuer's revocation authorities. When a issuing a grant, these authorities give the issuer the power to revoke the grant without rotating their primary signature key. The grant is co-signed with these authorities (alongside the issuer's authority)."
      type: "array"
      minItems: 1
      items:
        type: "object"
        additionalProperties: false
        required: ["url"]
        properties:
          url:
            description: "A URL where one may find the public signature key for the issuer authority for validation."
            type: "string"
            format: "uri"

    claimant:
      description: "Describes the claimant authority, given privilege to excercise the grant. May be one of: a key literal, a URL reference, a URL template with enumerated parameter names."
      oneOf: [
          type: "object"
          additionalProperties: false
          required: ["literal"]
          properties:
            literal:
              description: "The literal public signature key of the claimant authority, given as a base64 encoded string."
              type: "string"
        ,
          type: "object"
          additionalProperties: false
          required: ["url"]
          properties:
            url:
              description: "A URL where one may find the public signature key for the claimant authority for validation."
              type: "string"
              format: "uri"
        ,
         type: "object"
         additionalProperties: false
         required: ["template"]
         properties:
           template:
             description: "A URL template describing the possible resources containing the claimant's public signing key. This authority is bound in the claim during the exercise flow."
             type: "string"
             format: "uri-template"
      ]

export default schema
