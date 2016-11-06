import Vapor

public protocol ValidatableField {
  func validate(_: Node) -> FieldValidationResult
}

public struct StringField: ValidatableField {
  let validators: [FieldValidator<String>]
  public init(_ validators: FieldValidator<String>...) {
    self.validators = validators
  }
  public func validate(_ value: Node) -> FieldValidationResult {
    guard case .string(let string) = value else { return .failure([.incorrectValueType]) }
    let errors: [FieldError] = validators.reduce([]) { accumulated, validator in
      if case .failure(let errors) = validator.validate(input: string) { return accumulated + errors }
      return accumulated
    }
    return errors.isEmpty ? .success : .failure(errors)
  }
}

public struct IntegerField: ValidatableField {
  let validators: [FieldValidator<Int>]
  public init(_ validators: FieldValidator<Int>...) {
    self.validators = validators
  }
  public func validate(_ value: Node) -> FieldValidationResult {
    guard case .number(let number) = value else { return .failure([.incorrectValueType]) }
    switch number {
    case .double:
      return .failure([.validationFailed(message: "This value should be a whole number.")])
    case .int, .uint:
      break
    }
    guard let int = value.int else { return .failure([.incorrectValueType]) }
    let errors: [FieldError] = validators.reduce([]) { accumulated, validator in
      if case .failure(let errors) = validator.validate(input: int) { return accumulated + errors }
      return accumulated
    }
    return errors.isEmpty ? .success : .failure(errors)
  }
}

public struct UnsignedIntegerField: ValidatableField {
  let validators: [FieldValidator<UInt>]
  public init(_ validators: FieldValidator<UInt>...) {
    self.validators = validators
  }
  public func validate(_ value: Node) -> FieldValidationResult {
    guard case .number(let number) = value else { return .failure([.incorrectValueType]) }
    switch number {
    case .double:
      return .failure([.validationFailed(message: "This value should be a whole number.")])
    case .int(let int) where int < 0:
      return .failure([.validationFailed(message: "This value should be a positive number.")])
    case .int, .uint:
      break
    }
    guard let uint = value.uint else { return .failure([.incorrectValueType]) }
    let errors: [FieldError] = validators.reduce([]) { accumulated, validator in
      if case .failure(let errors) = validator.validate(input: uint) { return accumulated + errors }
      return accumulated
    }
    return errors.isEmpty ? .success : .failure(errors)
  }
}

public struct DoubleField: ValidatableField {
  let validators: [FieldValidator<Double>]
  public init(_ validators: FieldValidator<Double>...) {
    self.validators = validators
  }
  public func validate(_ value: Node) -> FieldValidationResult {
    guard let double = value.double else { return .failure([.incorrectValueType]) }
    let errors: [FieldError] = validators.reduce([]) { accumulated, validator in
      if case .failure(let errors) = validator.validate(input: double) { return accumulated + errors }
      return accumulated
    }
    return errors.isEmpty ? .success : .failure(errors)
  }
}
