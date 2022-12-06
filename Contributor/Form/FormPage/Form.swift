//
//  Form.swift
//  EAMForm
//
//  Created by arvindh on 17/07/18.
//

import Foundation

protocol FormKey {
  var stringValue: String {get}
}

extension String: FormKey {
  var stringValue: String {
    return self
  }
}

protocol FormDelegate: class {
  func rowsDidChange()
  func form(_ form: Form, didInsertRow atIndex: Int)
  func form(_ form: Form, didDeleteRow atIndex: Int)
  func form(_ form: Form, didValidateWithErrors errors: [FormValidationError])
}

extension FormDelegate {
  func rowsDidChange() {
    
  }
  
  func form(_ form: Form, didInsertRow atIndex: Int) {
    
  }
  
  func form(_ form: Form, didDeleteRow atIndex: Int) {
    
  }
  
  func form(_ form: Form, didValidateWithErrors errors: [FormValidationError]) {
    
  }
}

public struct FormValidationError: LocalizedError {
  enum ErrorType {
    case missingValue
    case missingPatternMatch
  }
  
  var type: ErrorType
  var row: BaseRow
  
  public var errorDescription: String? {
    switch type {
    case .missingValue:
      return "\(row.displayName) is mandatory"
    case .missingPatternMatch:
      return "Please enter a valid value for \(row.displayName)"
    }
  }
}

public enum FormValidation {
  case required
  case regex(pattern: String)
  
  var associatedErrorType: FormValidationError.ErrorType {
    switch self {
    case .required:
      return .missingValue
    case .regex(_):
      return .missingPatternMatch
    }
  }
  
  func createError(row: BaseRow) -> FormValidationError {
    return FormValidationError(
      type: associatedErrorType,
      row: row
    )
  }
}

final class Form: NSObject {
  public weak var delegate: FormDelegate?

  public var rows: [BaseRow] = [] {
    didSet {
      delegate?.rowsDidChange()
    }
  }
  
  subscript(key: FormKey) -> Any? {
    return self.values[key.stringValue]
  }
  
  public var title: String?
    
  public var values: [String: Any] {
    var values: [String: Any] = [:]

    for row in rows {
      if let key = row.tag, let value = row.baseValue, !key.isEmpty {
        values[key] = value
      }
    }

    return values
  }
  
  public func row(with tag: FormKey) -> BaseRow? {
    return rows.filter({ (row) -> Bool in
      return row.tag == tag.stringValue
    }).first
  }
  
  public func validate() {
    let errors: [FormValidationError] = rows.compactMap {
      $0.validate()
      return $0.errors
    }.reduce([]) {
      (results: [FormValidationError], additions: [FormValidationError]) -> [FormValidationError] in
      var results = results
      results.append(contentsOf: additions)
      return results
    }

    delegate?.form(self, didValidateWithErrors: errors)
  }
    
  public func add(row: BaseRow) {
    rows.append(row)
    delegate?.form(self, didInsertRow: rows.count - 1)
  }
    
  public func delete(row: BaseRow) {
    guard let index = rows.firstIndex(of: row) else {
      return
    }
    
    rows.remove(at: index)
    delegate?.form(self, didDeleteRow: index)
  }
}

extension Form {
  public override func isEqual(_ object: Any?) -> Bool {
    guard let object = object as? Form else {
      return false
    }
      
    return rows == object.rows
  }
}
