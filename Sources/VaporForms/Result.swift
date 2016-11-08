import Node

public enum FieldValidationResult {
  case success(Node)
  case failure([FieldError])
}

public enum FieldsetValidationResult {
  case success([String: Node])
  case failure(FieldErrorCollection, [String: Node])
}

public enum FormValidationResult {
  case success(Form)
  case failure(FieldErrorCollection, [String: Node])
}
