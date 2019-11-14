schema =
  type: "object"
  additionalProperties: false
  required: ["grant", "methods", "claimant", "delegate"]
  properties:
    grant:
      description: "The SHA-512 hash of the stringified grant from this contract. The hash is given as a base64 string. This affirms the association of the delegation to this contract."
      type: "string"

    template:
      description: "Optional.  When a claimant delegates a fixed URL, rather than a more permissive URL template, they may narrow the original grant by binding URL template parameters here. Specified as a dictionary of parameter names and values. Partial binding is not allowed."
      type: "object"

    methods:
      description: "The set of HTTP methods delegated to the delegate. Must be the set or subset of methods granted by the issuer or previous claimant."
      type: "array"
      minLength: 1
      items:
        type: "string"
        enum: ["GET", "PUT", "DELETE", "PATCH", "POST", "OPTIONS"]

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
      ]

    revocation:
      description: "Optional. Describes the claimant's revocation authority. When a claimant delegates a grant to a delegate, this authority gives them the power to revoke the delegation without rotating their primary signature key. The delegation is co-signed with this authority (alongside the claimant's authority). May be one of: a key literal, a URL reference."
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

         type: "object"
         additionalProperties: false
         required: ["template"]
         properties:
           template:
             description: "A URL template describing the possible resources containing the delegate's public signing key. This authority is bound in the claim during the exercise or delegation flows."
             type: "string"
      ]


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

         type: "object"
         additionalProperties: false
         required: ["template"]
         properties:
           template:
             description: "A URL template describing the possible resources containing the delegate's public signing key. This authority is bound in the claim during the exercise or delegation flows."
             type: "string"
      ]

export default schema
