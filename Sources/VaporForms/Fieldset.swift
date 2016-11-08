import Vapor
import Node
import Polymorphic

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
