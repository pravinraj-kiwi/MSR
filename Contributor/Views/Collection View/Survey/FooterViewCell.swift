//
//  FooterViewCell.swift
//  Contributor
//
//  Created by KiwiTech on 11/24/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol FooterViewDelegate: class {
  func clickOtherReason()
  func clickToExit()
}

class FooterViewCell: UICollectionViewCell {
    
 @IBOutlet weak var OtherButton: UIButton!
 @IBOutlet weak var OtherReasonTextView: UITextView!
 @IBOutlet weak var exitButton: UIButton!
 @IBOutlet weak var textViewHeight: NSLayoutConstraint!
 @IBOutlet weak var otherViewHeight: NSLayoutConstraint!
 @IBOutlet weak var otherText: UILabel!
 @IBOutlet weak var OtherView: UIView!
    
 weak var delegate: FooterViewDelegate?
 var themeColor: UIColor = Constants.primaryColor
    
func updateFooterCell() {
 applyCommunityTheme()
 OtherView.layer.borderColor = themeColor.cgColor
 OtherView.layer.borderWidth = 2
 OtherView.layer.cornerRadius = 8.0
 OtherReasonTextView.delegate = self
 OtherView.layer.cornerRadius = 8.0
 OtherView.backgroundColor = .white
 exitButton.alpha = 0.5
 exitButton.isUserInteractionEnabled = false
 otherText.textColor = themeColor
    OtherReasonTextView.placeholder = "Please explain exit reason".localized()
 OtherReasonTextView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
 OtherReasonTextView.keyboardDistanceFromTextField = 160
 hideOtherView()
}
    
func showOtherView() {
 textViewHeight.constant = 93
 otherViewHeight.constant = 0
 otherText.isHidden = false
 OtherReasonTextView.isHidden = false
 OtherButton.isHidden = true
 OtherReasonTextView.text = nil
}                                                     
    
func hideOtherView() {
 textViewHeight.constant = 0
 otherViewHeight.constant = 45
 otherText.isHidden = true
 OtherReasonTextView.isHidden = true
 OtherButton.isHidden = false
}
 
@IBAction func clickToOtherView(_ sender: Any) {
  exitButton.alpha = 0.5
  exitButton.isUserInteractionEnabled = false
  showOtherView()
  OtherReasonTextView.becomeFirstResponder()
  delegate?.clickOtherReason()
}
    
 @IBAction func clickToExit(_ sender: Any) {
    delegate?.clickToExit()
 }
}

extension FooterViewCell: UITextViewDelegate {
func textViewDidChange(_ textView: UITextView) {
    if textView.text.isEmpty {
        exitButton.alpha = 0.5
        exitButton.isUserInteractionEnabled = false
    } else {
        exitButton.alpha = 1.0
        exitButton.isUserInteractionEnabled = true
    }
}
    
func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    // as @nhgrif suggested, we can skip the string manipulations if
    // the beginning of the textView.text is not touched.
    guard range.location == 0 else {
        return true
    }

    let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
    return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
 }
}

extension FooterViewCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity,
         let colors = community.colors else {
      return
    }
    themeColor = colors.primary
    exitButton.backgroundColor = colors.primary
    exitButton.setTitle("Exit".localized(), for: .normal)
  }
}
