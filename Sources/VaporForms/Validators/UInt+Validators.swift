import Foundation

extension UInt {

  public class MinimumValidator: FieldValidator<UInt> {
    let constraint: UInt
    public init(_ constraint: UInt) {
      self.constraint = constraint
    }
    public override func validate(input value: UInt) -> FieldValidationResult {
      if value < constraint {
        return .failure([.validationFailed(message: "Value must be at least \(constraint).")])
      }
      return .success
    }
  }

  public class MaximumValidator: FieldValidator<UInt> {
    let constraint: UInt
    public init(_ constraint: UInt) {
      self.constraint = constraint
    }
    public override func validate(input value: UInt) -> FieldValidationResult {
      if value > constraint {
        return .failure([.validationFailed(message: "Value must be at most \(constraint).")])
      }
      return .success
    }
  }

  public class ExactValidator: FieldValidator<UInt> {
    let constraint: UInt
    public init(_ constraint: UInt) {
      self.constraint = constraint
    }
    public override func validate(input value: UInt) -> FieldValidationResult {
      if value != constraint {
        return .failure([.validationFailed(message: "Value must be exactly \(constraint).")])
      }
      return .success
    }
  }

}
