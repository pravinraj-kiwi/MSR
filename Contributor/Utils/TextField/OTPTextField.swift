//
//  OTPTextField.swift
//  Contributor
//
//  Created by KiwiTech on 3/24/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class OTPTextField: UITextField {
override func deleteBackward() {
  if self.text?.isEmpty ?? false {
    findPrevious()
  } else {
    super.deleteBackward()
  }
}

func removeAllText() {
   self.text = ""
}

func findPrevious() {
   if let nextField = self.superview?.viewWithTag(self.tag - 1) as? UITextField {
        nextField.becomeFirstResponder()
   } else {
      self.resignFirstResponder()
     }
   }
}
