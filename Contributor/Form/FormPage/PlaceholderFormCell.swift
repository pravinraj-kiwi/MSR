//
//  FormTableViewCell.swift
//  Contributor
//
//  Created by KiwiTech on 9/29/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

protocol PlaceholderCellDelegate: class {
  func getPlaceholderTextField(fieldType: TextFieldType, _ textField: UITextField, _ cell: PlaceholderFormCell)
  func startedTyping(fieldType: TextFieldType, _ textField: UITextField, _ cell: PlaceholderFormCell)
  func changedText(fieldType: TextFieldType, _ textField: UITextField, _ cell: PlaceholderFormCell)
  func updateDobText(_ text: String, selectedDate: Date)
  func setNextResponder(_ fromCell: UITableViewCell)
}

class PlaceholderFormCell: UITableViewCell {
@IBOutlet weak var placeHolderText: UILabel!
@IBOutlet weak var formTextField: UITextField!
@IBOutlet weak var formDivider: UIView!
@IBOutlet weak var passwordShow: UIButton!
@IBOutlet weak var hintText: UILabel!
@IBOutlet weak var errorLabel: UILabel!
@IBOutlet weak var topHintConstraint: NSLayoutConstraint!

weak var placeholderDelegate: PlaceholderCellDelegate?
var formData: FormModel?
var formModelData: [FormModel]?
var cellType: CellType? = .singleCell
var shouldShowPassword = false
var activeBorderColor: UIColor = Constants.primaryColor
let defaultColor = Utilities.getRgbColor(185, 185, 187)
let errorColor = Utilities.getRgbColor(255, 59, 48)
var screenType: ScreenType = .personalDetail

override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  formTextField.delegate = self
  passwordShow.isHidden = true
  applyCommunityTheme()
}

func updateUI(_ personalData: FormModel) {
  errorLabel.isHidden = true
  formTextField.placeholder = personalData.placeholderValue
  if !personalData.placeholderKey.isEmpty {
    placeHolderText.isHidden = false
    placeHolderText.text = personalData.placeholderKey
  } else {
    placeHolderText.isHidden = true
  }
  if !personalData.hintText.isEmpty {
    topHintConstraint.constant = 3
    hintText.text = personalData.hintText
  } else {
    topHintConstraint.constant = 0
  }
  if personalData.textFieldType == .email {
    formTextField.keyboardType = .emailAddress
  }
  if personalData.shouldShowError == true {
    formDivider.backgroundColor = errorColor
  } else {
    formDivider.backgroundColor = defaultColor
  }
  if let formData = formModelData {
    updateFormError(formData)
  }
  if let formModal = formData {
    updateTextFieldType(formModal)
  }
  if personalData.textFieldType == .dateOfBirth {
    formTextField.clearButtonMode = .never
  } else {
    formTextField.clearButtonMode = .whileEditing
  }
  formTextField.text = personalData.fieldValue
  if screenType == .personalDetail
        && personalData.textFieldType == .email {
    self.formTextField.isUserInteractionEnabled = false
    self.formTextField.alpha = 0.5
  } else {
    self.formTextField.isUserInteractionEnabled = true
    self.formTextField.alpha = 1.0
  }
}
    
func updateTextFieldType(_ cellType: FormModel) {
  passwordShow.isHidden = true
}

func updateFormError(_ formModel: [FormModel]) {
  errorLabel.isHidden = true
  if !formModel.filter({$0.shouldShowError == true}).isEmpty
        && !formModel.filter({$0.accountAlreadyExist == true}).isEmpty {
      errorLabel.isHidden = false
      let message =  formModel.compactMap({$0.serverError})[0]
      errorLabel.text = message
      formDivider.backgroundColor = errorColor
      NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
  } else {
    if !formModel.filter({$0.shouldShowError == true}).isEmpty {
      errorLabel.isHidden = false
      let value = formModel.compactMap({$0.fieldValue})[0]
      let type =  formModel.compactMap({$0.textFieldType})[0]
      errorLabel.text = Utilities.getErrorAccToType(type, value)
      formDivider.backgroundColor = errorColor
    }
  }
}
    
func showPassword() {
  formTextField.isSecureTextEntry = true
  shouldShowPassword = true
  passwordShow.tintColor = activeBorderColor
  applyCommunityTheme()
}

func hidePassword() {
  formTextField.isSecureTextEntry = false
  passwordShow.tintColor = Utilities.getRgbColor(211, 211, 212)
  shouldShowPassword = false
}
    
@IBAction func clickToSeePassword(_ sender: UIButton) {
  if sender.isSelected {
    hidePassword()
    sender.isSelected = false
  } else {
    showPassword()
    sender.isSelected = true
  }
 }
}

extension PlaceholderFormCell: UITextFieldDelegate {
func textFieldDidEndEditing(_ textField: UITextField) {
  formDivider.backgroundColor = defaultColor
  guard let type = formData?.textFieldType else { return }
  placeholderDelegate?.getPlaceholderTextField(fieldType: type,
                                               textField, self)
}

func textField(_ textField: UITextField,
               shouldChangeCharactersIn range: NSRange,
               replacementString string: String) -> Bool {
  let text = textField.text as NSString?
  var newText: String? = text?.replacingCharacters(in: range, with: string)
  if let txtStr = newText, txtStr.isEmpty {
    newText = nil
  }
  formDivider.backgroundColor = activeBorderColor
  guard let type = formData?.textFieldType else { return false}
  placeholderDelegate?.changedText(fieldType: type, textField, self)
  return true
}
    
func textFieldDidBeginEditing(_ textField: UITextField) {
  formDivider.backgroundColor = activeBorderColor
  guard let type = formData?.textFieldType else { return }
  if type == .referalCode {
    formTextField.returnKeyType = .done
  }
  placeholderDelegate?.startedTyping(fieldType: type, textField, self)
}
    
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
  if textField.returnKeyType == .done {
    formTextField.resignFirstResponder()
  } else {
    placeholderDelegate?.setNextResponder(self)
  }
  return true
  }
}

extension PlaceholderFormCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity,
          let colors = community.colors else {
        placeHolderText.textColor = Color.primary.value
        activeBorderColor = Color.primary.value
        formTextField.tintColor = Color.primary.value
        return
    }
    placeHolderText.textColor = colors.primary
    activeBorderColor = colors.primary
    formTextField.tintColor = colors.primary
  }
}

extension UITextField {
func setInputViewDatePicker(target: Any, selector: Selector, cancelSelector: Selector) {
  let screenWidth = UIScreen.main.bounds.width
  let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        datePicker.locale = Locale.init(identifier: "pt_BR" )
    } else {
        datePicker.locale = Locale.init(identifier: "en" )
    }
  datePicker.datePickerMode = .date
  datePicker.setMin18YearValidation()
  if let selectedDate = Defaults[.accountSelectedDate] {
    datePicker.setDate(selectedDate, animated: false)
  }
  if #available(iOS 13.4, *) {
    datePicker.preferredDatePickerStyle = .wheels
  } else {}
  self.inputView = datePicker
  let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
  let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let cancel = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: target, action: cancelSelector)
    let barButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: target, action: selector)
  toolBar.setItems([cancel, flexible, barButton], animated: false)
  self.inputAccessoryView = toolBar
  }
}
