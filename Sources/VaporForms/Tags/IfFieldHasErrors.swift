import Leaf

public final class IfFieldHasErrors: Tag {
  public let name = "ifFieldHasErrors"
  
  public func run(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument]) throws -> Node? {
    return nil
  }
  
  // Arg1: Fieldset
  // Arg2: Field name
  // Render if there are errors in the field's errors array
  public func shouldRender(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument], value: Node?) -> Bool {
    guard
      arguments.count == 2,
      let fieldset = arguments[0].value?.nodeObject,
      let fieldName = arguments[1].value?.string,
      let errors = fieldset[fieldName]?["errors"]?.nodeArray
    else { return false }
    return !errors.isEmpty
  }

}
