//
//  OtpValidationViewModel.swift
//  Contributor
//
//  Created by KiwiTech on 2/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class PhoneValidationViewModel {

    // api/validate/phone/send-code
    func sendOtpOnPhoneNumber(phoneNumber: String,
                              success: ((Bool) -> Void)?) {
        let params = PhoneNumberParams(phoneNumber: phoneNumber)
        NetworkManager.shared.sendOtpOnPhoneNumber(params) { (error) in
            if error != nil {
             success?(false)
           } else {
             success?(true)
            }
        }
    }
    
    // api/validate/phone/validate-code
    func verifySendOtp(phoneNumber: String, otp: String,
                       success: ((User?, Bool) -> Void)?) {
        let params = VerifyOtpParams(phoneNumber: phoneNumber, otp: otp)
        NetworkManager.shared.verifyRecievedOtp(params) { (userObject, error) in
            if error != nil {
                success?(nil, false)
            } else {
                success?(userObject, true)
            }
        }
    }
}
