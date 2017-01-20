import XCTest
@testable import VaporForms
@testable import Vapor
import Leaf

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
      ("testFieldBoolValidation", testFieldBoolValidation),
      // Fieldset
      ("testSimpleFieldset", testSimpleFieldset),
      ("testSimpleFieldsetGetInvalidData", testSimpleFieldsetGetInvalidData),
      ("testSimpleFieldsetWithPostValidation", testSimpleFieldsetWithPostValidation),
      // Form
      ("testSimpleForm", testSimpleForm),
      ("testFormValidation", testFormValidation),
      // Binding
      ("testValidateFromContentObject", testValidateFromContentObject),
      ("testValidateFormFromContentObject", testValidateFormFromContentObject),
      // Leaf tags
      ("testTagErrorsForField", testTagErrorsForField),
      ("testTagIfFieldHasErrors", testTagIfFieldHasErrors),
      ("testTagLoopErrorsForField", testTagLoopErrorsForField),
      ("testTagValueForField", testTagValueForField),
      ("testTagLabelForField", testTagLabelForField),
      // Whole thing use case
      ("testWholeFieldsetUsage", testWholeFieldsetUsage),
      ("testWholeFormUsage", testWholeFormUsage),
      ("testSampleLoginForm", testSampleLoginForm),
      ("testSampleLoginFormWithMultipart", testSampleLoginFormWithMultipart),
    ]
  }

  func expectMatch(_ test: FieldValidationResult, _ match: Node, fail: () -> Void) {
    switch test {
    case .success(let value) where value == match:
      break
    default:
      fail()
    }
  }
  func expectSuccess(_ test: FieldValidationResult, fail: () -> Void) {
    switch test {
    case .success: break
    case .failure: fail()
    }
  }
  func expectFailure(_ test: FieldValidationResult, fail: () -> Void) {
    switch test {
    case .success: fail()
    case .failure: break
    }
  }

  func expectSuccess(_ test: FieldsetValidationResult, fail: () -> Void) {
    switch test {
    case .success: break
    case .failure: fail()
    }
  }
  func expectFailure(_ test: FieldsetValidationResult, fail: () -> Void) {
    switch test {
    case .success: fail()
    case .failure: break
    }
  }

  // MARK: ValidationErrors struct

  func testValidationErrorsDictionaryLiteral() {
    // Must be able to be instantiated by dictionary literal
    let error1 = FieldError.requiredMissing
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
    let error1 = FieldError.requiredMissing
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
    expectMatch(StringField().validate("string"), Node("string")) { XCTFail() }
    // Incorrect value type should fail
    expectFailure(StringField().validate(nil)) { XCTFail() }
    // Value too short should fail
    expectFailure(StringField(String.MinimumLengthValidator(characters: 12)).validate("string")) { XCTFail() }
    // Value too long should fail
    expectFailure(StringField(String.MaximumLengthValidator(characters: 6)).validate("maxi string")) { XCTFail() }
    // Value not exact size should fail
    expectFailure(StringField(String.ExactLengthValidator(characters: 6)).validate("wrong size")) { XCTFail() }
  }

  func testFieldEmailValidation() {
    // Correct value should succeed
    expectMatch(StringField(String.EmailValidator()).validate("email@email.com"), "email@email.com") { XCTFail() }
    // Incorrect value type should fail
    expectFailure(StringField(String.EmailValidator()).validate(nil)) { XCTFail() }
    // Value too long should fail
    expectFailure(StringField(String.EmailValidator(), String.MaximumLengthValidator(characters: 6)).validate("email@email.com")) { XCTFail() }
    // Value not of email type should fail
    expectFailure(StringField(String.EmailValidator()).validate("not an email")) { XCTFail() }
  }

  func testFieldIntegerValidation() {
    // Correct value should succeed
    expectMatch(IntegerField().validate(42), Node(42)) { XCTFail() }
    expectMatch(IntegerField().validate("42"), Node(42)) { XCTFail() }
    expectMatch(IntegerField().validate(-42), Node(-42)) { XCTFail() }
    expectMatch(IntegerField().validate("-42"), Node(-42)) { XCTFail() }
    // Incorrect value type should fail
    expectFailure(IntegerField().validate(nil)) { XCTFail() }
    expectFailure(IntegerField().validate("I'm a string")) { XCTFail() }
    // Non-integer number should fail
    expectFailure(IntegerField().validate(3.4)) { XCTFail() }
    expectFailure(IntegerField().validate("3.4")) { XCTFail() }
    // Value too low should fail
    expectFailure(IntegerField(Int.MinimumValidator(42)).validate(4)) { XCTFail() }
    // Value too high should fail
    expectFailure(IntegerField(Int.MaximumValidator(42)).validate(420)) { XCTFail() }
    // Value not exact should fail
    expectFailure(IntegerField(Int.ExactValidator(42)).validate(420)) { XCTFail() }
  }

  func testFieldUnsignedIntegerValidation() {
    // Correct value should succeed
    expectMatch(UnsignedIntegerField().validate(42), Node(42)) { XCTFail() }
    expectMatch(UnsignedIntegerField().validate("42"), Node(42)) { XCTFail() }
    // Incorrect value type should fail
    expectFailure(UnsignedIntegerField().validate(nil)) { XCTFail() }
    expectFailure(UnsignedIntegerField().validate("I'm a string")) { XCTFail() }
    // Non-integer number should fail
    expectFailure(UnsignedIntegerField().validate(3.4)) { XCTFail() }
    expectFailure(UnsignedIntegerField().validate("3.4")) { XCTFail() }
    // Negative integer number should fail
    expectFailure(UnsignedIntegerField().validate(-42)) { XCTFail() }
    expectFailure(UnsignedIntegerField().validate("-42")) { XCTFail() }
    // Value too low should fail
    expectFailure(UnsignedIntegerField(UInt.MinimumValidator(42)).validate(4)) { XCTFail() }
    expectSuccess(UnsignedIntegerField(UInt.MinimumValidator(42)).validate(44)) { XCTFail() }
    // Value too high should fail
    expectFailure(UnsignedIntegerField(UInt.MaximumValidator(42)).validate(420)) { XCTFail() }
    // Value not exact should fail
    expectFailure(UnsignedIntegerField(UInt.ExactValidator(42)).validate(420)) { XCTFail() }
  }

  func testFieldDoubleValidation() {
    // Correct value should succeed
    expectMatch(DoubleField().validate(42.42), Node(42.42)) { XCTFail() }
    expectMatch(DoubleField().validate("42.42"), Node(42.42)) { XCTFail() }
    expectMatch(DoubleField().validate(-42.42), Node(-42.42)) { XCTFail() }
    expectMatch(DoubleField().validate("-42.42"), Node(-42.42)) { XCTFail() }
    // OK to enter an int here too
    expectMatch(DoubleField().validate(42), Node(42)) { XCTFail() }
    expectMatch(DoubleField().validate("42"), Node(42)) { XCTFail() }
    // Incorrect value type should fail
    expectFailure(DoubleField().validate(nil)) { XCTFail() }
    expectFailure(DoubleField().validate("I'm a string")) { XCTFail() }
    // Value too low should fail
    expectFailure(DoubleField(Double.MinimumValidator(4.2)).validate(4.0)) { XCTFail() }
    // Value too high should fail
    expectFailure(DoubleField(Double.MaximumValidator(4.2)).validate(5.6)) { XCTFail() }
    // Value not exact should fail
    expectFailure(DoubleField(Double.ExactValidator(4.2)).validate(42)) { XCTFail() }
    // Precision
    expectFailure(DoubleField(Double.MinimumValidator(4.0000002)).validate(4.0000001)) { XCTFail() }
  }

  func testFieldBoolValidation() {
    // Correct value should succeed
    expectMatch(BoolField().validate(true), Node(true)) { XCTFail() }
    expectMatch(BoolField().validate(false), Node(false)) { XCTFail() }
    // True-ish values should succeed
    expectMatch(BoolField().validate("true"), Node(true)) { XCTFail() }
    expectMatch(BoolField().validate("t"), Node(true)) { XCTFail() }
    expectMatch(BoolField().validate(1), Node(true)) { XCTFail() }
    // False-ish values should succeed
    expectMatch(BoolField().validate("false"), Node(false)) { XCTFail() }
    expectMatch(BoolField().validate("f"), Node(false)) { XCTFail() }
    expectMatch(BoolField().validate(0), Node(false)) { XCTFail() }
  }

  // MARK: Fieldset

  func testSimpleFieldset() {
    // It should be possible to create and validate a Fieldset on the fly.
    var fieldset = Fieldset([
      "string": StringField(),
      "integer": IntegerField(),
      "double": DoubleField()
    ])
    expectSuccess(fieldset.validate([:])) { XCTFail() }
  }

  func testSimpleFieldsetGetInvalidData() {
    // A fieldset passed invalid data should still hold a reference to that data
    var fieldset = Fieldset([
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
      guard case .failure = result else {
        XCTFail()
        return
      }
      // For next rendering, I should be able to see that data which was passed
      XCTAssertEqual(fieldset.values["string"]?.string, "MyString")
      XCTAssertEqual(fieldset.values["integer"]?.int, 42)
      XCTAssertNil(fieldset.values["gobbledegook"]?.string)
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
      guard case .failure = result else {
        XCTFail()
        return
      }
//      XCTAssertNil(fieldset.values["string"]?.string) // see discussion above
      XCTAssertNil(fieldset.values["integer"]?.int)
      XCTAssertNil(fieldset.values["double"]?.double)
    }
  }

  func testSimpleFieldsetWithPostValidation() {
    // This fieldset validates the whole fieldset after validating individual inputs.
    do {
      var fieldset = Fieldset([
        "string": StringField(),
        "integer": IntegerField(),
        "double": DoubleField()
      ]) { fieldset in
        fieldset.errors["string"].append(FieldError.validationFailed(message: "Always fail"))
      }
      expectFailure(fieldset.validate([:])) { XCTFail() }
    }
    // This fieldset validates a bit more intelligently
    do {
      var fieldset = Fieldset([
        "string": StringField(),
        "integer": IntegerField(),
        "double": DoubleField()
      ], requiring: ["string"]) { fieldset in
        if fieldset.values["string"]?.string != "Charles" {
          fieldset.errors["string"].append(FieldError.validationFailed(message: "String must be Charles"))
        }
      }
      switch fieldset.validate(["string": "Richard"]) {
      case .success:
        XCTFail()
      case .failure:
        XCTAssertEqual(fieldset.errors["string"][0].localizedDescription, "String must be Charles")
      }
    }
  }

  // MARK: Form

  func testSimpleForm() {
    // It should be possible to create a type-safe struct around a Fieldset.
    struct SimpleForm: Form {
      let string: String
      let integer: Int
      let double: Double

      static let fieldset = Fieldset([
        "string": StringField(),
        "integer": IntegerField(),
        "double": DoubleField()
      ])

      internal init(validatedData: [String: Node]) throws {
        string = validatedData["string"]!.string!
        integer = validatedData["integer"]!.int!
        double = validatedData["double"]!.double!
      }
    }
    do {
      let _ = try SimpleForm(validating: [
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

      static let fieldset = Fieldset([
        "string": StringField(),
        "integer": IntegerField(),
        "double": DoubleField()
      ], requiring: ["string", "integer"])

      internal init(validatedData: [String: Node]) throws {
        string = validatedData["string"]!.string!
        integer = validatedData["integer"]!.int!
        double = validatedData["double"]?.double
      }
    }
    // Good validation should succeed
    do {
      let _ = try SimpleForm(validating: [
        "string": "String",
        "integer": 1,
        "double": 2,
      ])
    } catch { XCTFail(String(describing: error)) }
    // One invalid value should fail
    do {
      let _ = try SimpleForm(validating: [
        "string": "String",
        "integer": "INVALID",
        "double": 2,
      ])
    } catch FormError.validationFailed {
    } catch { XCTFail(String(describing: error)) }
    // Missing optional value should succeed
    do {
      let _ = try SimpleForm(validating: [
        "string": "String",
        "integer": 1,
      ])
    } catch { XCTFail(String(describing: error)) }
    // Missing required value should fail
    do {
      let _ = try SimpleForm(validating: [
        "string": "String",
      ])
    } catch FormError.validationFailed {
    } catch { XCTFail(String(describing: error)) }
  }

  // MARK: Binding

  func testValidateFromContentObject() {
    // I want to simulate receiving a Request in POST and binding to it.
    var fieldset = Fieldset([
      "firstName": StringField(),
      "lastName": StringField(),
      "email": StringField(String.EmailValidator()),
      "age": IntegerField(),
    ], requiring: ["firstName", "lastName", "age"])
    // request.data is a Content object. I need to create a Content object.
    let content = Content()
    content.append(Node([
      "firstName": "Peter",
      "lastName": "Pan",
      "age": 13,
    ]))
    XCTAssertEqual(content["firstName"]?.string, "Peter")
    // Now validate
    expectSuccess(fieldset.validate(content)) { XCTFail() }
  }

  func testValidateFromJSON() {
    // I want to simulate receiving a Request in POST and binding to it.
    var fieldset = Fieldset([
      "firstName": StringField(),
      "lastName": StringField(),
      "email": StringField(String.EmailValidator()),
      "age": IntegerField()
    ], requiring: ["firstName", "lastName", "age"])
    // request.data is a Content object. I need to create a Content object.
    let content = Content()
    content.append(JSON([
      "firstName": "Peter",
      "lastName": "Pan",
      "age": 13,
    ]))
    XCTAssertEqual(content["firstName"]?.string, "Peter")
    // Now validate
    expectSuccess(fieldset.validate(content)) { XCTFail() }
  }

  func testValidateFormFromContentObject() {
    // I want to simulate receiving a Request in POST and binding to it.
    struct SimpleForm: Form {
      let firstName: String?
      let lastName: String?
      let email: String?
      let age: Int?

      static let fieldset = Fieldset([
        "firstName": StringField(),
        "lastName": StringField(),
        "email": StringField(String.EmailValidator()),
        "age": IntegerField(),
      ])

      internal init(validatedData: [String: Node]) throws {
        firstName = validatedData["firstName"]?.string
        lastName = validatedData["lastName"]?.string
        email = validatedData["email"]?.string
        age = validatedData["age"]?.int
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
      let _ = try SimpleForm(validating: content)
    } catch { XCTFail(String(describing: error)) }
  }

  // MARK: Leaf tags

  func testTagErrorsForField() {
    let stem = Stem(workingDirectory: "")
    stem.register(ErrorsForField())
    let leaf = try! stem.spawnLeaf(raw: "#errorsForField(fieldset, \"fieldName\") { #loop(self, \"message\") { #(message) } }")
    var fieldset = Fieldset(["fieldName": StringField()])
    fieldset.errors["fieldName"].append(FieldError.validationFailed(message: "Fail"))
    let context = Context(["fieldset": try! fieldset.makeNode()])
    let rendered = try! stem.render(leaf, with: context).string
    XCTAssertEqual(rendered, "Fail\n")
  }

  func testTagIfFieldHasErrors() {
    let stem = Stem(workingDirectory: "")
    stem.register(IfFieldHasErrors())
    let leaf = try! stem.spawnLeaf(raw: "#ifFieldHasErrors(fieldset, \"fieldName\") { HasErrors }")
    do {
      var fieldset = Fieldset(["fieldName": StringField()])
      fieldset.errors["fieldName"].append(FieldError.requiredMissing)
      let context = Context(["fieldset": try! fieldset.makeNode()])
      let rendered = try! stem.render(leaf, with: context).string
      XCTAssertEqual(rendered, "HasErrors")
    }
    do {
      let fieldset = Fieldset(["fieldName": StringField()])
      let context = Context(["fieldset": try! fieldset.makeNode()])
      let rendered = try! stem.render(leaf, with: context).string
      XCTAssertEqual(rendered, "")
    }
  }

  func testTagLoopErrorsForField() {
    let stem = Stem(workingDirectory: "")
    stem.register(LoopErrorsForField())
    let leaf = try! stem.spawnLeaf(raw: "#loopErrorsForField(fieldset, \"fieldName\", \"message\") { #(message) }")
    var fieldset = Fieldset(["fieldName": StringField()])
    fieldset.errors["fieldName"].append(FieldError.validationFailed(message: "Fail1"))
    fieldset.errors["fieldName"].append(FieldError.validationFailed(message: "Fail2"))
    let context = Context(["fieldset": try! fieldset.makeNode()])
    let rendered = try! stem.render(leaf, with: context).string
    XCTAssertEqual(rendered, "Fail1\nFail2\n")
  }

  func testTagValueForField() {
    let stem = Stem(workingDirectory: "")
    stem.register(ValueForField())
    let leaf = try! stem.spawnLeaf(raw: "#valueForField(fieldset, \"fieldName\")!")
    var fieldset = Fieldset(["fieldName": StringField()])
    fieldset.values = ["fieldName": "FieldValue"]
    let context = Context(["fieldset": try! fieldset.makeNode()])
    let rendered = try! stem.render(leaf, with: context).string
    XCTAssertEqual(rendered, "FieldValue!")
  }

  func testTagLabelForField() {
    let stem = Stem(workingDirectory: "")
    stem.register(LabelForField())
    let leaf = try! stem.spawnLeaf(raw: "#labelForField(fieldset, \"fieldName\")!")
    let fieldset = Fieldset(["fieldName": StringField(label: "NameLabel")])
    let context = Context(["fieldset": try! fieldset.makeNode()])
    let rendered = try! stem.render(leaf, with: context).string
    XCTAssertEqual(rendered, "NameLabel!")
  }

  // MARK: Whole thing

  func testWholeFieldsetUsage() {
    // Test the usability of a Fieldset.
    // I want to define a fieldset which can be used to render a view.
    // For that, the fields will need string labels.
    var fieldset = Fieldset([
      "name": StringField(label: "Your name",
        String.MaximumLengthValidator(characters: 255)
      ),
      "age": UnsignedIntegerField(label: "Your age",
        UInt.MinimumValidator(18, message: "You must be 18+.")
      ),
      "email": StringField(label: "Email address",
        String.EmailValidator(),
        String.MaximumLengthValidator(characters: 255)
      ),
    ])
    // Now, I want to be able to render this fieldset in a view.
    // That means I need to be able to convert it to a Node.
    // The node should be able to tell me the `label` for each field.
    do {
      let fieldsetNode = try! fieldset.makeNode()
      XCTAssertEqual(fieldsetNode["name"]?["label"]?.string, "Your name")
      XCTAssertEqual(fieldsetNode["age"]?["label"]?.string, "Your age")
      XCTAssertEqual(fieldsetNode["email"]?["label"]?.string, "Email address")
      // .. Nice to have: other things for the field, such as 'type', 'maxlength'.
      // .. For now, that's up to the view implementer to take care of.
    }
    // I've received data from my rendered view. Validate it.
    do {
      let validationResult = fieldset.validate([
        "name": "Peter Pan",
        "age": 11,
        "email": "peter@neverland.net",
      ])
      // This should have failed
      expectFailure(validationResult) { XCTFail() }
      // Now I should be able to render the fieldset into a view
      // with the passed-in data and also any errors.
      let fieldsetNode = try! fieldset.makeNode()
      XCTAssertEqual(fieldsetNode["name"]?["label"]?.string, "Your name")
      XCTAssertEqual(fieldsetNode["name"]?["value"]?.string, "Peter Pan")
      XCTAssertNil(fieldsetNode["name"]?["errors"])
      XCTAssertEqual(fieldsetNode["age"]?["errors"]?[0]?.string, "You must be 18+.")
    }
    // Let's try and validate it correctly.
    do {
      let validationResult = fieldset.validate([
        "name": "Peter Pan",
        "age": 33,
        "email": "peter@neverland.net",
      ])
      guard case .success(let validatedData) = validationResult else {
        XCTFail()
        return
      }
      XCTAssertEqual(validatedData["name"]!.string!, "Peter Pan")
      XCTAssertEqual(validatedData["age"]!.int!, 33)
      XCTAssertEqual(validatedData["email"]!.string!, "peter@neverland.net")
      // I would now do something useful with this validated data.
    }
  }

  func testWholeFormUsage() {
    // Test the usability of a Form.
    struct SimpleForm: Form {
      let name: String
      let age: UInt
      let email: String?
      static let fieldset = Fieldset([
        "name": StringField(label: "Your name",
          String.MaximumLengthValidator(characters: 255)
        ),
        "age": UnsignedIntegerField(label: "Your age",
          UInt.MinimumValidator(18, message: "You must be 18+.")
        ),
        "email": StringField(label: "Email address",
          String.EmailValidator(),
          String.MaximumLengthValidator(characters: 255)
        ),
      ], requiring: ["name", "age"])
      internal init(validatedData: [String: Node]) throws {
        name = validatedData["name"]!.string!
        age = validatedData["age"]!.uint!
        email = validatedData["email"]?.string
      }
    }
    // I have defined a form with a fieldset with labels. Test
    // that I can properly render it.
    do {
      let fieldsetNode = try! SimpleForm.fieldset.makeNode()
      XCTAssertEqual(fieldsetNode["name"]?["label"]?.string, "Your name")
      XCTAssertEqual(fieldsetNode["age"]?["label"]?.string, "Your age")
      XCTAssertEqual(fieldsetNode["email"]?["label"]?.string, "Email address")
    }
    // I've received data from my rendered view. Validate it.
    do {
      let _ = try SimpleForm(validating: [
        "name": "Peter Pan",
        "age": 11,
        "email": "peter@neverland.net",
      ])
      // This should not succeed
      XCTFail()
    } catch FormError.validationFailed(let fieldset) {
      // Now I should be able to render the fieldset into a view
      // with the passed-in data and also any errors.
      let fieldsetNode = try! fieldset.makeNode()
      XCTAssertEqual(fieldsetNode["name"]?["label"]?.string, "Your name")
      XCTAssertEqual(fieldsetNode["name"]?["value"]?.string, "Peter Pan")
      XCTAssertNil(fieldsetNode["name"]?["errors"])
      XCTAssertEqual(fieldsetNode["age"]?["errors"]?[0]?.string, "You must be 18+.")
    } catch { XCTFail() }
    // Let's try and validate it correctly.
    do {
      let form = try SimpleForm(validating: [
        "name": "Peter Pan",
        "age": 33,
        "email": "peter@neverland.net",
      ])
      XCTAssertEqual(form.name, "Peter Pan")
      XCTAssertEqual(form.age, 33)
      XCTAssertEqual(form.email, "peter@neverland.net")
      // I would now do something useful with this validated data.
    } catch { XCTFail() }
  }

  func testSampleLoginForm() {
    // Test a simple login form which validates against a credential store.
    struct LoginForm: Form {
      let username: String
      let password: String
      static let fieldset = Fieldset([
        "username": StringField(label: "Username"),
        "password": StringField(label: "Password"),
      ], requiring: ["username", "password"]) { fieldset in
        let credentialStore = [
          (username: "user1", password: "pass1"),
          (username: "user2", password: "pass2"),
          (username: "user3", password: "pass3"),
        ]
        if (credentialStore.filter {
          $0.username == fieldset.values["username"]!.string! && $0.password == fieldset.values["password"]!.string!
        }.isEmpty) {
          fieldset.errors["password"].append(FieldError.validationFailed(message: "Invalid password"))
        }
      }
      internal init(validatedData: [String: Node]) throws {
        username = validatedData["username"]!.string!
        password = validatedData["password"]!.string!
      }
    }
    // Try and log in incorrectly
    do {
      let postData = Content()
      postData.append(Node([
        "username": "user1",
        "password": "notmypassword",
      ]))
      let _ = try LoginForm(validating: postData)
      XCTFail()
    } catch FormError.validationFailed(let fieldset) {
      XCTAssertEqual(fieldset.errors["password"][0].localizedDescription, "Invalid password")
    } catch { XCTFail() }
    // Try and log in correctly
    do {
      let postData = Content()
      postData.append(Node([
        "username": "user1",
        "password": "pass1",
      ]))
      let form = try LoginForm(validating: postData)
      XCTAssertEqual(form.username, "user1")
    } catch { XCTFail() }
  }
    
  func testSampleLoginFormWithMultipart() {
    // Test a simple login form which validates against a credential store.
    struct LoginForm: Form {
      let username: String
      let password: String
      static let fieldset = Fieldset([
        "username": StringField(label: "Username"),
        "password": StringField(label: "Password"),
      ], requiring: ["username", "password"]) { fieldset in
        let credentialStore = [
          (username: "user1", password: "pass1"),
          (username: "user2", password: "pass2"),
          (username: "user3", password: "pass3"),
        ]
        if (credentialStore.filter {
          $0.username == fieldset.values["username"]!.string! && $0.password == fieldset.values["password"]!.string!
        }.isEmpty) {
          fieldset.errors["password"].append(FieldError.validationFailed(message: "Invalid password"))
        }
      }
      internal init(validatedData: [String: Node]) throws {
        username = validatedData["username"]!.string!
        password = validatedData["password"]!.string!
      }
    }
    // Try and log in incorrectly
    do {
      let boundary = "~~vapor-forms~~"
      var body = "--" + boundary + "\r\n"
      body += "Content-Disposition: form-data; name=\"username\"\r\n"
      body += "\r\n"
      body += "user1\r\n"
      body += "--" + boundary + "\r\n"
      body += "Content-Disposition: form-data; name=\"password\"\r\n"
      body += "\r\n"
      body += "notmypassword\r\n"
      body += "--" + boundary + "\r\n"
      let parsedBoundary = try Multipart.parseBoundary(contentType: "multipart/form-data; charset=utf-8; boundary=\(boundary)")
      let multipart = Multipart.parse(body.bytes, boundary: parsedBoundary)
      let postData = Content()
      postData.append { (indexes: [PathIndex]) -> Polymorphic? in
        guard let first = indexes.first else { return nil }
        if let string = first as? String {
          return multipart[string]
        } else if let int = first as? Int {
          return multipart["\(int)"]
        } else {
          return nil
        }
      }
      let _ = try LoginForm(validating: postData)
      XCTFail()
    } catch FormError.validationFailed(let fieldset) {
      XCTAssertEqual(fieldset.errors["password"][0].localizedDescription, "Invalid password")
    } catch { XCTFail() }
    // Try and log in correctly
    do {
      let boundary = "~~vapor-forms~~"
      var body = "--" + boundary + "\r\n"
      body += "Content-Disposition: form-data; name=\"username\"\r\n"
      body += "\r\n"
      body += "user1\r\n"
      body += "--" + boundary + "\r\n"
      body += "Content-Disposition: form-data; name=\"password\"\r\n"
      body += "\r\n"
      body += "pass1\r\n"
      body += "--" + boundary + "\r\n"
      let parsedBoundary = try Multipart.parseBoundary(contentType: "multipart/form-data; charset=utf-8; boundary=\(boundary)")
      let multipart = Multipart.parse(body.bytes, boundary: parsedBoundary)
      let postData = Content()
      postData.append { (indexes: [PathIndex]) -> Polymorphic? in
        guard let first = indexes.first else { return nil }
        if let string = first as? String {
          return multipart[string]
        } else if let int = first as? Int {
          return multipart["\(int)"]
        } else {
          return nil
        }
      }
      let form = try LoginForm(validating: postData)
      XCTAssertEqual(form.username, "user1")
    } catch { XCTFail() }
  }
}
