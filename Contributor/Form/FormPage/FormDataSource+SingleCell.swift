//
//  FormDataSource+SingleCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import EmailValidator
import SwiftyUserDefaults

extension FormDatasource: PlaceholderCellDelegate {
func setNextResponder(_ fromCell: UITableViewCell) {
    if fromCell is PlaceholderFormCell,
       let nextCell = tableView?.cellForRow(at: IndexPath(row: 0, section: 2)) as? PlaceHolderMultiCell {
    nextCell.formFieldFirstName?.becomeFirstResponder()
  }
}
    
func updateDobText(_ text: String, selectedDate: Date) {
  let formModel = formData.flatMap({$0.sectionValue.filter({$0.textFieldType == .dateOfBirth})})
  _ = formModel.map({$0.fieldValue = text})
  _ = formModel.map({$0.datePickerDate = selectedDate})
  if let nextCell = tableView?.cellForRow(at: IndexPath(row: 0, section: 4)) as? PlaceHolderMultiCell {
    nextCell.formFieldFirstName?.becomeFirstResponder()
  }
}
    
func startedTyping(fieldType: TextFieldType, _ textField: UITextField, _ cell: PlaceholderFormCell) {
    let formModel = formData.flatMap({$0.sectionValue.filter({$0.textFieldType == fieldType})})
    _ = formModel.map({$0.shouldShowError = false})
    _ = formModel.map({$0.accountAlreadyExist = false})
    if fieldType == .dateOfBirth {
        cell.formTextField.setInputViewDatePicker(target: self, selector: #selector(tapDone),
                                                  cancelSelector: #selector(tapCancel))
    } else {
        cell.formTextField.inputView =  nil
       cell.formTextField.inputAccessoryView = nil
    }
    if fieldType == .email {
        cell.formTextField.keyboardType = .emailAddress
    }
    reloadCell(formModel, cell)
}
        
func changedText(fieldType: TextFieldType, _ textField: UITextField, _ cell: PlaceholderFormCell) {}
    
func getPlaceholderTextField(fieldType: TextFieldType, _ textField: UITextField, _ cell: PlaceholderFormCell) {
  let formModel = formData.flatMap({$0.sectionValue.filter({$0.textFieldType == fieldType})})
  _ = formModel.map({$0.fieldValue = textField.text ?? ""})
  _ = formModel.map({$0.textFieldType = fieldType})
  _ = formModel.map({$0.shouldShowError = false})
  _ = formModel.map({$0.accountAlreadyExist = false})
  if fieldType != .referalCode && textField.text?.isEmpty == true {
    _ = formModel.map({$0.shouldShowError = true})
  } else {
    if fieldType == .email && !EmailValidator.validate(email: textField.text ?? "") {
      _ = formModel.map({$0.shouldShowError = true})
    }
    if fieldType == .dateOfBirth, let selectedDate = Defaults[.accountSelectedDate] {
        let age = Utilities.calculateAgeInYearsFromDateOfBirth(birthday: selectedDate)
        if age < 16 {
          _ = formModel.map({$0.shouldShowError = true})
        }
    }
  }
  handleButtonEnableDisable(formModel)
  reloadCell(formModel, cell)
}
    
func handleButtonEnableDisable(_ formModel: [FormModel]) {
  NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
  if screenType == .createAccount {
    if validateFieldsForCreateAccount() {
      NotificationCenter.default.post(name: NSNotification.Name.updateButton, object: nil)
    }
  } else {
    if validateFields() {
      NotificationCenter.default.post(name: NSNotification.Name.updateButton, object: nil)
    }
  }
}
    
func validateFieldsForCreateAccount() -> Bool {
  if validateFields() {
    let dobSection = formData.flatMap({$0.sectionValue.filter({$0.section == 2})})
    let dob = dobSection.map({$0.fieldValue})[0]
    let passwordSection = formData.flatMap({$0.sectionValue.filter({$0.section == 3})})
    let newPassword = passwordSection.map({$0.fieldValue})[0]
    let confirmPassword = passwordSection.map({$0.fieldValue1})[0]
    let isTermAccepted = formData.compactMap({$0.isTermsConditionAccepted == true})[0]
    if !dob.isEmpty && !newPassword.isEmpty && !confirmPassword.isEmpty && isTermAccepted {
      if let selectedDate = Defaults[.accountSelectedDate] {
        let age = Utilities.calculateAgeInYearsFromDateOfBirth(birthday: selectedDate)
        if age > 15 {
            return true
         }
       }
    }
  }
 return false
}
    
func validateFields() -> Bool {
  let section = formData.flatMap({$0.sectionValue.filter({$0.section == 0})})
  let email = section.map({$0.fieldValue})[0]
  let sectionoOne = formData.flatMap({$0.sectionValue.filter({$0.section == 1})})
  let firstName = sectionoOne.map({$0.fieldValue})[0]
  let lastName = sectionoOne.map({$0.fieldValue1})[0]
  if (!email.isEmpty && EmailValidator.validate(email: email))
        && !firstName.isEmpty && !lastName.isEmpty {
    return true
  }
 return false
  }
}
