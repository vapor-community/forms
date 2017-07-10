import Leaf

public final class ValueForField: BasicTag {
    public let name = "valueForField"
    
    // Arg1: Fieldset
    // Arg2: Field name
    public func run(arguments: ArgumentList) throws -> Node? {
        guard
            arguments.count == 2,
            let fieldset = arguments[0]?.object,
            let fieldName = arguments[1]?.string,
            let value = fieldset[fieldName]?["value"]
            else { return nil }
        return value
    }
}
