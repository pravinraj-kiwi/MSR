//
//  FormErrorMessage.swift
//  Contributor
//
//  Created by KiwiTech on 10/2/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import EmailValidator
import SwiftyUserDefaults

extension Utilities {
class func getErrorAccToType(_ fieldType: TextFieldType,
                             _ text: String = "") -> String {
    switch fieldType {
    case .email:
      if !EmailValidator.validate(email: text) {
        return "Please enter a valid email address".localized()
      }
      return ""
    case .firstName:
        return "Please enter your first name".localized()
    case .lastName:
        return "Please enter your last name".localized()
    case .firstLastName:
        return "Please enter your first and last name".localized()
    case .password:
        return "Passwords do not match, please try again".localized()
    case .currentPassword:
        return "Please enter your current password".localized()
    case .newPassword:
        return "Please enter a new password".localized()
    case .confirmNewPassword:
        return "Please enter your confirm password".localized()
    case .newConfirmPassword:
        return "Please enter your new password and confirm".localized()
    case .currentNewPassword:
        return "Please enter your current and new password".localized()
    case .currentConfirmPassword:
        return "Please enter your current password and confirm new password".localized()
    case .currentNewConfirmPassword:
        return "Please fill out all fields".localized()
    case .dateOfBirth:
        if let selectedDate = Defaults[.accountSelectedDate] {
            let age = Utilities.calculateAgeInYearsFromDateOfBirth(birthday: selectedDate)
            if age < 16 {
              return "Oh no! You must be 16+ years of age to use MSR".localized()
            }
        }
        return "Please enter your date of birth".localized()
    case .referalCode: return ""
    case .signUpNewPassword:
        return "Please enter a password".localized()
    case .signUpConfirmPassword:
        return "Please confirm your password".localized()
    case .confirmEmail:
        if !EmailValidator.validate(email: text) {
          return "Please enter a valid confirm email address".localized()
        }
        return ""
    case .misMatchEmails:
        return "Please make sure your emails match".localized()
    }
    
  }
}
