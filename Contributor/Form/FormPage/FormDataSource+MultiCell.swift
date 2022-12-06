//
//  FormDataSource+MultiCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import EmailValidator
import SwiftyUserDefaults

extension FormDatasource: PlaceHolderMultiCellDelegate {
 func setMultiNextResponder(_ fieldType: TextFieldType, _ fromCell: UITableViewCell) {
    if fieldType == .lastName {
        if fromCell is PlaceHolderMultiCell,
           let nextCell = tableView?.cellForRow(at: IndexPath(row: 0, section: 3)) as? PlaceholderFormCell {
            if nextCell.formData?.textFieldType == .dateOfBirth {
                nextCell.formTextField?.becomeFirstResponder()
                nextCell.formTextField.setInputViewDatePicker(target: self, selector: #selector(tapDone),
                                                              cancelSelector: #selector(tapCancel))
            }
        }
    }
    if fieldType == .signUpConfirmPassword {
        if fromCell is PlaceHolderMultiCell,
           let nextCell = tableView?.cellForRow(at: IndexPath(row: 0, section: 5)) as? PlaceholderFormCell {
            nextCell.formTextField?.becomeFirstResponder()
        }
    }
}
    
@objc func tapDone() {
  if let nextCell = tableView?.cellForRow(at: IndexPath(row: 0, section: 3)) as? PlaceholderFormCell,
    let datePickerView = nextCell.formTextField.inputView as? UIDatePicker {
    let format = DateFormatType.shortStyleFormat.rawValue
    let dateStr = Utilities.convertDateToString(date: datePickerView.date, outpuFormat: format)
    nextCell.formTextField.text = dateStr
    let model = formData.filter({$0.section == 3})[0].sectionValue
    _ = model.map({$0.fieldValue = dateStr})
    updateDobText(dateStr, selectedDate: datePickerView.date)
    Defaults[.accountSelectedDate] = datePickerView.date
    getPlaceholderTextField(fieldType: .dateOfBirth, nextCell.formTextField, nextCell)
  }
}
    
@objc func tapCancel() {
  if let nextCell = tableView?.cellForRow(at: IndexPath(row: 0, section: 4)) as? PlaceHolderMultiCell {
    nextCell.formFieldFirstName?.becomeFirstResponder()
  }
}
    
func getMultiPlaceholderTextField(fieldType: TextFieldType, _ textField: UITextField,
                                  _ cell: PlaceHolderMultiCell, _ section: Int) {
  let model = formData.filter({$0.section == section})[0].sectionValue
    resetPassWordMatch()
  if textField.tag == tagOne {
    let formModel = model.filter({$0.textFieldType == fieldType})
    _ = formModel.map({$0.fieldValue = textField.text ?? ""})
    _ = formModel.map({$0.shouldShowError = false})
    if textField.text?.isEmpty == true {
      _ = formModel.map({$0.shouldShowError = true})
    }
  }
  if textField.tag == tagTwo {
    let formModel = model.filter({$0.textFieldType1 == fieldType})
    _ = formModel.map({$0.fieldValue1 = textField.text ?? ""})
    _ = formModel.map({$0.shouldShowError1 = false})
    if textField.text?.isEmpty == true {
        _ = formModel.map({$0.shouldShowError1 = true})
    }
  }
  handleButtonEnableDisable(model)
  reloadMultiCell(textField, model, cell)
}

func resetPassWordMatch() {
  let passwordSection = formData.flatMap({$0.sectionValue.filter({$0.section == 3})})
  _ =  passwordSection.map({$0.passwordNotMatched = false})
  _ =  passwordSection.map({$0.passwordMatched = false})
}

func startedMultiTyping(fieldType: TextFieldType, _ textField: UITextField,
                        _ section: Int, _ cell: PlaceHolderMultiCell) {
  let model = formData.filter({$0.section == section})[0].sectionValue
  resetPassWordMatch()
  if textField.tag == tagOne {
    let formModel = model.filter({$0.textFieldType == fieldType})
    _ = formModel.map({$0.fieldValue = textField.text ?? ""})
    _ = formModel.map({$0.shouldShowError = false})
  }
  if textField.tag == tagTwo {
    let formModel = model.filter({$0.textFieldType1 == fieldType})
    _ = formModel.map({$0.fieldValue1 = textField.text ?? ""})
    _ = formModel.map({$0.shouldShowError1 = false})
  }
  reloadMultiCell(textField, model, cell)
}

func changedMultiText(fieldType: TextFieldType, _ textField: UITextField,
                      _ cell: PlaceHolderMultiCell, _ section: Int) { }
}
