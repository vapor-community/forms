import Vapor
import Node

public enum FieldError: Error {
  // Value did not pass validation. Message should be displayed to users.
  case validationFailed(message: String)
  // A required value was not included.
  case requiredMissing
  // A Form was passed validated data which was incomplete
  case invalidValidatedData

  public var localizedDescription: String {
    switch self {
    case .validationFailed(let message):
      return message
    case .requiredMissing:
      return "This field is required."
    case .invalidValidatedData:
      return "Invalid validated data."
    }
  }
  
}

public struct FieldErrorCollection: Error, ExpressibleByDictionaryLiteral, NodeRepresentable {
  public typealias Key = String
  public typealias Value = [FieldError]

  private var contents: [Key: Value]

  // ["key": [error1, error2]]
  // ["key": [error1], "key": [error2]]
  public init(dictionaryLiteral elements: (Key, Value)...) {
    contents = [:]
    for (key, value) in elements {
      self[key] += value
    }
  }

  // errors["key"].append(error1)
  // errors["key"].append(error2)
  public subscript (key: Key) -> Value {
    get {
      return contents[key] ?? []
    }
    set {
      contents[key] = newValue
    }
  }

  public var isEmpty: Bool {
    return contents.isEmpty
  }
  
  public func makeNode(context: Context) throws -> Node {
    var nodeObject: [String: Node] = [:]
    contents.forEach { key, value in
      nodeObject[key] = Node(value.map { Node($0.localizedDescription) })
    }
    return Node(nodeObject)
  }

}
