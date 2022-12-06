//
//  ErrorFormCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/1/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

protocol PlaceHolderMultiCellDelegate: class {
  func getMultiPlaceholderTextField(fieldType: TextFieldType,
                                    _ textField: UITextField,
                                    _ cell: PlaceHolderMultiCell,
                                    _ section: Int)
  func startedMultiTyping(fieldType: TextFieldType,
                          _ textField: UITextField,
                          _ section: Int,
                          _ cell: PlaceHolderMultiCell)
  func changedMultiText(fieldType: TextFieldType,
                        _ textField: UITextField,
                        _ cell: PlaceHolderMultiCell,
                        _ section: Int)
  func setMultiNextResponder(_ fieldType: TextFieldType,
                             _ fromCell: UITableViewCell)
}

class PlaceHolderMultiCell: UITableViewCell {
    
@IBOutlet weak var placeHolderFirstName: UILabel!
@IBOutlet weak var formFieldFirstName: UITextField!
@IBOutlet weak var formDividerFirstName: UIView!
@IBOutlet weak var placeHolderLastName: UILabel!
@IBOutlet weak var formFieldLastName: UITextField!
@IBOutlet weak var formDividerLastName: UIView!
@IBOutlet weak var multiLabelError: UILabel!
@IBOutlet weak var multiPassword: UIButton!
@IBOutlet weak var multiPassword1: UIButton!
weak var multiDelegate: PlaceHolderMultiCellDelegate?
var activeBorderColor: UIColor = Constants.primaryColor
let defaultColor = Utilities.getRgbColor(185, 185, 187)
let errorColor = Utilities.getRgbColor(255, 59, 48)
let tagOne = TextFieldTag.one.rawValue
let tagTwo = TextFieldTag.two.rawValue
var formMultiData: FormModel?
var formModel: [FormModel]?
    
override func awakeFromNib() {
  // Initialization code
  backgroundColor = .clear
  applyCommunityTheme()
  formFieldFirstName.delegate = self
  formFieldLastName.delegate = self
  multiPassword.isHidden = true
  multiPassword1.isHidden = true
}

func initialUI(_ personalData: FormModel) {
 if personalData.textFieldType == .signUpNewPassword
        || personalData.textFieldType == .signUpConfirmPassword {
    formFieldFirstName.keyboardType = .asciiCapable
    formFieldLastName.keyboardType = .asciiCapable
 }
 placeHolderFirstName.text = personalData.placeholderKey
 if !personalData.placeholderValue.isEmpty {
    formFieldFirstName.placeholder = personalData.placeholderValue
 }
 formFieldFirstName.text = personalData.fieldValue
 placeHolderLastName.text = personalData.placeholderKey1
 formFieldLastName.text = personalData.fieldValue1
 if !personalData.placeholderValue1.isEmpty {
    formFieldLastName.placeholder = personalData.placeholderValue1
 }
}
    
func handlePasswordUI() {
  if Defaults[.accountNewPassword] == true {
    showPassword(formFieldFirstName, multiPassword)
  }
  if Defaults[.accountConfirmPassword] == true {
    showPassword(formFieldLastName, multiPassword1)
  }
}
    
func updateMultiUI(_ personalData: FormModel) {
  initialUI(personalData)
  multiLabelError.isHidden = true
  if personalData.shouldShowError == true {
    formDividerFirstName.backgroundColor = errorColor
  } else {
    formDividerFirstName.backgroundColor = defaultColor
  }
  if personalData.shouldShowError1 == true {
    formDividerLastName.backgroundColor = errorColor
  } else {
    formDividerLastName.backgroundColor = defaultColor
  }
  if let multiData = formModel {
    updateMultiFormError(multiData)
  }
  if personalData.textFieldType == .signUpNewPassword
        || personalData.textFieldType == .signUpConfirmPassword {
    updateInitialPasswordUI()
    if !personalData.fieldValue.isEmpty {
        multiPassword.isHidden = false
    }
    if !personalData.fieldValue1.isEmpty {
        multiPassword1.isHidden = false
    }
  } else {
    formFieldFirstName.clearButtonMode = .whileEditing
    formFieldLastName.clearButtonMode = .whileEditing
    formFieldFirstName.autocapitalizationType = .sentences
    formFieldLastName.autocapitalizationType = .sentences
    multiPassword.isHidden = true
    multiPassword1.isHidden = true
  }
}

func updateInitialPasswordUI() {
  formFieldFirstName.clearButtonMode = .never
  formFieldLastName.clearButtonMode = .never
  hidePassword(formFieldFirstName, multiPassword)
  hidePassword(formFieldLastName, multiPassword1)
  handlePasswordUI()
}
    
func showPassword(_ textField: UITextField,
                  _ passWordButton: UIButton) {
  textField.isSecureTextEntry = false
  passWordButton.tintColor = activeBorderColor
  applyCommunityTheme()
}

func hidePassword(_ textField: UITextField,
                  _ passWordButton: UIButton) {
  textField.isSecureTextEntry = true
  passWordButton.tintColor = Utilities.getRgbColor(211, 211, 212)
}
        
@IBAction func clickToSeeNewPassword(_ sender: UIButton) {
  if sender.isSelected {
    hidePassword(formFieldFirstName, multiPassword)
    sender.isSelected = false
    Defaults[.accountNewPassword] = false
  } else {
    showPassword(formFieldFirstName, multiPassword)
    sender.isSelected = true
    Defaults[.accountNewPassword] = true
  }
 }

@IBAction func clickToConfirmNewPassword(_ sender: UIButton) {
  if sender.isSelected {
    hidePassword(formFieldLastName, multiPassword1)
    sender.isSelected = false
    Defaults[.accountConfirmPassword] = false
  } else {
    showPassword(formFieldLastName, multiPassword1)
    sender.isSelected = true
    Defaults[.accountConfirmPassword] = true
  }
 }
    
func updateMultiFormError(_ formModel: [FormModel]) {
   multiLabelError.isHidden = true
  if !formModel.filter({$0.shouldShowError == true}).isEmpty {
    multiLabelError.isHidden = false
    let type = formModel.compactMap({$0.textFieldType})[0]
    let value = formModel.compactMap({$0.fieldValue})[0]
    multiLabelError.text = Utilities.getErrorAccToType(type, value)
    formDividerFirstName.backgroundColor = errorColor
  }
  if !formModel.filter({$0.shouldShowError1 == true}).isEmpty {
    multiLabelError.isHidden = false
    let type1 = formModel.compactMap({$0.textFieldType1})[0]
    let value1 = formModel.compactMap({$0.fieldValue1})[0]
    multiLabelError.text = Utilities.getErrorAccToType(type1, value1)
    formDividerLastName.backgroundColor = errorColor
  }
  if (!formModel.map({$0.textFieldType == .signUpNewPassword}).isEmpty ||
        !formModel.map({$0.textFieldType1 == .signUpConfirmPassword}).isEmpty)
        && !formModel.filter({$0.passwordNotMatched == true}).isEmpty {
      multiLabelError.isHidden = false
      multiLabelError.text = Utilities.getErrorAccToType(.password)
      formDividerFirstName.backgroundColor = errorColor
      formDividerLastName.backgroundColor = errorColor
  }
  if (!formModel.map({$0.textFieldType == .signUpNewPassword}).isEmpty ||
        !formModel.map({$0.textFieldType1 == .signUpConfirmPassword}).isEmpty)
        && !formModel.filter({$0.passwordMatched == true}).isEmpty {
      multiLabelError.isHidden = true
      formDividerFirstName.backgroundColor = defaultColor
      formDividerLastName.backgroundColor = defaultColor
  }
  if !formModel.filter({$0.shouldShowError == true
                        && $0.shouldShowError1 == true}).isEmpty {
    multiLabelError.isHidden = false
    let type = formModel.compactMap({$0.textFieldType})[0]
    if type == .firstName {
      multiLabelError.text = Utilities.getErrorAccToType(.firstLastName, "")
    }
    if type == .signUpNewPassword {
      multiLabelError.text = Utilities.getErrorAccToType(.newConfirmPassword, "")
    }
    formDividerFirstName.backgroundColor = errorColor
    formDividerLastName.backgroundColor = errorColor
  }
 }
}

extension PlaceHolderMultiCell: UITextFieldDelegate {
    
func textFieldDidEndEditing(_ textField: UITextField) {
  if textField.tag == tagOne {
    formDividerFirstName.backgroundColor = defaultColor
    guard let multiCellSection = formMultiData?.section else { return }
    guard let fieldType = self.formMultiData?.textFieldType else { return }
    multiDelegate?.getMultiPlaceholderTextField(fieldType: fieldType,
                                                textField, self, multiCellSection)
  }
  if textField.tag == tagTwo {
    formDividerLastName.backgroundColor = defaultColor
    guard let multiCellSection = formMultiData?.section else { return }
    guard let fieldType1 = self.formMultiData?.textFieldType1 else { return }
    multiDelegate?.getMultiPlaceholderTextField(fieldType: fieldType1,
                                                   textField, self, multiCellSection)
  }
}

func textField(_ textField: UITextField,
               shouldChangeCharactersIn range: NSRange,
               replacementString string: String) -> Bool {
  let text = textField.text as NSString?
  var newText: String? = text?.replacingCharacters(in: range, with: string)
  if let textString = newText, textString.isEmpty {
    newText = nil
  }
  guard let fieldType = self.formMultiData?.textFieldType else { return true }
  if fieldType == .signUpNewPassword || fieldType == .signUpConfirmPassword {
    let whitespaceSet = NSCharacterSet.whitespaces
    if let _ = string.rangeOfCharacter(from: whitespaceSet) {
      return false
    }
  }
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    if textField.tag == self.tagOne {
        self.formDividerFirstName.backgroundColor = self.activeBorderColor
        guard let multiCellSection = self.formMultiData?.section else { return }
        guard let fieldType = self.formMultiData?.textFieldType else { return }
        if fieldType == .signUpNewPassword {
            self.updateNewPassword(textField)
        }
        self.multiDelegate?.changedMultiText(fieldType: fieldType,
                                         textField, self, multiCellSection)
     }
    if textField.tag == self.tagTwo {
        self.formDividerLastName.backgroundColor = self.activeBorderColor
        guard let multiCellSection = self.formMultiData?.section else { return }
        guard let fieldType1 = self.formMultiData?.textFieldType1 else { return }
        if fieldType1 == .signUpConfirmPassword {
            self.updateConfirmPassword(textField)
        }
        self.multiDelegate?.changedMultiText(fieldType: fieldType1, textField,
                                         self, multiCellSection)
     }
  }
  return true
}
   
func updateNewPassword(_ textField: UITextField) {
  if let field = textField.text, field.isEmpty {
    self.multiPassword.isHidden = true
  } else {
    if let field = textField.text, field.length >= 1 {
        self.multiPassword.isHidden = false
    }
  }
}
    
func updateConfirmPassword(_ textField: UITextField) {
  if let field = textField.text, field.isEmpty {
    self.multiPassword1.isHidden = true
  } else {
    if let field = textField.text, field.length >= 1 {
        self.multiPassword1.isHidden = false
    }
  }
}
    
func textFieldDidBeginEditing(_ textField: UITextField) {
  if textField.tag == tagOne {
    formDividerFirstName.backgroundColor = activeBorderColor
  }
  if textField.tag == tagTwo {
    formDividerLastName.backgroundColor = activeBorderColor
  }
  if textField.tag == tagOne {
    guard let multiCellSection = formMultiData?.section else { return }
    guard let fieldType = self.formMultiData?.textFieldType else { return }
    multiDelegate?.startedMultiTyping(fieldType: fieldType, textField, multiCellSection, self)
  }
  if textField.tag == tagTwo {
    guard let multiCellSection = formMultiData?.section else { return }
    guard let fieldType1 = self.formMultiData?.textFieldType1 else { return }
    multiDelegate?.startedMultiTyping(fieldType: fieldType1, textField, multiCellSection, self)
  }
}
    
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
  formFieldLastName.becomeFirstResponder()
  if textField.returnKeyType == .done {
    formFieldLastName.resignFirstResponder()
  } else if textField.tag == tagTwo {
    guard let fieldType1 = self.formMultiData?.textFieldType1 else { return true}
    multiDelegate?.setMultiNextResponder(fieldType1, self)
  }
  return true
  }
}

extension PlaceHolderMultiCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity,
          let colors = community.colors else {
         updateColors(Color.primary.value)
          return
    }
    updateColors(colors.primary)
}
    
func updateColors(_ color: UIColor) {
  placeHolderFirstName.textColor = color
  placeHolderLastName.textColor = color
  activeBorderColor = color
  formFieldFirstName.tintColor = color
  formFieldLastName.tintColor = color
 }
}
