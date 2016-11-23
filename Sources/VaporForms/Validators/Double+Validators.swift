import Node

extension Double {

  /**
    Validates that the value is greater than or equal to a constraint.
  */
  public class MinimumValidator: FieldValidator<Double> {
    let constraint: Double
    let message: String?
    public init(_ constraint: Double, message: String?=nil) {
      self.constraint = constraint
      self.message = message
    }
    public override func validate(input value: Double) -> FieldValidationResult {
      if value < constraint {
        return .failure([.validationFailed(message: message ?? "Value must be at least \(constraint).")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the value is less than or equal to a constraint.
  */
  public class MaximumValidator: FieldValidator<Double> {
    let constraint: Double
    let message: String?
    public init(_ constraint: Double, message: String?=nil) {
      self.constraint = constraint
      self.message = message
    }
    public override func validate(input value: Double) -> FieldValidationResult {
      if value > constraint {
        return .failure([.validationFailed(message: message ?? "Value must be at most \(constraint).")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the value is equal to a constraint.
  */
  public class ExactValidator: FieldValidator<Double> {
    let constraint: Double
    let message: String?
    public init(_ constraint: Double, message: String?=nil) {
      self.constraint = constraint
      self.message = message
    }
    public override func validate(input value: Double) -> FieldValidationResult {
      if value != constraint {
        return .failure([.validationFailed(message: message ?? "Value must be exactly \(constraint).")])
      }
      return .success(Node(value))
    }
  }

}
