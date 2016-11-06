import Foundation

public class FieldValidator<T> {
  public func validate(input value: T) -> FieldValidationResult {
    return .success
  }
}
