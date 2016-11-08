import Node

extension Double {

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
