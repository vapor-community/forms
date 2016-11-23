import Vapor
import Node
import Polymorphic

/**
  A struct which contains a list of fields, each with their validators attached,
  and a list of field names which are required to receive a value for validation.

  Instantiate this struct with your choice of field names and `ValidatableField`
  instances, then call `validate()` with either a `Content` object (from
  `request.data`) or programmatically with a `[String: Node]` dictionary.

  If you have set a `finalValidationBlock`, then this block will be called after
  all fields have been validated. It won't be called if any fields have failed,
  so you can be sure that the data in `values` is clean. Use this closure to check
  any fields which depend on each other, and add to `errors` if the fieldset does
  not pass validation.

  A fieldset which does not pass validation will have the `values` and `errors`
  properties set. A fieldset can also be converted to a `Node` and passed directly
  to a view renderer.

  You can validate any `Content` object, so that means POSTed HTML form data, JSON,
  and GET query string data.

  A fieldset can be simply stored in a variable, but is most powerful when paired
  with a `Form`.

  To validate incoming data, the fieldset pulls the value out of the data structure
  using the field name, so if you are implementing an HTML form, the `name` of your
  inputs should match the field names in your fieldset.
*/
public struct Fieldset {
  // These are the field definitions.
  let fields: [String: ValidatableField]
  // These are the names of the fields that need answers.
  let requiredFieldNames: [String]
  // This block will be called after field validation for whole-fieldset validation.
  let finalValidationBlock: ((inout Fieldset) -> Void)?
  // This is passed-in data for the fields. Can be set manually, or is set at validation.
  // This data is never passed to validate() and is used only for rendering purposes.
  public var values: [String: Node] = [:]
  // These are field validation errors. Set at validation.
  public var errors: FieldErrorCollection = [:]

  public init(_ fields: [String: ValidatableField], requiring requiredFieldNames: [String]=[], finalValidationBlock: ((inout Fieldset) -> Void)?=nil) {
    self.fields = fields
    self.requiredFieldNames = requiredFieldNames
    self.finalValidationBlock = finalValidationBlock
  }

  public mutating func validate(_ content: Content) -> FieldsetValidationResult {
    var validatedData: [String: Node] = [:]
    values = [:]
    errors = [:]
    fields.forEach { fieldName, fieldDefinition in
      // For each field, see if there's a matching value in the Content
      // Fail if no matching value for a required field
      guard let value = content[fieldName] as? Node else {
        if requiredFieldNames.contains(fieldName) {
          errors[fieldName].append(.requiredMissing)
        }
        return
      }
      // Store the passed-in value to be returned later
      values[fieldName] = value
      // Now try to validate it against the field
      switch fieldDefinition.validate(value) {
      case .success(let validatedValue):
        validatedData[fieldName] = validatedValue
      case .failure(let fieldErrors):
        fieldErrors.forEach { errors[fieldName].append($0) } // TODO: allow append a list not individual items
      }
    }
    // Do any whole-form validation if the fields themselves validated fine
    if errors.isEmpty {
      finalValidationBlock?(&self)
    }
    // Now return
    if !errors.isEmpty {
      return .failure
    }
    return .success(validated: validatedData)
  }

  public mutating func validate(_ values: [String: Node]) -> FieldsetValidationResult {
    let content = Content()
    content.append(Node(values))
    return validate(content)
  }

}

extension Fieldset: NodeRepresentable {
  public func makeNode(context: Context) throws -> Node {
    /*
    [
      "name": [
        "label": "Your name",
        "value": "bob",
        "errors: [
          "Name should be longer than 3 characters."
      ],
    ]
    */
    var object: [String: Node] = [:]
    fields.forEach { fieldName, fieldDefinition in
      var fieldNode: [String: Node] = [
        "label": Node(fieldDefinition.label),
      ]
      if let value = values[fieldName] {
        fieldNode["value"] = value
      }
      let fieldErrors = errors[fieldName]
      if !fieldErrors.isEmpty {
        fieldNode["errors"] = Node(fieldErrors.map { Node($0.localizedDescription) })
      }
      object[fieldName] = Node(fieldNode)
    }
    return Node(object)
  }
}
