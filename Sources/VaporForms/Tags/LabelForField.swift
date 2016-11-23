import Leaf

public final class LabelForField: BasicTag {
  public let name = "labelForField"

  // Arg1: Fieldset
  // Arg2: Field name
  public func run(arguments: [Argument]) throws -> Node? {
    guard
      arguments.count == 2,
      let fieldset = arguments[0].value?.nodeObject,
      let fieldName = arguments[1].value?.string,
      let label = fieldset[fieldName]?["label"]
    else { return nil }
    print("label is \(label)")
    return label
  }
}
