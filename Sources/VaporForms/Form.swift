import Vapor

// TODO: Consider using Mirror to ensure that fields match properties on the Form.
// Downside, what if you want to transform from the Field to the property? Or if there's
// no matching property? Also Mirror can be a real performance hit.

public protocol Form {
  static var fields: Fieldset { get }
  init(validated: [String: Node]) throws
}

public extension Form {

  public static func validating(_ data: [String: Node]) throws -> FormValidationResult {
    let content = Content()
    content.append(Node(data))
    return try validating(content)
  }

  public static func validating(_ content: Content) throws -> FormValidationResult {
    switch Self.fields.validate(content) {
    case .failure(let errors, let invalidData):
      return .failure(errors, invalidData)
    case .success(let validData):
      return .success(try Self(validated: validData))
    }
  }

}
