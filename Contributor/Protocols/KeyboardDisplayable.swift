//
//  KeyboardDisplayable.swift
//  Contributor
//
//  Created by arvindh on 24/09/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import SnapKit

protocol KeyboardDisplayable: KeyboardWrapperDelegate {
  var keyboardWrapper: KeyboardWrapper! {get set}
  var bottomConstraint: Constraint! {get set}
}

extension KeyboardDisplayable where Self: UIViewController {
  func keyboardWrapper(_ wrapper: KeyboardWrapper, didChangeKeyboardInfo info: KeyboardInfo) {
    if info.state == .willHide || info.state == .hidden {
      bottomConstraint.update(offset: 0)
    }
    else {
      bottomConstraint.update(offset: -info.endFrame.height)
    }
    
    UIView.animate(withDuration: info.animationDuration, delay: 0, options: info.animationOptions, animations: {
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    }, completion: { (_) in
      
    })
  }

}
