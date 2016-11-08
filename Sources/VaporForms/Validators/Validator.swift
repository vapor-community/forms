import Node

public class FieldValidator<T> {
  public func validate(input value: T) -> FieldValidationResult {
    return .success(Node(nil))
  }
}
