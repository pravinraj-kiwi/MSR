//
//  PlaceHolderTriple+ErrorHandling.swift
//  Contributor
//
//  Created by KiwiTech on 10/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension TripleTextFieldsCell: UITextFieldDelegate {
func stopEditingFields(_ textField: UITextField, dividerView: UIView,
                       _ cellType: TextFieldType) {
  dividerView.backgroundColor = defaultColor
  guard let multiCellSection = formTripleData?.section else { return }
  tripleDelegate?.getTriplePlaceholderTextField(fieldType: cellType,
                                                textField, self, multiCellSection)
}
    
func updateChangeInFields(_ textField: UITextField, dividerView: UIView,
                          _ cellType: TextFieldType) {
  dividerView.backgroundColor = activeBorderColor
  guard let multiCellSection = formTripleData?.section else { return }
  tripleDelegate?.changedTripleText(fieldType: cellType,
                                    textField, self, multiCellSection)
}
    
func startEditingFields(_ textField: UITextField, dividerView: UIView,
                        _ cellType: TextFieldType) {
  dividerView.backgroundColor = activeBorderColor
  guard let multiCellSection = formTripleData?.section else { return }
  tripleDelegate?.startedTripleTyping(fieldType: cellType,
                                      textField, multiCellSection, self)
}
 
func textFieldDidBeginEditing(_ textField: UITextField) {
  switch textField.tag {
  case tagOne:
    guard let cellType = formTripleData?.textFieldType else { return }
    startEditingFields(textField, dividerView: formDivider, cellType)
  case tagTwo:
    guard let cellType = formTripleData?.textFieldType1 else { return }
    startEditingFields(textField, dividerView: formDivider1, cellType)
  case tagThree:
    guard let cellType = formTripleData?.textFieldType2 else { return }
    startEditingFields(textField, dividerView: formDivider2, cellType)
  default: break
    }
}

func textField(_ textField: UITextField,
               shouldChangeCharactersIn range: NSRange,
               replacementString string: String) -> Bool {
  let text = textField.text as NSString?
  var newText: String? = text?.replacingCharacters(in: range, with: string)
  if let txtStr = newText, txtStr.isEmpty {
    newText = nil
  }
  let whitespaceSet = NSCharacterSet.whitespaces
  if let _ = string.rangeOfCharacter(from: whitespaceSet) {
    return false
  }
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
  switch textField.tag {
  case self.tagOne:
    guard let cellType = self.formTripleData?.textFieldType else { return }
    self.updateChangeInFields(textField, dividerView: self.formDivider, cellType)
  case self.tagTwo:
    guard let cellType = self.formTripleData?.textFieldType1 else { return }
    self.updateChangeInFields(textField, dividerView: self.formDivider1, cellType)
  case self.tagThree:
    guard let cellType = self.formTripleData?.textFieldType2 else { return }
    self.updateChangeInFields(textField, dividerView: self.formDivider2, cellType)
  default: break
    }
  }
  return true
}
    
func textFieldDidEndEditing(_ textField: UITextField) {
  switch textField.tag {
  case tagOne:
    guard let cellType = formTripleData?.textFieldType else { return }
    stopEditingFields(textField, dividerView: formDivider, cellType)
  case tagTwo:
    guard let cellType = formTripleData?.textFieldType1 else { return }
    stopEditingFields(textField, dividerView: formDivider1, cellType)
  case tagThree:
    guard let cellType = formTripleData?.textFieldType2 else { return }
    stopEditingFields(textField, dividerView: formDivider2, cellType)
  default: break
    }
}
    
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
  if textField == formField {
    textField.resignFirstResponder()
    formField1.becomeFirstResponder()
  } else if textField == formField1 {
    textField.resignFirstResponder()
    formField2.becomeFirstResponder()
  } else if textField == formField2 {
    textField.resignFirstResponder()
  }
  return true
  }
}
