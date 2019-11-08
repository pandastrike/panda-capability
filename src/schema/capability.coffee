schema =
  type: "array"
  items:
    type: "object"
    additionalProperties: false
    required: ["template", "methods"]
    properties:
      template:
        description: "The URL template that describes the family of resources this capability grants to the recipient."
        type: "string"
        format: "uri-template"
      methods:
        description: "The set of HTTP methods this capability allows the recipient to use on this resource."
        type: "array"
        items:
          type: "string"
          enum: ["GET", "PUT", "DELETE", "PATCH", "POST", "OPTIONS"]
      constraints:
        description: "A list of constraints on the grant that can flexibly provide third party validity checks.  Must have a name and type fields as a label, but are otherwise free to accommodate multiple types of constraints."
        type: "array"
        items:
          type: "object"
          required: ["name", "type"]
          properties:
            name:
              description: "A label for this constraint"
              type: "string"
            type:
              description: "The name for the type of constraint, which must be recognized by the ultimate validator"
              type: "string"

export default schema
