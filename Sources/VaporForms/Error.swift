import Vapor
import Node

/**
  Represents an error in the field validation process.
  While they conform to `Error`, these are never thrown by VaporForms;
  instead, they are returned as part of a `...ValidationResult`.

  The `localizedDescription` of these errors is intended to be displayed
  to users as part of e.g. an HTML form.
*/
public enum FieldError: Error {
  /**
    The value did not pass validation.
    The `message` provides further information and can be displayed to users.
  */
  case validationFailed(message: String)
  /**
    The field was marked as required, but a value was not provided.
  */
  case requiredMissing

  public var localizedDescription: String {
    switch self {
    case .validationFailed(let message):
      return message
    case .requiredMissing:
      return "This field is required."
    }
  }

}

/**
  A custom key-value Collection containing arrays of `FieldError` values, each keyed
  by a `String`.

  This collection is used to represent all validation errors raised by a `Fieldset`.
  The key is the field name, and the value is the array of errors relating to that field.

  Subscripting is always safe: if the field does not exist in the collection, an empty
  array will be returned.
*/
public struct FieldErrorCollection: Error, ExpressibleByDictionaryLiteral {
  public typealias Key = String
  public typealias Value = [FieldError]

  private var contents: [Key: Value]

  /**
    When creating an instance by a dictionary literal, setting a key multiple times
    will append to the existing value, rather than replacing it. Therefore both of these
    are correct:

        ["fieldName": [error1, error2]]

    and:

        [
          "fieldName": [error1],
          "fieldName": [error2],
        ]
  */
  public init(dictionaryLiteral elements: (Key, Value)...) {
    contents = [:]
    for (key, value) in elements {
      self[key] += value
    }
  }

  /**
    Since a missing key always returns an empty array, it is safe to always append to
    this collection without needing to check for the existence of the key first. For
    example:

        errors["fieldName"].append(error1)
        errors["fieldName"].append(error2)
  */
  public subscript (key: Key) -> Value {
    get {
      return contents[key] ?? []
    }
    set {
      contents[key] = newValue
    }
  }

  /**
    `true` if there are no errors in the collection.
  */
  public var isEmpty: Bool {
    return contents.isEmpty
  }

}


/**
  Represents an error in validating a Form.
*/
public enum FormError: Error {
  /**
    Validation of the Form failed. The Fieldset instance is returned with
   `errors` and `values` properties set to help with re-rendering the form.
  */
  case validationFailed(fieldset: Fieldset)
}
