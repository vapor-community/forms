import Vapor

/**
  A field which is able to validate a value.
  Adopt this protocol to be able to be included in a `Fieldset`.
*/
public protocol ValidatableField {
  func validate(_: Node) -> FieldValidationResult
}

/**
  A field which can receive a `String` value and optionally validate it before
  returning a `FieldValidationResult`.
*/
public struct StringField: ValidatableField {
  let validators: [FieldValidator<String>]
  public init(_ validators: FieldValidator<String>...) {
    self.validators = validators
  }
  public func validate(_ value: Node) -> FieldValidationResult {
    // In theory, this shouldn't ever really fail
    guard let string = value.string else {
      return .failure([.validationFailed(message: "Please enter valid text.")])
    }
    let errors: [FieldError] = validators.reduce([]) { accumulated, validator in
      if case .failure(let errors) = validator.validate(input: string) { return accumulated + errors }
      return accumulated
    }
    return errors.isEmpty ? .success(Node(string)) : .failure(errors)
  }
}

/**
  A field which can receive an `Int` value and optionally validate it before
  returning a `FieldValidationResult`.
*/
public struct IntegerField: ValidatableField {
  let validators: [FieldValidator<Int>]
  public init(_ validators: FieldValidator<Int>...) {
    self.validators = validators
  }
  public func validate(_ value: Node) -> FieldValidationResult {
    // Retrieving value.int, if value is a Double, will force-convert it to an Int which is
    // not what we want so we have to filter out all Doubles first.
    // This has the unfortunate side-effect of excluding any Doubles which are in fact whole numbers.
    if case .number(let number) = value, case .double = number {
      return .failure([.validationFailed(message: "Please enter a whole number.")])
    }
    guard let int = value.int else {
      return .failure([.validationFailed(message: "Please enter a whole number.")])
    }
    let errors: [FieldError] = validators.reduce([]) { accumulated, validator in
      if case .failure(let errors) = validator.validate(input: int) { return accumulated + errors }
      return accumulated
    }
    return errors.isEmpty ? .success(Node(int)) : .failure(errors)
  }
}

/**
  A field which can receive a `UInt` value and optionally validate it before
  returning a `FieldValidationResult`.
*/
public struct UnsignedIntegerField: ValidatableField {
  let validators: [FieldValidator<UInt>]
  public init(_ validators: FieldValidator<UInt>...) {
    self.validators = validators
  }
  public func validate(_ value: Node) -> FieldValidationResult {
    // Filter out Doubles (see comments in IntegerField) and negative Ints first.
    if case .number(let number) = value, case .double = number {
      return .failure([.validationFailed(message: "Please enter a positive whole number.")])
    }
    if case .number(let number) = value, case .int(let int) = number, int < 0 {
      return .failure([.validationFailed(message: "Please enter a positive whole number.")])
    }
    guard let uint = value.uint else {
      return .failure([.validationFailed(message: "Please enter a positive whole number.")])
    }
    let errors: [FieldError] = validators.reduce([]) { accumulated, validator in
      if case .failure(let errors) = validator.validate(input: uint) { return accumulated + errors }
      return accumulated
    }
    return errors.isEmpty ? .success(Node(uint)) : .failure(errors)
  }
}

/**
  A field which can receive a `Double` value and optionally validate it before
  returning a `FieldValidationResult`.
*/
public struct DoubleField: ValidatableField {
  let validators: [FieldValidator<Double>]
  public init(_ validators: FieldValidator<Double>...) {
    self.validators = validators
  }
  public func validate(_ value: Node) -> FieldValidationResult {
    guard let double = value.double else {
      return .failure([.validationFailed(message: "Please enter a number.")])
    }
    let errors: [FieldError] = validators.reduce([]) { accumulated, validator in
      if case .failure(let errors) = validator.validate(input: double) { return accumulated + errors }
      return accumulated
    }
    return errors.isEmpty ? .success(Node(double)) : .failure(errors)
  }
}

/**
  A field which can receive a `Bool` value and optionally validate it before
  returning a `FieldValidationResult`.
*/
public struct BoolField: ValidatableField {
  let validators: [FieldValidator<Bool>]
  public init(_ validators: FieldValidator<Bool>...) {
    self.validators = validators
  }
  public func validate(_ value: Node) -> FieldValidationResult {
    // If POSTing from a `checkbox` style input, the key's absence means `false`.
    let bool = value.bool ?? false
    let errors: [FieldError] = validators.reduce([]) { accumulated, validator in
      if case .failure(let errors) = validator.validate(input: bool) { return accumulated + errors }
      return accumulated
    }
    return errors.isEmpty ? .success(Node(bool)) : .failure(errors)
  }
}
