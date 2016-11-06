import Foundation

extension Int {

  public class MinimumValidator: FieldValidator<Int> {
    let constraint: Int
    public init(_ constraint: Int) {
      self.constraint = constraint
    }
    public override func validate(input value: Int) -> FieldValidationResult {
      if value < constraint {
        return .failure([.validationFailed(message: "Value must be at least \(constraint).")])
      }
      return .success
    }
  }

  public class MaximumValidator: FieldValidator<Int> {
    let constraint: Int
    public init(_ constraint: Int) {
      self.constraint = constraint
    }
    public override func validate(input value: Int) -> FieldValidationResult {
      if value > constraint {
        return .failure([.validationFailed(message: "Value must be at most \(constraint).")])
      }
      return .success
    }
  }

  public class ExactValidator: FieldValidator<Int> {
    let constraint: Int
    public init(_ constraint: Int) {
      self.constraint = constraint
    }
    public override func validate(input value: Int) -> FieldValidationResult {
      if value != constraint {
        return .failure([.validationFailed(message: "Value must be exactly \(constraint).")])
      }
      return .success
    }
  }

}
