import Node

/**
  Returned after the validation of a single `ValidatableField`.

  If you are calling a `Validator` directly this result type is also used.
*/
public enum FieldValidationResult {
  /**
    The value was successfully validated. The value which was validated is
    returned in the associated value.

    Note that because of polymorphism, the return value is not guaranteed
    to be of the same type as the value passed in. For example, an
    `IntegerField` is able to accept a String value "42" which it will
    convert to an Int value 42 before validating. The value returned here
    will be the Int.
  */
  case success(Node)
  /**
    The value did not pass at least one of the field's validators. The
    list of field validation errors, and their user-presentable error
    messgaes, are in the associated value.
  */
  case failure([FieldError])
}

/**
  Returned after the attempted validation of a `Fieldset`.
*/
public enum FieldsetValidationResult {
  /**
    The `Fieldset` validated correctly, and the valid results are in
    the associated value. The key is the name of the field, and the value
    is the validated value of the field.

    Note that because of polymorphism, the return value is not guaranteed
    to be of the same type as the value passed in. For example, an
    `IntegerField` is able to accept a String value "42" which it will
    convert to an Int value 42 before validating. The value returned here
    will be the Int.
  */
  case success(validated: [String: Node])
  /**
    The `Fieldset` did not pass at least one of the fieldset's validators,
    or required values were missing. `Fieldset.errors` is a
    keyed collection of fields and their errors, where the key is the field
    name and the value is an array of errors raised during that field's
    validation phase.

    `Fieldset.values` is the dictionary of values which were validated
    against. You can use this dictionary when re-rendering your HTML form to
    pre-fill the fields with the user's invalid input.
  */
  case failure
}

/**
  Returned after the attempted validation of a `Form`.
*/
public enum FormValidationResult {
  /**
    The `Form` was validated successfully, and an instance of that `Form` is
    returned as the associated value. You can use the properties of the form
    instance as valid data.
  */
  case success(Form)
  /**
    The `Form` did not pass at least one of its fieldset's validators, or
    required values were missing. The first associated value is a
    keyed collection of fields and their errors, where the key is the field
    name and the value is an array of errors raised during that field's
    validation phase.

    The second associated value is the dictionary of values which were validated
    against. You can use this dictionary when re-rendering your HTML form to
    pre-fill the fields with the user's invalid input.
  */
  case failure(Fieldset)
}
