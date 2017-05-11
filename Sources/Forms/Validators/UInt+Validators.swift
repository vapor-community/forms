import Node

extension UInt {

  /**
    Validates that the value is greater than or equal to a constraint.
  */
  public class MinimumValidator: FieldValidator<UInt> {
    let constraint: UInt
    let message: String?
    public init(_ constraint: UInt, message: String?=nil) {
      self.constraint = constraint
      self.message = message
    }
    public override func validate(input value: UInt) -> FieldValidationResult {
      if value < constraint {
        return .failure([.validationFailed(message: message ?? "Value must be at least \(constraint).")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the value is less than or equal to a constraint.
  */
  public class MaximumValidator: FieldValidator<UInt> {
    let constraint: UInt
    let message: String?
    public init(_ constraint: UInt, message: String?=nil) {
      self.constraint = constraint
      self.message = message
    }
    public override func validate(input value: UInt) -> FieldValidationResult {
      if value > constraint {
        return .failure([.validationFailed(message: message ?? "Value must be at most \(constraint).")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the value is equal to a constraint.
  */
  public class ExactValidator: FieldValidator<UInt> {
    let constraint: UInt
    let message: String?
    public init(_ constraint: UInt, message: String?=nil) {
      self.constraint = constraint
      self.message = message
    }
    public override func validate(input value: UInt) -> FieldValidationResult {
      if value != constraint {
        return .failure([.validationFailed(message: message ?? "Value must be exactly \(constraint).")])
      }
      return .success(Node(value))
    }
  }

}
