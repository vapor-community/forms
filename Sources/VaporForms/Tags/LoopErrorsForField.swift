import Leaf

public final class LoopErrorsForField: Tag {
  public let name = "loopErrorsForField"
  
  // Arg1: Fieldset
  // Arg2: Field name
  // Arg3: Constant name in loop
  // Render for each error message in field's error message array.
  public func run(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument]) throws -> Node? {
    guard
      arguments.count == 3,
      let fieldset = arguments[0].value?.nodeObject,
      let fieldName = arguments[1].value?.string,
      let constant = arguments[2].value?.string,
      let errors = fieldset[fieldName]?["errors"]?.nodeArray
    else { return nil }
    return .array(errors.map { [constant: $0] })
  }
  
  public func render(stem: Stem, context: Context, value: Node?, leaf: Leaf) throws -> Bytes {
    guard let array = value?.nodeArray else { return "".bytes }
    func renderItem(_ item: Node) throws -> Bytes {
      context.push(item)
      let rendered = try stem.render(leaf, with: context)
      context.pop()
      return rendered
    }
    return try array
      .map(renderItem)
      .flatMap { $0 + [.newLine] }
  }

}
