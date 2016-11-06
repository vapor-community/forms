import XCTest
import VaporForms
import Vapor

/**
 Layout of the vapor-forms library
 - Value: it's a Node for easy Vapor interoperability
 - Validator: a thing which operates on a Type (String, Int, etc) and checks a Value against its own validation rules.
   It returns FieldValidationResult .success or .failure(FieldErrorCollection).
 - Field: a thing which accepts a certain type of Value and holds a number of Validators. It checks a Value against
   its Validators and returns FieldValidationResult .success or .failure(FieldErrorCollection)
 - Fieldset: a collection of Fields which can take an input ValueSet and validate the whole lot against its Fields.
   It returns .success(ValueSet) or .failure(FieldErrorCollection, ValueSet)
 - Form: a protocol for a struct to make a reusable form out of Fieldsets. Can throw because the init needs to
   be implemented by the client (mapping fields to struct properties).

 Errors:
 - FieldError: is an enum of possible error types.
 - FieldErrorCollection: is a specialised collection mapping FieldErrorCollection to field names as String.

 Result sets:
 - FieldValidationResult is either empty .success or .failure(FieldErrorCollection)
 - FieldsetValidationResult is either .success([String: Value]) or .failure(FieldErrorCollection, [String: Value])


 TDD: things a form should do
 ✅ it should be agnostic as to form-encoded, GET, JSON, etc
 ✅ have fields with field types and validation, special case for optionals
 ✅ validate data when inited with request data
 ✅ throw useful validation errors
 - provide useful information on each field to help generate HTML forms but not actually generate them
*/

class VaporFormsTests: XCTestCase {
  static var allTests : [(String, (VaporFormsTests) -> () throws -> Void)] {
    return [
      // ValidationErrors struct
      ("testValidationErrorsDictionaryLiteral", testValidationErrorsDictionaryLiteral),
      ("testValidationErrorsCreateByAppending", testValidationErrorsCreateByAppending),
      // Field validation
      ("testFieldStringValidation", testFieldStringValidation),
      ("testFieldEmailValidation", testFieldEmailValidation),
      ("testFieldIntegerValidation", testFieldIntegerValidation),
      ("testFieldUnsignedIntegerValidation", testFieldUnsignedIntegerValidation),
      ("testFieldDoubleValidation", testFieldDoubleValidation),
      // Fieldset
      ("testSimpleFieldset", testSimpleFieldset),
      ("testSimpleFieldsetGetInvalidData", testSimpleFieldsetGetInvalidData),
      // Form
      ("testSimpleForm", testSimpleForm),
      ("testFormValidation", testFormValidation),
      // Binding
      ("testValidateFromContentObject", testValidateFromContentObject),
      ("testValidateFormFromContentObject", testValidateFormFromContentObject),
    ]
  }

  func expectSuccess(_ test: FieldValidationResult) {
    switch test {
    case .success: break
    case .failure: XCTFail()
    }
  }
  func expectFailure(_ test: FieldValidationResult) {
    switch test {
    case .success: XCTFail()
    case .failure: break
    }
  }

  func expectSuccess(_ test: FieldsetValidationResult) {
    switch test {
    case .success: break
    case .failure: XCTFail()
    }
  }
  func expectFailure(_ test: FieldsetValidationResult) {
    switch test {
    case .success: XCTFail()
    case .failure: break
    }
  }

  // MARK: ValidationErrors struct

  func testValidationErrorsDictionaryLiteral() {
    // Must be able to be instantiated by dictionary literal
    let error1 = FieldError.incorrectValueType
    let error2 = FieldError.requiredMissing
    let errors: FieldErrorCollection = ["key": [error1, error2]]
    XCTAssertEqual(errors["key"].count, 2)
    // Another way of instantiating
    let errors2: FieldErrorCollection = [
      "key": [error1],
      "key": [error2],
    ]
    XCTAssertEqual(errors2["key"].count, 2)
  }

  func testValidationErrorsCreateByAppending() {
    // Must be able to be instantiated mutably
    let error1 = FieldError.incorrectValueType
    let error2 = FieldError.requiredMissing
    var errors: FieldErrorCollection = [:]
    XCTAssertEqual(errors["key"].count, 0)
    errors["key"].append(error1)
    XCTAssertEqual(errors["key"].count, 1)
    errors["key"].append(error2)
    XCTAssertEqual(errors["key"].count, 2)
  }

  // MARK: Field validation

  func testFieldStringValidation() {
    // Correct value should succeed
    expectSuccess(StringField().validate("string"))
    // Incorrect value type should fail
    expectFailure(StringField().validate(nil))
    // Value too short should fail
    expectFailure(StringField(String.MinimumLengthValidator(characters: 12)).validate("string"))
    // Value too long should fail
    expectFailure(StringField(String.MaximumLengthValidator(characters: 6)).validate("maxi string"))
    // Value not exact size should fail
    expectFailure(StringField(String.ExactLengthValidator(characters: 6)).validate("wrong size"))
  }

  func testFieldEmailValidation() {
    // Correct value should succeed
    expectSuccess(StringField(String.EmailValidator()).validate("email@email.com"))
    // Incorrect value type should fail
    expectFailure(StringField(String.EmailValidator()).validate(nil))
    // Value too long should fail
    expectFailure(StringField(String.EmailValidator(), String.MaximumLengthValidator(characters: 6)).validate("email@email.com"))
    // Value not of email type should fail
    expectFailure(StringField(String.EmailValidator()).validate("not an email"))
  }

  func testFieldIntegerValidation() {
    // Correct value should succeed
    expectSuccess(IntegerField().validate(42))
    // Incorrect value type should fail
    expectFailure(IntegerField().validate(nil))
    expectFailure(IntegerField().validate("I'm a string"))
    // Non-integer number should fail
    expectFailure(IntegerField().validate(3.4))
    // Value too low should fail
    expectFailure(IntegerField(Int.MinimumValidator(42)).validate(4))
    // Value too high should fail
    expectFailure(IntegerField(Int.MaximumValidator(42)).validate(420))
    // Value not exact should fail
    expectFailure(IntegerField(Int.ExactValidator(42)).validate(420))
  }

  func testFieldUnsignedIntegerValidation() {
    // Correct value should succeed
    expectSuccess(UnsignedIntegerField().validate(42))
    // Incorrect value type should fail
    expectFailure(UnsignedIntegerField().validate(nil))
    expectFailure(UnsignedIntegerField().validate("I'm a string"))
    // Non-integer number should fail
    expectFailure(UnsignedIntegerField().validate(3.4))
    // Negative integer number should fail
    expectFailure(UnsignedIntegerField().validate(-42))
    // Value too low should fail
    expectFailure(UnsignedIntegerField(UInt.MinimumValidator(42)).validate(4))
    // Value too high should fail
    expectFailure(UnsignedIntegerField(UInt.MaximumValidator(42)).validate(420))
    // Value not exact should fail
    expectFailure(UnsignedIntegerField(UInt.ExactValidator(42)).validate(420))
  }

  func testFieldDoubleValidation() {
    // Correct value should succeed
    expectSuccess(DoubleField().validate(42.42))
    // OK to enter an int here too
    expectSuccess(DoubleField().validate(42))
    // Incorrect value type should fail
    expectFailure(DoubleField().validate(nil))
    expectFailure(DoubleField().validate("I'm a string"))
    // Value too low should fail
    expectFailure(DoubleField(Double.MinimumValidator(4.2)).validate(4.0))
    // Value too high should fail
    expectFailure(DoubleField(Double.MaximumValidator(4.2)).validate(5.6))
    // Value not exact should fail
    expectFailure(DoubleField(Double.ExactValidator(4.2)).validate(42))
    // Precision
    expectFailure(DoubleField(Double.MinimumValidator(4.0000002)).validate(4.0000001))
  }

  // MARK: Fieldset

  func testSimpleFieldset() {
    // It should be possible to create and validate a Fieldset on the fly.
    let fieldset = Fieldset([
      "string": StringField(),
      "integer": IntegerField(),
      "double": DoubleField()
    ])
    expectSuccess(fieldset.validate([:]))
  }

  func testSimpleFieldsetGetInvalidData() {
    // A fieldset passed invalid data should still hold a reference to that data
    let fieldset = Fieldset([
      "string": StringField(),
      "integer": IntegerField(),
      "double": DoubleField()
    ], requiring: ["string", "integer", "double"])
    // Pass some invalid data
    do {
      let result = fieldset.validate([
        "string": "MyString",
        "integer": 42,
      ])
      guard case .failure(_, let data) = result else {
        XCTFail()
        return
      }
      // For next rendering, I should be able to see that data which was passed
      XCTAssertEqual(data["string"]?.string, "MyString")
      XCTAssertEqual(data["integer"]?.int, 42)
      XCTAssertNil(data["gobbledegook"]?.string)
    }
    // Try again with some really invalid data
    // Discussion: should the returned data be identical to what was sent, or should it be
    // "the data we tried to validate against"? For instance, our String validators check that
    // the Node value is actually a String, while Node.string is happy to convert e.g. an Int.
    do {
      let result = fieldset.validate([
        "string": 42,
        "double": "walrus",
        "montypython": 7.7,
      ])
      guard case .failure(_, let data) = result else {
        XCTFail()
        return
      }
//      XCTAssertNil(data["string"]?.string) // see discussion above
      XCTAssertNil(data["integer"]?.int)
      XCTAssertNil(data["double"]?.double)
    }
  }

  // MARK: Form

  func testSimpleForm() {
    // It should be possible to create a type-safe struct around a Fieldset.
    struct SimpleForm: Form {
      let string: String
      let integer: Int
      let double: Double

      static let fields = Fieldset([
        "string": StringField(),
        "integer": IntegerField(),
        "double": DoubleField()
      ])

      internal init(validated: [String: Node]) throws {
        guard
          let string = validated["string"]?.string,
          let integer = validated["integer"]?.int,
          let double = validated["double"]?.double
        else { throw FieldError.invalidValidatedData }
        self.string = string
        self.integer = integer
        self.double = double
      }
    }
    do {
      let _ = try SimpleForm.validating([
        "string": "String",
        "integer": 1,
        "double": 2,
      ])
    } catch { XCTFail(String(describing: error)) }
  }

  func testFormValidation() {
    struct SimpleForm: Form {
      let string: String
      let integer: Int
      let double: Double?

      static let fields = Fieldset([
        "string": StringField(),
        "integer": IntegerField(),
        "double": DoubleField()
      ], requiring: ["string", "integer"])

      internal init(validated: [String: Node]) throws {
        guard
          let string = validated["string"]?.string,
          let integer = validated["integer"]?.int
          else { throw FieldError.invalidValidatedData }
        self.string = string
        self.integer = integer
        self.double = validated["double"]?.double
      }
    }
    // Good validation should succeed
    do {
      let _ = try SimpleForm.validating([
        "string": "String",
        "integer": 1,
        "double": 2,
      ])
    } catch { XCTFail(String(describing: error)) }
    // One invalid value should fail
    do {
      let _ = try SimpleForm.validating([
        "string": "String",
        "integer": "INVALID",
        "double": 2,
      ])
    } catch is FieldErrorCollection {
    } catch { XCTFail(String(describing: error)) }
    // Missing optional value should succeed
    do {
      let _ = try SimpleForm.validating([
        "string": "String",
        "integer": 1,
      ])
    } catch { XCTFail(String(describing: error)) }
    // Missing required value should fail
    do {
      let _ = try SimpleForm.validating([
        "string": "String",
      ])
    } catch is FieldErrorCollection {
    } catch { XCTFail(String(describing: error)) }
  }

  // MARK: Binding

  func testValidateFromContentObject() {
    // I want to simulate receiving a Request in POST and binding to it.
    let fieldset = Fieldset([
      "firstName": StringField(),
      "lastName": StringField(),
      "email": StringField(String.EmailValidator()),
      "age": IntegerField(),
    ])
    // request.data is a Content object. I need to create a Content object.
    let content = Content()
    content.append(Node([
      "firstName": "Peter",
      "lastName": "Pan",
      "age": 13,
    ]))
    XCTAssertEqual(content["firstName"]?.string, "Peter")
    // Now validate
    expectSuccess(fieldset.validate(content))
  }

  func testValidateFormFromContentObject() {
    // I want to simulate receiving a Request in POST and binding to it.
    struct SimpleForm: Form {
      let firstName: String?
      let lastName: String?
      let email: String?
      let age: Int?

      static let fields = Fieldset([
        "firstName": StringField(),
        "lastName": StringField(),
        "email": StringField(String.EmailValidator()),
        "age": IntegerField(),
      ])

      internal init(validated: [String: Node]) throws {
        firstName = validated["firstName"]?.string
        lastName = validated["lastName"]?.string
        email = validated["email"]?.string
        age = validated["age"]?.int
      }
    }
    // request.data is a Content object. I need to create a Content object.
    let content = Content()
    content.append(Node([
      "firstName": "Peter",
      "lastName": "Pan",
      "age": 13,
    ]))
    XCTAssertEqual(content["firstName"]?.string, "Peter")
    // Now validate
    do {
      let result = try SimpleForm.validating(content)
    } catch { XCTFail(String(describing: error)) }
  }

}
