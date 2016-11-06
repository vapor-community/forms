# VaporForms

Brings simple, dynamic and re-usable web form handling to
[Vapor](https://github.com/vapor/vapor).

**Don't use this in production. Please.**

## Features

Create a `Fieldset` on the fly:

```swift
let fieldset = Fieldset([
  "firstName": StringField(),
  "lastName": StringField(),
])
```

and add validation:

```swift
let fieldset = Fieldset([
  "firstName": StringField(),
  "lastName": StringField(),
  "email": StringField(String.EmailValidator()),
], requiring: ["email"])
```

You can add multiple validators, too:

```swift
let fieldset = Fieldset([
  "firstName": StringField(
    String.MinimumLengthValidator(characters: 3),
    String.MaximumLengthValidator(characters: 255),
  ),
  "lastName": StringField(
    String.MinimumLengthValidator(characters: 3),
    String.MaximumLengthValidator(characters: 255),
  ),
  "email": StringField(String.EmailValidator()),
], requiring: ["email"])
```

Validate from a `request`:

```swift
fieldset.validate(request.data)
```

or even from a simple object:

```swift
fieldset.validate([
  "firstName": "Peter",
  "lastName": "Pan",
])
```

Validation results:

```swift
switch fieldset.validate(request.data) {
case .success(let data):
  let user = User(
    firstName: data["firstName"]?.string,
    lastName: data["lastName"]?.string
  )
case .failure(let errors, let data):
  // Use the field names and failed validation messages in `errors`,
  // and the passed-in values in `data` to re-render your form.
}
```

Gain strongly-typed results by wrapping the `Fieldset` in a re-usable `Form`.

```swift
struct UserForm: Form {
  let firstName: String
  let lastName: String
  let email: String
  
  static let fields = Fieldset([
    "firstName": StringField(),
    "lastName": StringField(),
    "email": StringField(String.EmailValidator()),
  ], requiring: ["firstName", "lastName", "email"])
  
  init(validated: [String: Node]) throws {
    guard
      let firstName = validated["firstName"]?.string,
      let lastName = validated["lastName"]?.string,
      let email = validated["email"]?.string
    else { throw FieldError.invalidValidatedData }
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
  }
}

drop.get { req in
  switch try UserForm.validating(req.data) {
  case .success(let form):
    return "Hello \(form.firstName) \(form.lastName)"
  case .failure(let errors, let data):
    // Use the field names and failed validation messages in `errors`,
    // and the passed-in values in `data` to re-render your form.
  }
}
```

## Documentation

See the extensive tests file for full usage while in early development.
Built-in validators are in the `Validators` directory.
Code is not particularly well commented.
Proper documentation to come.

## Known issues

So far, everything works as it says on the tin.

There are some unfortunate design aspects, though, which the author hopes to
straighten out.

One of Swift's greatest assets is strong typing, but this library largely
bypasses all those benefits. This is due to limitations in both Swift's
introspection mechanism, and the author's general intelligence. The `Form`
protocol is an attempt to resolve this lack; *in theory*, when the end-user
fills out their `fields` property and `init` method correctly there should
be no problems, but it would be nice for the compiler to catch any typos
before the app runs. Using an `enum` for field names would be a good idea.

The majority of the library uses `...ValidationResult` enums to return useful
information about the success or failure of validation. However, the `Form`
protocol also `throws` because the mapping of validated data to instance
property is implemented by the end-user and errors may arise.

Vapor's `Node` is heavily used, as is `Content`. Unfortunately, the built-in
[validation](https://vapor.github.io/documentation/guide/validation.html)
is (despite the author's best efforts) almost completely unused. Future PRs
may be able to converge the two validation mechanisms enough that this library
doesn't need to supply its own.
