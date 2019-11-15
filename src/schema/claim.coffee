schema =
  type: "object"
  additionalProperties: false
  required: ["method", "timestamp", "claimant"]
  properties:
    template:
      description: "Optional. Binds values to the URL template from the grant. Values are listed in a dictionary with parameter names."
      type: "object"
    method:
      description: "Binds the HTTP method the claimant wishes to execute."
      type: "string"
      enum: ["GET", "PUT", "DELETE", "PATCH", "POST", "OPTIONS"]
    timestamp:
      description: "Binds the current time, given as ISO 8601. Used in conjunction with the grant's tolerance property during validation."
      type: "string"
      format: "date-time"
    claimant:
      description: "Binds the claimant authority, given privilege to excercise the grant. May be one of: a key literal, a URL reference, or parameters to bind a URL template.  This must correspond to the type of claimant authority specified in the grant."
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
        ,
          type: "object"
          additionalProperties: false
          required: ["parameters"]
          properties:
            template:
              description: "A dictionary of parameters and their values. These bind to the URL template specified in the grant. The resultant URL must respond with the claimant's public signature key matching this claim."
              type: "string"
      ]


export default schema
