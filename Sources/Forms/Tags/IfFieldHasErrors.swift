import Leaf

public final class IfFieldHasErrors: Tag {
    public let name = "ifFieldHasErrors"
    
    public func run(tagTemplate: TagTemplate, arguments: ArgumentList) throws -> Node? {
        guard
            arguments.count == 2,
            let fieldset = arguments[0]?.object,
            let fieldName = arguments[1]?.string,
            let errors = fieldset[fieldName]?["errors"]
            else { return nil }
        return errors
    }
    
    public func run(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument]) throws -> Node? {
    return nil
  }
}
