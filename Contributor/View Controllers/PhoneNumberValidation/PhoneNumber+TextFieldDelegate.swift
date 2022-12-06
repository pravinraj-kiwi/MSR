//
//  PhoneNumber+TextFieldDelegate.swift
//  Contributor
//
//  Created by KiwiTech on 2/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension PhoneNumberValidationController: UITextFieldDelegate {

func textFieldDidBeginEditing(_ textField: UITextField) {
    pickerStackView.isHidden = true
    if textField == phoneNumberTextField {
        if textField.text == "" {
            otpSendButton.setEnabled(false)
            phoneNumberLineView.backgroundColor = textFieldDefaultColor
        } else {
            otpSendButton.setEnabled(true)
            phoneNumberLineView.backgroundColor = primaryColor
        }
        phoneNumberErrorLabel.text = ""
    }
}

func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
               replacementString string: String) -> Bool {
    let isValidate = textField.validateForPhoneNumber(CharactersIn: range,
                                                      string: string)
    if let text = textField.text,
       let textRange = Range(range, in: text) {
       let updatedText = text.replacingCharacters(in: textRange,
                                                   with: string)
        if updatedText == "" {
            otpSendButton.setEnabled(false)
            phoneNumberLineView.backgroundColor = textFieldDefaultColor
        } else {
            otpSendButton.setEnabled(true)
            phoneNumberLineView.backgroundColor = primaryColor
        }
        phoneNumberErrorLabel.text = ""
    }
    return isValidate
}

func textFieldDidEndEditing(_ textField: UITextField) {
    updateUIWithError()
}

func updateUIWithError() {
    if let phoneNumber = phoneNumberTextField.text {
        let number = "\(phoneValidationModel.countryCode)\(phoneNumber)"
        let isValidNumber = Helper.isNumberValidWithSelectedCountryCode(number)
        otpSendButton.setEnabled(isValidNumber)
        if isValidNumber {
            phoneValidationModel.phoneNumber = phoneNumber
            phoneNumberLineView.backgroundColor = textFieldDefaultColor
            phoneNumberErrorLabel.text = ""
        } else {
            phoneNumberErrorLabel.isHidden = false
            phoneNumberLineView.backgroundColor = .red
            phoneNumberErrorLabel.text = PhoneValidationText.invalidNumber.localized()
        }
    } else {
        phoneNumberErrorLabel.isHidden = false
        phoneNumberLineView.backgroundColor = .red
        phoneNumberErrorLabel.text = PhoneValidationText.phoneNumberValidation.localized()
    }
  }
}
