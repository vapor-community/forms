import Node

extension Int {

  /**
    Validates that the value is greater than or equal to a constraint.
  */
  public class MinimumValidator: FieldValidator<Int> {
    let constraint: Int
    let message: String?
    public init(_ constraint: Int, message: String?=nil) {
      self.constraint = constraint
      self.message = message
    }
    public override func validate(input value: Int) -> FieldValidationResult {
      if value < constraint {
        return .failure([.validationFailed(message: message ?? "Value must be at least \(constraint).")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the value is less than or equal to a constraint.
  */
  public class MaximumValidator: FieldValidator<Int> {
    let constraint: Int
    let message: String?
    public init(_ constraint: Int, message: String?=nil) {
      self.constraint = constraint
      self.message = message
    }
    public override func validate(input value: Int) -> FieldValidationResult {
      if value > constraint {
        return .failure([.validationFailed(message: message ?? "Value must be at most \(constraint).")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the value is equal to a constraint.
  */
  public class ExactValidator: FieldValidator<Int> {
    let constraint: Int
    let message: String?
    public init(_ constraint: Int, message: String?=nil) {
      self.constraint = constraint
      self.message = message
    }
    public override func validate(input value: Int) -> FieldValidationResult {
      if value != constraint {
        return .failure([.validationFailed(message: message ?? "Value must be exactly \(constraint).")])
      }
      return .success(Node(value))
    }
  }

}
