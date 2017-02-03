import Vapor
import Fluent

/**
 Validates if the value exists on the database
 */
public class UniqueFieldValidator<ModelType: Entity>: FieldValidator<String> {
  let column: String
  let additionalFilters: [(column:String, comparison:Filter.Comparison, value:String)]?
  let message: String?
  public init(column: String, additionalFilters: [(column:String, comparison:Filter.Comparison, value:String)]?=nil, message: String?=nil) {
    self.column = column
    self.additionalFilters = additionalFilters
    self.message = message
  }
  public override func validate(input value: String) -> FieldValidationResult {
    // Let's create the main filter
    do {
      let query = try ModelType.query()
      try query.filter(self.column, value)
      // If we have addition filters, add them
      if let filters = self.additionalFilters {
        for filter in filters {
          try query.filter(filter.column, filter.comparison, filter.value)
        }
      }
      // Check if any record exists
      if(try query.count() > 0){
        return .failure([.validationFailed(message: message ?? "\(self.column) is not unique")])
      }
      // If not we have green light
      return .success(Node(value))
    } catch {
      return .failure([.validationFailed(message: message ?? "\(self.column) is not unique")])
    }
  }
}
