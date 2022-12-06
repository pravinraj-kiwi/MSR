//
//  PersonalEdit.swift
//  Contributor
//
//  Created by KiwiTech on 9/29/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

enum PaymentType: String {
    case giftCard = "default"
    case paypal = "paypal"
    func getPaymentTypeServerValue() -> String {
        switch self {
        case .giftCard:
            return  "default"
        case .paypal:
            return "paypal"
        }
    }
}
enum CellType {
 case singleCell
 case multiCell
 case tripleCell
}

enum ReturnType {
  case next
  case returnType
}

class FormModel {
    var textFieldType: TextFieldType?
    var placeholderKey: String = ""
    var placeholderValue: String = ""
    var hintText: String = ""
    var fieldValue: String = ""
    var datePickerDate: Date?
    var section: Int = 0
    var shouldShowError: Bool = false
    var placeholderKey1: String = ""
    var placeholderValue1: String = ""
    var shouldShowError1: Bool = false
    var fieldValue1: String = ""
    var textFieldType1: TextFieldType?
    var placeholderKey2: String = ""
    var placeholderValue2: String = ""
    var shouldShowError2: Bool = false
    var fieldValue2: String = ""
    var textFieldType2: TextFieldType?
    var passwordNotMatched: Bool = false
    var passwordMatched: Bool = false
    var showPasswordIcon: Bool = false
    var serverError: String = ""
    var accountAlreadyExist: Bool = false
    var wrongCurrentPassword: Bool = false
    var emailsNotMatched: Bool = false
    var emailMatched: Bool = false
}

class FormSection {
 var section: Int
 var sectionKey: String?
 var sectionValue: [FormModel]
 var cellType: CellType
 var isTermsConditionAccepted = false
var isPayPalAmountSelected = false
init(formType: CellType, formSection: Int, formKey: String = "", formValue: [FormModel]) {
  cellType = formType
  section = formSection
  sectionKey = formKey
  sectionValue = formValue
 }
}
