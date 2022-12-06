//
//  FormDataSource+TripleCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension FormDatasource: TripleTextFieldsDelegate {
func getTriplePlaceholderTextField(fieldType: TextFieldType,
                                   _ textField: UITextField,
                                   _ cell: TripleTextFieldsCell, _ section: Int) {
    let model = formData.filter({$0.section == section})[0].sectionValue
    if textField.tag == tagOne {
      _ = model.map({$0.fieldValue = textField.text ?? ""})
      _ = model.map({$0.shouldShowError = false})
      if textField.text?.isEmpty == true {
          _ = model.map({$0.shouldShowError = true})
      }
     }
    if textField.tag == tagTwo {
      _ = model.map({$0.fieldValue1 = textField.text ?? ""})
      _ = model.map({$0.shouldShowError1 = false})
      if textField.text?.isEmpty == true {
          _ = model.map({$0.shouldShowError1 = true})
      }
    }
    if textField.tag == tagThree {
      _ = model.map({$0.fieldValue2 = textField.text ?? ""})
      _ = model.map({$0.shouldShowError2 = false})
      if textField.text?.isEmpty == true {
        _ = model.map({$0.shouldShowError2 = true})
      }
    }
    reloadTripleCell(textField, model, cell)
    NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
    if validateTripleFields(fieldType: fieldType, textField, cell, section) {
      NotificationCenter.default.post(name: NSNotification.Name.updateButton, object: nil)
    }
}
    
func validateTripleFields(fieldType: TextFieldType,
                          _ textField: UITextField,
                          _ cell: TripleTextFieldsCell,
                          _ section: Int) -> Bool {
  let model = formData.flatMap({$0.sectionValue.filter({$0.section == 0})})
  let currentPassword = model.map({$0.fieldValue})[0]
  let newPassword = model.map({$0.fieldValue1})[0]
  let confirmPassword = model.map({$0.fieldValue2})[0]
  if !currentPassword.isEmpty && !newPassword.isEmpty && !confirmPassword.isEmpty {
    return true
  }
 return false
}
    
func startedTripleTyping(fieldType: TextFieldType, _ textField: UITextField,
                         _ section: Int, _ cell: TripleTextFieldsCell) {
    let model = formData.filter({$0.section == section})[0].sectionValue
    if textField.tag == tagOne {
      _ = model.map({$0.fieldValue = textField.text ?? ""})
      _ = model.map({$0.shouldShowError = false})
     }
    if textField.tag == tagTwo {
      _ = model.map({$0.fieldValue1 = textField.text ?? ""})
      _ = model.map({$0.shouldShowError1 = false})
    }
    if textField.tag == tagThree {
      _ = model.map({$0.fieldValue2 = textField.text ?? ""})
      _ = model.map({$0.shouldShowError2 = false})
    }
    reloadTripleCell(textField, model, cell)
    NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
    if validateTripleFields(fieldType: fieldType, textField, cell, section) {
      NotificationCenter.default.post(name: NSNotification.Name.updateButton, object: nil)
    }
}

func changedTripleText(fieldType: TextFieldType, _ textField: UITextField,
                       _ cell: TripleTextFieldsCell, _ section: Int) { }
}
