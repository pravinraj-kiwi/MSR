//
//  MSRTextField.swift
//  Contributor
//
//  Created by arvindh on 20/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import SnapKit
import EmailValidator
import AMPopTip

enum MSRTextfieldValidation {
  case email
  case matchValue(value: String, description: String)
}

enum MSRTextfieldValidationError: LocalizedError {
  case invalidEmail
  case invalidDate
  case invalidValue
  case nonMatchingValue(description: String)
  
  var errorDescription: String? {
    switch self {
    case .invalidEmail:
        return TextFieldText.invalidEmail.localized()
    case .invalidDate:
        return TextFieldText.invalidDate.localized()
    case .invalidValue:
        return TextFieldText.invalidValue.localized()
    case .nonMatchingValue(let desc):
        return "The value doesn't match that of".localized() + "\(desc)"
    }
  }
}

class MSRTextField: UIView {
  struct Layout {
    static var left: CGFloat = 16
    static var right: CGFloat = 16
    static var top: CGFloat = 12
    static var bottom: CGFloat = 6
    static var borderHeight: CGFloat = 1
    static var iconSize: CGFloat = 20
  }
  
  var trimTrailingSpace = false
  
  let textField: UITextField = {
    let tf = UITextField()
    tf.font = Font.regular.of(size: 15)
    tf.tintColor = Constants.primaryColor
    tf.backgroundColor = Constants.backgroundColor
    return tf
  }()
  
  let errorButton: UIButton = {
    let button = UIButton(type: UIButton.ButtonType.custom)
    button.setImage(Image.error.value.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: UIControl.State.normal)
    button.tintColor = Color.error.value
    button.imageView?.clipsToBounds = true
    button.clipsToBounds = true
    
    return button
  }()
  
  var errorImageViewWidthConstraint: Constraint!
  var errorImageViewLeftMarginConstraint: Constraint!

  let validationCheckImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.image = Image.validationSuccess.value
    return iv
  }()

  var validationCheckImageViewWidthConstraint: Constraint!
  var validationCheckImageViewLeftMarginConstraint: Constraint!

  let border: UIView = {
    let view = UIView()
    view.backgroundColor = Color.border.value
    return view
  }()
  
  var borderColor: UIColor = Color.border.value {
    didSet {
      border.backgroundColor = borderColor
    }
  }
  
  lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: CGRect.zero)
    indicator.color = Color.text.value
    indicator.hidesWhenStopped = true
    return indicator
  }()
  
  var activeBorderColor: UIColor = Constants.primaryColor
  
  var text: String? {
    get {
      return textField.text
    }
    set {
      textField.text = newValue
    }
  }
  
  var validation: MSRTextfieldValidation?
  var error: MSRTextfieldValidationError? {
    didSet {
      updateForError()
    }
  }
  
  var onTextChange: ((MSRTextField, String?) -> Void)?
  var onShouldReturn: ((MSRTextField) -> Void)?
  var onErrorButtonTapped: ((MSRTextField, Error) -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    registerForNewCommunityThemeNotification()
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupViews() {
    backgroundColor = Constants.backgroundColor
    
    addSubview(textField)
    textField.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(Layout.top)
      make.left.equalToSuperview().offset(Layout.left)
      make.bottom.equalToSuperview().offset(-Layout.bottom).priority(999)
    }
    textField.delegate = self
    
    addSubview(errorButton)
    errorButton.snp.makeConstraints { make in
      self.errorImageViewWidthConstraint = make.width.equalTo(Layout.iconSize).constraint
      make.height.equalTo(Layout.iconSize)
      self.errorImageViewLeftMarginConstraint = make.left.equalTo(textField.snp.right).offset(Layout.right).constraint
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().offset(-Layout.right).priority(999)
    }
    errorButton.addTarget(self, action: #selector(self.errorButtonTapped), for: UIControl.Event.touchUpInside)

    addSubview(validationCheckImageView)
    validationCheckImageView.snp.makeConstraints { make in
      self.validationCheckImageViewWidthConstraint = make.width.equalTo(0).constraint
      make.height.equalTo(Layout.iconSize)
      self.validationCheckImageViewLeftMarginConstraint = make.left.equalTo(textField.snp.right).offset(0).constraint
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().offset(-Layout.right).priority(999)
    }

    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.width.height.equalTo(Layout.iconSize)
      make.right.equalToSuperview().offset(-Layout.right).priority(999)
    }
    
    addSubview(border)
    border.snp.makeConstraints { make in
      make.height.equalTo(Layout.borderHeight)
      make.left.right.bottom.equalToSuperview()
    }
    
    updateForError()
    applyCommunityTheme()
    
    setNeedsLayout()
    layoutIfNeeded()
  }
  
  func updateForError() {
    if let _ = self.error {
      errorImageViewWidthConstraint.update(offset: Layout.iconSize)
      errorImageViewLeftMarginConstraint.update(offset: Layout.right)
      borderColor = Color.error.value
    } else {
      errorImageViewWidthConstraint.update(offset: 0)
      errorImageViewLeftMarginConstraint.update(offset: 0)
      borderColor = Color.border.value
    }
    
    setNeedsLayout()
    layoutIfNeeded()
  }
  
  func clearError() {
    if let _ = error {
      error = nil
      updateForError()
      border.backgroundColor = activeBorderColor
    }
  }

  func showValidationCheck() {
    clearError()
    hideLoading()
    validationCheckImageViewWidthConstraint.update(offset: Layout.iconSize)
    validationCheckImageViewLeftMarginConstraint.update(offset: Layout.right)
    setNeedsLayout()
    layoutIfNeeded()
  }

  func hideValidationCheck() {
    validationCheckImageViewWidthConstraint.update(offset: 0)
    validationCheckImageViewLeftMarginConstraint.update(offset: 0)
    setNeedsLayout()
    layoutIfNeeded()
  }
  
  @objc func errorButtonTapped() {
    guard let error = error else {return}
    
    onErrorButtonTapped?(self, error)
  }
  
  func validate() -> MSRTextfieldValidationError? {
    guard let validation = self.validation else {
      return nil
    }

    var error: MSRTextfieldValidationError?
    
    switch validation {
    case .email:
      let isValid = EmailValidator.validate(email: self.text ?? "")
      if !isValid {
        error = MSRTextfieldValidationError.invalidEmail
      }
    case .matchValue(let value, let description):
      if let text = self.text {
        if text != value {
          error = MSRTextfieldValidationError.nonMatchingValue(description: description)
        }
      }
    }
    
    self.error = error
    
    return error
  }
  
  func showLoading() {
    activityIndicator.startAnimating()
  }
  
  func hideLoading() {
    activityIndicator.stopAnimating()
  }
}

extension MSRTextField: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    border.backgroundColor = activeBorderColor
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    border.backgroundColor = borderColor
    if trimTrailingSpace {
      textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
      onTextChange?(self, textField.text)
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {    
    textField.resignFirstResponder()
    onShouldReturn?(self)
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let text = textField.text as NSString?
    var newText: String? = text?.replacingCharacters(in: range, with: string)
    
    if let t = newText, t.isEmpty {
      newText = nil
    }
    
    hideValidationCheck()
    clearError()
    
    onTextChange?(self, newText)
    return true
  }
}

extension MSRTextField: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    borderColor = colors.border
    activeBorderColor = colors.primary
    textField.tintColor = colors.primary
  }
}
