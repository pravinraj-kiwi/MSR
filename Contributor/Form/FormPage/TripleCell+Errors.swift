//
//  TripleCell+Errors.swift
//  Contributor
//
//  Created by KiwiTech on 10/5/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension TripleTextFieldsCell {
func handleAllFieldError(_ formModel: [FormModel]) -> Bool {
  if !formModel.filter({$0.shouldShowError == true
                        && $0.shouldShowError1 == true
                        && $0.shouldShowError2 == true}).isEmpty {
    multiLabelError.isHidden = false
    let type = formModel.compactMap({$0.textFieldType})[0]
    if type == .currentPassword {
        multiLabelError.text = Utilities.getErrorAccToType(.currentNewConfirmPassword)
    }
    formDivider.backgroundColor = errorColor
    formDivider1.backgroundColor = errorColor
    formDivider2.backgroundColor = errorColor
    return true
  }
 return false
}
    
func handleOtherTagError(_ formModel: [FormModel]) {
  if !formModel.filter({$0.shouldShowError1 == true}).isEmpty {
    let type1 = formModel.compactMap({$0.textFieldType1})[0]
    let value1 = formModel.compactMap({$0.fieldValue1})[0]
    updateErrorUI(type1, value1, dividerView: formDivider1)
  } else if !formModel.filter({$0.shouldShowError2 == true}).isEmpty {
    let type2 = formModel.compactMap({$0.textFieldType2})[0]
    let value2 = formModel.compactMap({$0.fieldValue2})[0]
    updateErrorUI(type2, value2, dividerView: formDivider2)
  } else if !formModel.filter({$0.shouldShowError == true}).isEmpty {
    let type = formModel.compactMap({$0.textFieldType})[0]
    let value = formModel.compactMap({$0.fieldValue})[0]
    updateErrorUI(type, value, dividerView: formDivider)
   }
}
    
func handleMultipleCases(_ formModel: [FormModel]) -> Bool {
  var foundError = false
  if !formModel.filter({$0.shouldShowError1 == true
                        && $0.shouldShowError2 == true}).isEmpty {
    multiLabelError.isHidden = false
    let type = formModel.compactMap({$0.textFieldType1})[0]
    if type == .newPassword {
        multiLabelError.text = Utilities.getErrorAccToType(.newConfirmPassword)
    }
    formDivider1.backgroundColor = errorColor
    formDivider2.backgroundColor = errorColor
    foundError = true
  } else if !formModel.filter({$0.shouldShowError == true
                                && $0.shouldShowError2 == true}).isEmpty {
    multiLabelError.isHidden = false
    let type = formModel.compactMap({$0.textFieldType})[0]
    if type == .currentPassword {
        multiLabelError.text = Utilities.getErrorAccToType(.currentConfirmPassword)
    }
    formDivider.backgroundColor = errorColor
    formDivider2.backgroundColor = errorColor
    foundError = true
  } else if !formModel.filter({$0.shouldShowError == true
                                && $0.shouldShowError1 == true}).isEmpty {
    multiLabelError.isHidden = false
    let type = formModel.compactMap({$0.textFieldType})[0]
    if type == .currentPassword {
        multiLabelError.text = Utilities.getErrorAccToType(.currentNewPassword)
    }
    formDivider.backgroundColor = errorColor
    formDivider1.backgroundColor = errorColor
    foundError = true
   }
 return foundError
  }
}
