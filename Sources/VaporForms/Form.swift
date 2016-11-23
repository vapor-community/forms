import Vapor

// TODO: Consider using Mirror to ensure that fields match properties on the Form.
// Downside, what if you want to transform from the Field to the property? Or if there's
// no matching property? Also Mirror can be a real performance hit.

/**
  Conform to this protocol to create a re-usable, statically-typed form.

  When declaring your Form struct or class, you should also create your
  `Fieldset`. You will then be able to
*/
public protocol Form {
  /**
    Store your fieldset in this static var.
  */
  static var fieldset: Fieldset { get }

  // TODO: Does this need to throw? We guarantee that `validated` is valid data,
  // if the fieldset is set up correctly, so it should be safe to extract
  // this data using implicitly-unwrapped optionals without needing to throw.
  /**
    Implement this initializer to finalise your `Form` object. It is called
    by the `Form` itself after your form is constructed with

        let formResult = FormObject.validating(request.context)
        guard case .success(let form) = formResult ...

    The values in `validated` are guaranteed to be valid for your `Fieldset`.
    In this initializer, you must map from each field to your struct or class's
    properties, like so:

        self.name = validated["name"]!.string

    If implicitly unwrapping your optionals is not something you would like to do,
    or if you need to perform 'whole-form' validation, this initializer throws so
    that you can throw an error:

        guard let name = validated["name"]?.string else { throw FormIncorrectlyConfigured }

    If you don't want a direct 1:1 mapping of fields to form values, you should do
    work on the validated values before storing them in your form instance. For example,
    uppercasing or lowercasing strings, combining two or more fields into a new field.
  */
  init(validated: [String: Node]) throws
}

public extension Form {

  public static func validating(_ data: [String: Node]) throws -> FormValidationResult {
    let content = Content()
    content.append(Node(data))
    return try validating(content)
  }

  /**
    This is the standard entry point for creating a validated form. Pass in a `Context`
    object such as `request.data` to receive a `FormValidationResult` which will either
    be a successful instantiation of a form with valid properties, or a validation
    failure containing an instance of the fieldset with helpful error messages split by
    field along with the data passed in so that you can render it as initial values in
    your HTML form.
  */
  public static func validating(_ content: Content) throws -> FormValidationResult {
    var fieldset = Self.fieldset
    switch fieldset.validate(content) {
    case .failure:
      return .failure(fieldset)
    case .success(let data):
      return .success(try Self(validated: data))
    }
  }

}
