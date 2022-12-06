//
//  Row.swift
//  EAMForm
//
//  Created by arvindh on 17/07/18.
//

import Foundation
import UIKit

protocol RowType: AnyObject {
  init(tag: FormKey?, initializer: (Self) -> Void)
  
  func onValueChange(_ callback: @escaping () -> Void) -> Self
  func onSelection(_ callback: @escaping () -> Void) -> Self
}

extension RowType where Self: BaseRow {
  init(tag: FormKey?, initializer: (Self) -> Void) {
    self.init(tag: tag)
    initializer(self)
  }
  
  @discardableResult
  func onValueChange(_ callback: @escaping () -> Void) -> Self {
    _onValueChange = callback
    return self
  }
  
  @discardableResult
  func onSelection(_ callback: @escaping () -> Void) -> Self {
    _onSelection = callback
    return self
  }
}

class BaseRow: NSObject {
  public weak var form: Form?
  
  public var baseValue: Any?
  public var baseView: UIView?
  public var tag: String?
  public var displayName: String = ""
  public var validations: [FormValidation] = []
  public fileprivate(set) var errors: [FormValidationError] = [] {
    didSet {
      valueDidChange()
    }
  }
  
  public var index: Int? {
    return form?.rows.firstIndex(where: { $0 == self })
  }
  
  fileprivate var _onValueChange: (() -> Void)?
  fileprivate var _onSelection: (() -> Void)?
  
  public required init(tag: FormKey?) {
    self.tag = tag?.stringValue
    super.init()
  }
  
  public func valueDidChange() {}
  public func attach(to contentView: UIView) {}
  public func validate() {}
  func setupView() {}
}

extension BaseRow {
  open override func isEqual(_ object: Any?) -> Bool {
    guard let object = object as? BaseRow else {
      return false
    }
    
    guard let value = baseValue as? AnyHashable, let objValue = object.baseValue as? AnyHashable else {
      return false
    }
    
    return tag == object.tag && value == objValue
  }
}

class Row<ValueType, ViewType>: BaseRow where ViewType: UIView, ViewType: RowViewType, ValueType == ViewType.Value {
  public var value: ValueType? {
    get {
      return baseValue as? ValueType
    }
    set {
      baseValue = newValue
      errors = []
      valueDidChange()
    }
  }
  
  var view: ViewType! {
    get {
      return baseView as? ViewType
    }
    set {
      baseView = newValue
    }
  }
  
  public required init(tag: FormKey?) {
    super.init(tag: tag)
    setupView()
  }
  
  public override func attach(to contentView: UIView) {
    assert(view != nil, "Row's view should have been setup")
    
    contentView.addSubview(view)
    view.snp.makeConstraints { make in
      make.edges.equalTo(contentView)
    }
    
    contentView.setNeedsLayout()
    contentView.layoutIfNeeded()
  }
  
  public override func valueDidChange() {
    view.update(with: value, errors: errors)
    view.setNeedsLayout()
    view.layoutIfNeeded()
    
    _onValueChange?()
  }
  
  public override func validate() {
    var errors: [FormValidationError] = []
    
    for validation in validations {
      switch validation {
      case .required:
        guard let _ = value else {
          let error = validation.createError(row: self)
          errors.append(error)
          continue
        }
      default:
        break
      }
    }
    
    self.errors = errors
  }
}

final class TextFieldRow: Row<String, TextfieldRowView>, RowType, UITextFieldDelegate {
  override func setupView() {
    view = TextfieldRowView(frame: CGRect.zero)
    view.textField.delegate = self
  }
  
  public var insets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: -4, right: -10) {
    didSet {
      view.insets = insets
    }
  }
  
  override var displayName: String {
    didSet {
      placeholder = displayName
    }
  }
  
  public var placeholder: String = "" {
    didSet {
      view.textField.placeholder = placeholder
    }
  }
  
  public var isSecure: Bool = false {
    didSet {
      view.textField.isSecureTextEntry = isSecure
    }
  }
  
  public func textField(_ textField: UITextField,
                        shouldChangeCharactersIn range: NSRange,
                        replacementString string: String) -> Bool {
    let text = textField.text as NSString?
    let newText = text?.replacingCharacters(in: range, with: string)
    
    if let newText = newText, !newText.isEmpty {
      value = newText
    } else {
      value = nil
    }
    
    return false
  }
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

final class TextRow: Row<String, TextRowView>, RowType, UITextFieldDelegate {
  override func setupView() {
    view = TextRowView(frame: CGRect.zero)
    view.textField.delegate = self
  }
  
  var title: String = "" {
    didSet {
      view.label.text = title
    }
  }
  
  var isSecure: Bool = false {
    didSet {
      view.textField.isSecureTextEntry = isSecure
    }
  }
  
  public func textField(_ textField: UITextField,
                        shouldChangeCharactersIn range: NSRange,
                        replacementString string: String) -> Bool {
    let text = textField.text as NSString?
    let newText = text?.replacingCharacters(in: range, with: string)
    
    if let newText = newText, !newText.isEmpty {
      value = newText
    } else {
      value = nil
    }
    
    return false
  }
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

final class LabelRow: Row<String, LabelRowView>, RowType {
  override func setupView() {
    view = LabelRowView(frame: CGRect.zero)
  }
  
  var title: String = "" {
    didSet {
      view.label.text = title
    }
  }
}

final class SwitchRow: Row<Bool, SwitchRowView>, RowType {
  override func setupView() {
    view = SwitchRowView(frame: CGRect.zero)
  }
  
  var title: String = "" {
    didSet {
      view.label.text = title
    }
  }
}
