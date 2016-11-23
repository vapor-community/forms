import Foundation
import Vapor

extension String {

  /**
    Validates that the number of characters in the value is greater than or equal to a constraint.
  */
  public class MinimumLengthValidator: FieldValidator<String> {
    let characters: Int
    let message: String?
    public init(characters: Int, message: String?=nil) {
      self.characters = characters
      self.message = message
    }
    override public func validate(input value: String) -> FieldValidationResult {
      if value.characters.count < characters {
        return .failure([.validationFailed(message: message ?? "String must be at least \(characters) characters long.")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the number of characters in the value is less than or equal to a constraint.
  */
  public class MaximumLengthValidator: FieldValidator<String> {
    let characters: Int
    let message: String?
    public init(characters: Int, message: String?=nil) {
      self.characters = characters
      self.message = message
    }
    override public func validate(input value: String) -> FieldValidationResult {
      if value.characters.count > characters {
        return .failure([.validationFailed(message: message ?? "String must be at most \(characters) characters long.")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the number of characters in the value is equal to a constraint.
  */
  public class ExactLengthValidator: FieldValidator<String> {
    let characters: Int
    let message: String?
    public init(characters: Int, message: String?=nil) {
      self.characters = characters
      self.message = message
    }
    override public func validate(input value: String) -> FieldValidationResult {
      if value.characters.count != characters {
        return .failure([.validationFailed(message: message ?? "String must be exactly \(characters) characters long.")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the the value is a valid email address string. Does not
    validate that this email address actually exists, just that it is formatted
    correctly.
  */
  public class EmailValidator: FieldValidator<String> {
    let message: String?
    public init(message: String?=nil) {
      self.message = message
    }
    override public func validate(input value: String) -> FieldValidationResult {
      do {
        try Email.validate(input: value)
      } catch {
        return .failure([.validationFailed(message: message ?? "Enter a valid email address.")])
      }
      return .success(Node(value))
    }
  }

}
