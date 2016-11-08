import Foundation
import Vapor

extension String {

  public class MinimumLengthValidator: FieldValidator<String> {
    let characters: Int
    public init(characters: Int) {
      self.characters = characters
    }
    override public func validate(input value: String) -> FieldValidationResult {
      if value.characters.count < characters {
        return .failure([.validationFailed(message: "String must be at least \(characters) characters long.")])
      }
      return .success(Node(value))
    }
  }

  public class MaximumLengthValidator: FieldValidator<String> {
    let characters: Int
    public init(characters: Int) {
      self.characters = characters
    }
    override public func validate(input value: String) -> FieldValidationResult {
      if value.characters.count > characters {
        return .failure([.validationFailed(message: "String must be at most \(characters) characters long.")])
      }
      return .success(Node(value))
    }
  }

  public class ExactLengthValidator: FieldValidator<String> {
    let characters: Int
    public init(characters: Int) {
      self.characters = characters
    }
    override public func validate(input value: String) -> FieldValidationResult {
      if value.characters.count != characters {
        return .failure([.validationFailed(message: "String must be exactly \(characters) characters long.")])
      }
      return .success(Node(value))
    }
  }

  public class EmailValidator: FieldValidator<String> {
    override public init() {}
    override public func validate(input value: String) -> FieldValidationResult {
      do {
        try Email.validate(input: value)
      } catch {
        return .failure([.validationFailed(message: "Enter a valid email address.")])
      }
      return .success(Node(value))
    }
  }

}
