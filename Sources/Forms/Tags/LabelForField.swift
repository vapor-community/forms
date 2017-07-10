import Leaf

public final class LabelForField: BasicTag {
    public let name = "labelForField"
    
    public func run(arguments: ArgumentList) throws -> Node? {
        guard
            arguments.count == 2,
            let fieldset = arguments[0]?.object,
            let fieldName = arguments[1]?.string,
            let label = fieldset[fieldName]?["label"]
            else { return nil }
        return label
    }
}
