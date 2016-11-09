import Node

extension Double {

  /**
    Validates that the value is greater than or equal to a constraint.
  */
  public class MinimumValidator: FieldValidator<Double> {
    let constraint: Double
    public init(_ constraint: Double) {
      self.constraint = constraint
    }
    public override func validate(input value: Double) -> FieldValidationResult {
      if value < constraint {
        return .failure([.validationFailed(message: "Value must be at least \(constraint).")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the value is less than or equal to a constraint.
  */
  public class MaximumValidator: FieldValidator<Double> {
    let constraint: Double
    public init(_ constraint: Double) {
      self.constraint = constraint
    }
    public override func validate(input value: Double) -> FieldValidationResult {
      if value > constraint {
        return .failure([.validationFailed(message: "Value must be at most \(constraint).")])
      }
      return .success(Node(value))
    }
  }

  /**
    Validates that the value is equal to a constraint.
  */
  public class ExactValidator: FieldValidator<Double> {
    let constraint: Double
    public init(_ constraint: Double) {
      self.constraint = constraint
    }
    public override func validate(input value: Double) -> FieldValidationResult {
      if value != constraint {
        return .failure([.validationFailed(message: "Value must be exactly \(constraint).")])
      }
      return .success(Node(value))
    }
  }

}
