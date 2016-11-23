import Foundation
import Vapor
import Leaf

public final class ErrorsForFormInput: BasicTag {
  public let name = "errorsForFormInput"

  public func run(arguments: [Argument]) throws -> Node? {
    guard
      arguments.count == 2,
      let object = arguments[0].value?.nodeObject?["errors"],
      let key = arguments[1].value?.string,
      let value = object[key]
      else { return nil }
    return value
  }
}
