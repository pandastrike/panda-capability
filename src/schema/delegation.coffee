schema =
  type: "object"
  additionalProperties: false
  required: ["integrity", "methods", "claimant", "delegate"]
  properties:
    integrity:
      description: "The SHA-512 hash of the stringified grant and any previous delegations, affirming the association of the delegation with this contract. The hash is given as a base64 string."
      type: "string"

    template:
      description: "Optional.  When a claimant delegates a fixed URL, rather than a more permissive URL template, they may narrow the original grant by binding URL template parameters here. Specified as a dictionary of parameter names and values. Partial binding is not allowed. Therefore, this can only be bound once and all later delegations must abide by the resultant URL."
      type: "object"

    methods:
      description: "The set of HTTP methods delegated to the delegate. Must be the set or subset of methods granted by the issuer or previous claimant."
      type: "array"
      minItems: 1
      items:
        type: "string"
        enum: ["GET", "PUT", "DELETE", "PATCH", "POST", "OPTIONS"]

    expires:
      description: "Optional. Describes the datetime at which this delegation expires. Therefore, this field allows the claimant to provide self-revoking delgations at an arbitrarily specified time in the future. Given as an ISO 8601 timestamp."
      type: "string"
      format: "date-time"

    claimant:
      description: "Describes the claimant authority, from where the delegation authority flows. The delegation is signed with this authority. May be one of: a key literal, a URL reference."
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
              description: "A dictionary of URL template parameters and their values. These bind to the URL template specified for the claimant in either: (1) the grant, if it's the original claimant. (2) or the last delegation description if this is an Nth delegation.  The resultant URL must respond with the claimant's public signature key matching this claim."
              type: "object"
      ]

    revocations:
      description: "Optional. Describes the claimant's revocation authorities. When a claimant delegates a grant to a delegate, these authorities give them the power to revoke the delegation without rotating their primary signature key. The delegation is co-signed with these authorities (alongside the claimant's authority)."
      type: "array"
      minItems: 1
      items:
        type: "object"
        additionalProperties: false
        required: ["url"]
        properties:
          url:
            description: "A URL where one may find the public signature key for the delegate authority for validation."
            type: "string"
            format: "uri"

    delegate:
      description: "Describes the delegate authority, given privilege to excercise the grant by the claimant or previous delegate. May be one of: a key literal, a URL reference, a URL template with enumerated parameter names."
      oneOf: [
          type: "object"
          additionalProperties: false
          required: ["literal"]
          properties:
            literal:
              description: "The literal public signature key of the delegate authority, given as a base64 encoded string."
              type: "string"
        ,
          type: "object"
          additionalProperties: false
          required: ["url"]
          properties:
            url:
              description: "A URL where one may find the public signature key for the delegate authority for validation."
              type: "string"
              format: "uri"
        ,
         type: "object"
         additionalProperties: false
         required: ["template"]
         properties:
           template:
             description: "A URL template describing the possible resources containing the delegate's public signing key. This authority is bound in the claim during the exercise or delegation flows."
             type: "string"
             format: "uri-template"
      ]

export default schema
