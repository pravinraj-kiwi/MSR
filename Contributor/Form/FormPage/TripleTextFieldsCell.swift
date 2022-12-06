//
//  TripleTextFieldsCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

protocol TripleTextFieldsDelegate: class {
  func getTriplePlaceholderTextField(fieldType: TextFieldType,
                                     _ textField: UITextField,
                                     _ cell: TripleTextFieldsCell, _ section: Int)
  func startedTripleTyping(fieldType: TextFieldType, _ textField: UITextField,
                           _ section: Int, _ cell: TripleTextFieldsCell)
  func changedTripleText(fieldType: TextFieldType, _ textField: UITextField,
                         _ cell: TripleTextFieldsCell, _ section: Int)
}

class TripleTextFieldsCell: UITableViewCell {
@IBOutlet weak var placeHolder: UILabel!
@IBOutlet weak var formField: UITextField!
@IBOutlet weak var formDivider: UIView!
@IBOutlet weak var placeHolder1: UILabel!
@IBOutlet weak var formField1: UITextField!
@IBOutlet weak var formDivider1: UIView!
@IBOutlet weak var placeHolder2: UILabel!
@IBOutlet weak var formField2: UITextField!
@IBOutlet weak var formDivider2: UIView!
@IBOutlet weak var multiLabelError: UILabel!
@IBOutlet weak var multiPassword: UIButton!
@IBOutlet weak var multiPassword1: UIButton!
@IBOutlet weak var multiPassword2: UIButton!

weak var tripleDelegate: TripleTextFieldsDelegate?
var activeBorderColor: UIColor = Constants.primaryColor
let defaultColor = Utilities.getRgbColor(185, 185, 187)
let errorColor = Utilities.getRgbColor(255, 59, 48)
let tagOne = TextFieldTag.one.rawValue
let tagTwo = TextFieldTag.two.rawValue
let tagThree = TextFieldTag.three.rawValue
var formTripleData: FormModel?
    
override func awakeFromNib() {
  // Initialization code
  applyCommunityTheme()
  formField.delegate = self
  formField1.delegate = self
  formField2.delegate = self
  multiLabelError.isHidden = true
  updatePasswodUI(password: multiPassword, textField: formField)
  updatePasswodUI(password: multiPassword1, textField: formField1)
  updatePasswodUI(password: multiPassword2, textField: formField2)
}
    
func updatePasswodUI(password: UIButton, textField: UITextField) {
 password.isHidden = false
 textField.isSecureTextEntry = true
 password.tintColor = Utilities.getRgbColor(211, 211, 212)
}

func handlePasswordUI() {
  if Defaults[.tripleCurrentPassword] == true {
    showPassword(formField, multiPassword)
  }
  if Defaults[.tripleNewPassword] == true {
    showPassword(formField1, multiPassword1)
  }
  if Defaults[.tripleConfirmPassword] == true {
    showPassword(formField2, multiPassword2)
  }
}

func initialUI(_ personalData: FormModel) {
 if personalData.showPasswordIcon {
    handlePasswordUI()
 } else {
   multiPassword.isHidden = true
   multiPassword1.isHidden = true
   multiPassword2.isHidden = true
 }
 updateOtherControls(personalData)
}
    
func updateOtherControls(_ personalData: FormModel) {
  placeHolder.text = personalData.placeholderKey
  formField.placeholder = personalData.placeholderValue
  formField.text = personalData.fieldValue
  placeHolder1.text = personalData.placeholderKey1
  formField1.text = personalData.fieldValue1
  formField1.placeholder = personalData.placeholderValue1
  placeHolder2.text = personalData.placeholderKey2
  formField2.text = personalData.fieldValue2
  formField2.placeholder = personalData.placeholderValue2
  if personalData.passwordNotMatched {
    multiLabelError.isHidden = false
    multiLabelError.text = Utilities.getErrorAccToType(.password)
    formDivider1.backgroundColor = errorColor
    formDivider2.backgroundColor = errorColor
   }
  if personalData.wrongCurrentPassword {
    multiLabelError.isHidden = false
    multiLabelError.text = personalData.serverError
    formDivider.backgroundColor = errorColor
    NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
  }
}
    
func showPassword(_ textField: UITextField, _ passWordButton: UIButton) {
  textField.isSecureTextEntry = false
  passWordButton.tintColor = activeBorderColor
  applyCommunityTheme()
}

func hidePassword(_ textField: UITextField, _ passWordButton: UIButton) {
  textField.isSecureTextEntry = true
  passWordButton.tintColor = Utilities.getRgbColor(211, 211, 212)
}
        
@IBAction func clickToSeeCurrentPassword(_ sender: UIButton) {
  if sender.isSelected {
    hidePassword(formField, multiPassword)
    sender.isSelected = false
    Defaults[.tripleCurrentPassword] = false
  } else {
    showPassword(formField, multiPassword)
    sender.isSelected = true
    Defaults[.tripleCurrentPassword] = true
  }
 }

@IBAction func clickToSeeNewPassword(_ sender: UIButton) {
  if sender.isSelected {
    hidePassword(formField1, multiPassword1)
    sender.isSelected = false
    Defaults[.tripleNewPassword] = false
  } else {
    showPassword(formField1, multiPassword1)
    sender.isSelected = true
    Defaults[.tripleNewPassword] = true
  }
 }

@IBAction func clickToConfirmNewPassword(_ sender: UIButton) {
  if sender.isSelected {
    hidePassword(formField2, multiPassword2)
    sender.isSelected = false
    Defaults[.tripleConfirmPassword] = false
  } else {
    showPassword(formField2, multiPassword2)
    sender.isSelected = true
    Defaults[.tripleConfirmPassword] = true
  }
 }
    
func updateTripleUI(_ personalData: FormModel) {
  initialUI(personalData)
  formDivider.backgroundColor = defaultColor
  formDivider1.backgroundColor = defaultColor
  formDivider2.backgroundColor = defaultColor
}
    
func updateErrorUI(_ type: TextFieldType, _ value: String, dividerView: UIView) {
  multiLabelError.isHidden = false
  multiLabelError.text = Utilities.getErrorAccToType(type, value)
  dividerView.backgroundColor = errorColor
}
    
func updateTripleFormError(_ textField: UITextField, _ formModel: [FormModel]) {
  multiLabelError.isHidden = true
  _ = formModel.map({$0.wrongCurrentPassword = false})
  if textField.tag == tagOne {
    if !handleAllFieldError(formModel) {
     if !handleMultipleCases(formModel) {
        handleOtherTagError(formModel)
    }
   }
  }
    
  if textField.tag == tagTwo {
    if !handleAllFieldError(formModel) {
     if !handleMultipleCases(formModel) {
        handleOtherTagError(formModel)
    }
   }
  }
    
  if textField.tag == tagThree {
    if !handleAllFieldError(formModel) {
     if !handleMultipleCases(formModel) {
        handleOtherTagError(formModel)
    }
  }
 }
}
}

extension TripleTextFieldsCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity,
          let colors = community.colors else {
          updateColors(Color.primary.value)
        return
    }
   updateColors(colors.primary)
}
    
func updateColors(_ color: UIColor) {
  placeHolder.textColor = color
  placeHolder1.textColor = color
  placeHolder2.textColor = color
  activeBorderColor = color
  formField.tintColor = color
  formField1.tintColor = color
  formField2.tintColor = color
 }
}
