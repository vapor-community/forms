import Leaf

public final class ErrorsForField: BasicTag {
    public let name = "errorsForField"
    
    // Arg1: Fieldset
    // Arg2: Field name
    public func run(arguments: ArgumentList) throws -> Node? {
        guard
            arguments.count == 2,
            let fieldset = arguments[0]?.object,
            let fieldName = arguments[1]?.string,
            let errors = fieldset[fieldName]?["errors"]
            else { return nil }
        return errors
    }
}
