//
//  Views.swift
//  EAMForm
//
//  Created by arvindh on 17/07/18.
//

import Foundation
import SnapKit

public protocol RowViewType {
  associatedtype Value: Equatable
  func update(with value: Value?, errors: [FormValidationError])
}

public class BaseRowView: UIView {
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  func setup() {}
}

public class TextfieldRowView: BaseRowView, RowViewType {
  public typealias Value = String
  
  let textField: UITextField = {
    let textField = UITextField(frame: CGRect.zero)
    textField.backgroundColor = Constants.backgroundColor
    textField.font = Font.regular.of(size: 16)
    return textField
  }()
  
  let errorLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 14)
    label.textColor = Constants.primaryColor
    label.backgroundColor = Constants.backgroundColor
    label.text = ""
    return label
  }()
  
  private var leftMargin: Constraint!
  private var topMargin: Constraint!
  private var rightMargin: Constraint!
  private var bottomMargin: Constraint!
  
  var insets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: -4, right: -10) {
    didSet {
      leftMargin.update(offset: insets.left)
      topMargin.update(offset: insets.top)
      rightMargin.update(offset: insets.right)
      bottomMargin.update(offset: insets.bottom)
      
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  override func setup() {
    backgroundColor = Constants.backgroundColor
    
    addSubview(textField)
    textField.snp.makeConstraints { make in
      self.topMargin = make.top.equalTo(self).offset(insets.top).constraint
      self.leftMargin = make.left.equalTo(self).offset(insets.left).constraint
      self.rightMargin = make.right.equalTo(self).offset(-insets.right).priority(999).constraint
      make.height.equalTo(44)
    }
    
    UIView.addUnderline(to: textField, in: self, UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0))
    
    addSubview(errorLabel)
    errorLabel.snp.makeConstraints { (make) in
      make.left.equalTo(textField)
      make.right.equalTo(textField)
      make.top.equalTo(textField.snp.bottom).offset(4)
      self.bottomMargin = make.bottom.equalTo(self).offset(insets.bottom).constraint
      make.height.equalTo(20)
    }
  }
  
  public func update(with value: Value?, errors: [FormValidationError]) {
    if !errors.isEmpty {
      // Do Something
      let error = errors.first
      errorLabel.text = error?.errorDescription
      return
    }
    
    textField.text = value
    errorLabel.text = ""
  }
}

public class TextRowView: BaseRowView, RowViewType {
  public typealias Value = String
  
  let label: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 16)
    label.backgroundColor = Constants.backgroundColor
    label.textColor = Color.text.value
    return label
  }()
  
  let textField: UITextField = {
    let textField = UITextField(frame: CGRect.zero)
    textField.backgroundColor = Constants.backgroundColor
    textField.font = Font.regular.of(size: 16)
    textField.textColor = Color.lightText.value
    textField.textAlignment = .right
    textField.clearButtonMode = .whileEditing
    return textField
  }()
  
  override func setup() {
    backgroundColor = Constants.backgroundColor
    setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalTo(self).offset(8)
      make.bottom.equalTo(self).offset(-8).priority(999)
      make.left.equalTo(self).offset(16).priority(999)
      make.height.equalTo(36)
      make.width.equalTo(140)
    }
    
    addSubview(textField)
    textField.snp.makeConstraints { make in
      make.top.equalTo(label)
      make.bottom.equalTo(label)
      make.left.equalTo(label.snp.right).offset(10)
      make.right.equalTo(self).offset(-10).priority(999)
      make.height.equalTo(label)
    }
    
    let border = UIView()
    border.backgroundColor = Color.lightBackground.value
    addSubview(border)
    border.snp.makeConstraints { make in
      make.left.equalTo(label)
      make.right.equalTo(self)
      make.bottom.equalTo(self)
      make.height.equalTo(1)
    }
  }
  
  public func update(with value: Value?, errors: [FormValidationError]) {
    if !errors.isEmpty {
      return
    }
    textField.text = value
  }
}

public class LabelRowView: BaseRowView, RowViewType {
  public typealias Value = String
  let label: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 16)
    label.backgroundColor = Constants.backgroundColor
    return label
  }()
  
  let valueLabel: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 16)
    label.textAlignment = .right
    label.textColor = Color.lightText.value
    label.backgroundColor = Constants.backgroundColor
    return label
  }()
  
  override func setup() {
    backgroundColor = Constants.backgroundColor
    setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalTo(self).offset(8)
      make.bottom.equalTo(self).offset(-8).priority(999)
      make.left.equalTo(self).offset(10)
      make.height.equalTo(36)
    }
    
    addSubview(valueLabel)
    valueLabel.snp.makeConstraints { make in
      make.top.equalTo(label)
      make.bottom.equalTo(label)
      make.left.equalTo(label.snp.right).offset(10)
      make.right.equalTo(self).offset(-10).priority(999)
      make.height.equalTo(label)
      make.width.equalTo(label)
    }
  }
  
  public func update(with value: Value?, errors: [FormValidationError]) {
    if !errors.isEmpty {
      return
    }
    valueLabel.text = value
  }
}

public class SwitchRowView: BaseRowView, RowViewType {
  public typealias Value = Bool
    let label: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 16)
    label.backgroundColor = Constants.backgroundColor
    return label
  }()
  
  let switchView: UISwitch = {
    let switchView = UISwitch()
    return switchView
  }()
  
  override func setup() {
    backgroundColor = Constants.backgroundColor
    addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalTo(self).offset(8)
      make.bottom.equalTo(self).offset(-8).priority(999)
      make.left.equalTo(self).offset(10)
      make.height.equalTo(36)
    }
    
    addSubview(switchView)
    switchView.snp.makeConstraints { make in
      make.top.equalTo(label)
      make.bottom.equalTo(label)
      make.left.equalTo(label.snp.right).offset(10)
      make.right.equalTo(self).offset(-10).priority(999)
      make.height.equalTo(label)
    }
  }
  
  public func update(with value: Value?, errors: [FormValidationError]) {
    if !errors.isEmpty {
      return
    }
    switchView.isOn = value ?? false
  }
}
