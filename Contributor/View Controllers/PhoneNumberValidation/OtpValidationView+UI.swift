//
//  OtpValidationView+UI.swift
//  Contributor
//
//  Created by KiwiTech on 3/2/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

extension OtpValidationViewController {
    
  func updatedPhoneNumberLabel() {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 1.2
    paragraphStyle.alignment = .center

    let prefixString = OtpValidationText.phoneLabelText.localized().withAttributes([
      .textColor(UIColor(white: 156.0 / 255.0, alpha: 1.0)),
      .font(Font.regular.of(size: 18)),
      Attribute.paragraphStyle(paragraphStyle)
    ])
    let sufixString = "\(phoneNumber) ".withAttributes([
      .textColor(UIColor.black),
      .font(Font.regular.of(size: 18)),
      Attribute.paragraphStyle(paragraphStyle)
    ])
    let editString = Text.editText.localized().withAttributes([
      .textColor(Constants.primaryColor),
      .font(Font.regular.of(size: 18)),
      .underlineStyle(NSUnderlineStyle.single),
      .underlineColor(Constants.primaryColor),
      Attribute.paragraphStyle(paragraphStyle)
    ])
    let textCombination = NSMutableAttributedString()
    textCombination.append(prefixString)
    textCombination.append(sufixString)
    textCombination.append(editString)
    
    phoneNumberLabel.attributedText = textCombination
  }
  
  func addTapGestureOnLabel() {
    let tap = UITapGestureRecognizer(target: self,
                                     action: #selector(tapLabel(tap:)))
    phoneNumberLabel.addGestureRecognizer(tap)
    phoneNumberLabel.isUserInteractionEnabled = true
  }
  
  @objc func tapLabel(tap: UITapGestureRecognizer) {
   if let range = phoneNumberLabel.text?.range(of: Text.editText.localized())?.nsRange {
      if tap.didTapAttributedTextInLabel(label: phoneNumberLabel,
                                         inRange: range) {
        clickToEditNumber()
      }
    }
  }
}
