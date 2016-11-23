import Vapor
import Node

/**
  A Form did not pass validation; this data structure contains information
  about the failed validation and can be returned to a View for rendering.
*/
public struct InvalidForm {
  /**
  A keyed collection of fields and their errors, where the key is the field
  name and the value is an array of errors raised during that field's validation
  phase.
  */
  let errors: FieldErrorCollection
  /**
  The second associated value is the dictionary of values which were validated
  against. You can use this dictionary when re-rendering your HTML form to
  pre-fill the fields with the user's invalid input.
  */
  let values: [String: Node]
}

extension InvalidForm: NodeRepresentable {
  public func makeNode(context: Context) throws -> Node {
    return Node([
      "errors": try errors.makeNode(),
      "values": Node(values)
    ])
  }
}
