//
//  OTPInputView.swift
//  Contributor
//
//  Created by KiwiTech on 3/24/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol OTPViewDelegate: class {
  func didFinishEnteringOTP(otpNumber: String)
  func otpNotValid()
}

@IBDesignable public class OTPInputView: UIView {
  @IBInspectable var maximumDigits: Int = 6
  @IBInspectable var inactiveColor: UIColor = Constants.inactiveColor
  @IBInspectable var shadowColour: UIColor = .clear
  @IBInspectable var textColor: UIColor = .white
  @IBInspectable var font: UIFont = Font.semiBold.of(size: 17)
  weak var delegateOTP: OTPViewDelegate?
  @IBInspectable var activeColor: UIColor = Constants.primaryColor
  
  override public func prepareForInterfaceBuilder() {
    setupTextFields()
  }
  
  override public func awakeFromNib() {
    setupTextFields()
  }
  
  fileprivate func setupTextFields() {
    backgroundColor = .white
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.widthAnchor.constraint(equalTo: widthAnchor),
      stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
      stackView.heightAnchor.constraint(equalTo: heightAnchor)
      ])
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.spacing = 12
    stackView.distribution = .fillEqually
    for tag in 1...maximumDigits {
      let textField = OTPTextField()
      textField.tag = tag //set Tag to textField
      stackView.addArrangedSubview(textField)  // Add to stackView
      setupTextFieldStyle(textField)  // set the style accordingly
    }
  }
  
  fileprivate func setupTextFieldStyle(_ textField: UITextField) {
    textField.delegate = self // set up textfield delegate
    textField.backgroundColor = inactiveColor
    textField.keyboardType = .numberPad
    textField.textAlignment = .center
    textField.contentHorizontalAlignment = .center
    textField.textColor = textColor
    textField.tintColor = activeColor
    textField.font = font
    textField.textContentType = .oneTimeCode
    applyCommunityTheme()
  }
}

extension OTPInputView: UITextFieldDelegate {
  
  public func textField(_ textField: UITextField,
                        shouldChangeCharactersIn range: NSRange,
                        replacementString string: String) -> Bool {
    // handle backspace, empty out the box totally
    if string.isBackspace {
      if textField.hasText {
        // delete text in this box
        textField.text = ""
      } else {
        // delete the text and jump to the previous box if one exists
        if let previousTextField = viewWithTag(textField.tag - 1) as? UITextField {
          textField.resignFirstResponder()
          previousTextField.becomeFirstResponder()
        }
      }
    } else {
      if string.isEmpty {
        textField.text = ""
      } else {
        var nextTextField: UITextField? = nil
        
        var remainingCharacters = string
        let firstCharacter = String(remainingCharacters.removeFirst())
        // when this field is empty
        if !textField.hasText {
          textField.text = firstCharacter
          textField.backgroundColor = activeColor
          nextTextField = viewWithTag(textField.tag + 1) as? UITextField
        } else {
          for i in textField.tag...maximumDigits {
            guard let t = viewWithTag(i) as? UITextField else { continue }
            if !t.hasText {
              t.text = firstCharacter
              t.backgroundColor = activeColor
              nextTextField = viewWithTag(t.tag + 1) as? UITextField
              break
            }
          }
        }
        while let t = nextTextField, remainingCharacters.length > 0 {
          let nextCharacter = String(remainingCharacters.removeFirst())
          t.text = nextCharacter
          t.backgroundColor = activeColor
          nextTextField = viewWithTag(t.tag + 1) as? UITextField
        }
        // leave this field
        textField.resignFirstResponder()
        // and move to the next
        if let nextTextField = nextTextField {
          nextTextField.becomeFirstResponder()
        }
      }
    }
    checkForCompletedOTP()
    return false
  }
  
  public func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.text = ""
    textField.backgroundColor = activeColor
    checkForCompletedOTP()
  }
  
  public func textFieldDidEndEditing(_ textField: UITextField) {
    if textField.hasText {
      textField.backgroundColor = activeColor
    } else {
      textField.backgroundColor = inactiveColor
    }
  }
  
  public func checkForCompletedOTP() {
    var otp = ""
    for tag in 1...maximumDigits {
      guard let textfield = viewWithTag(tag) as? UITextField else { continue }
      otp += textfield.text!
    }
    // if OTP is complete, i.e equals to maxDigits allowed, send finish to delegate
    if otp.count == maximumDigits {
      endEditing(true)
      delegateOTP?.didFinishEnteringOTP(otpNumber: otp)
    } else {
      delegateOTP?.otpNotValid()
    }
  }

  public func removeAllOTP() {
    for tag in 1...maximumDigits {
      if let textfield = viewWithTag(tag) as? UITextField {
        textfield.text = ""
        textfield.backgroundColor = inactiveColor
        textfield.resignFirstResponder()
      }
    }
  }
}
extension OTPInputView: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity,
         let colors = community.colors else {
      return
    }
    activeColor = colors.primary
  }
}
