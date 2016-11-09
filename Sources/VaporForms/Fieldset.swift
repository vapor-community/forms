import Vapor
import Node
import Polymorphic

/**
  A struct which contains a list of fields, each with their validators attached,
  and a list of field names which are required to receive a value for validation.

  Instantiate this struct with your choice of field names and `ValidatableField`
  instances, then call `validate()` with either a `Content` object (from
  `request.data`) or programmatically with a `[String: Node]` dictionary.

  You can validate any `Content` object, so that means POSTed HTML form data, JSON,
  and GET query string data.

  A fieldset can be simply stored in a variable, but is most powerful when paired
  with a `Form`.

  To validate incoming data, the fieldset pulls the value out of the data structure
  using the field name, so if you are implementing an HTML form, the `name` of your
  inputs should match the field names in your fieldset.
*/
public struct Fieldset {
  let fields: [String: ValidatableField]
  let requiredFieldNames: [String]

  public init(_ fields: [String: ValidatableField], requiring requiredFieldNames: [String]=[]) {
    self.fields = fields
    self.requiredFieldNames = requiredFieldNames
  }

  public func validate(_ content: Content) -> FieldsetValidationResult {
    var validatedData: [String: Node] = [:]
    var inData: [String: Node] = [:]
    var errors: FieldErrorCollection = [:]
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
      inData[fieldName] = value
      // Now try to validate it against the field
      switch fieldDefinition.validate(value) {
      case .success(let validatedValue):
        validatedData[fieldName] = validatedValue
      case .failure(let fieldErrors):
        fieldErrors.forEach { errors[fieldName].append($0) } // TODO: allow append a list not individual items
      }
    }
    if !errors.isEmpty {
      return .failure(errors, inData)
    }
    return .success(validatedData)
  }

  public func validate(_ data: [String: Node]) -> FieldsetValidationResult {
    let content = Content()
    content.append(Node(data))
    return validate(content)
  }

}
