import Leaf

public final class ValueForField: BasicTag {
  public let name = "valueForField"
  
  // Arg1: Fieldset
  // Arg2: Field name
  public func run(arguments: [Argument]) throws -> Node? {
    guard
      arguments.count == 2,
      let fieldset = arguments[0].value?.nodeObject,
      let fieldName = arguments[1].value?.string,
      let value = fieldset[fieldName]?["value"]
      else { return nil }
    return value
  }
}
