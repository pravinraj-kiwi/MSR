//
//  SupportCell+DelegateHandling.swift
//  Contributor
//
//  Created by KiwiTech on 10/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension SupportFeedbackCell {
    
 @IBAction func clickToOpenPicker(_ sender: UIButton) {
   if sender.isSelected {
    hidePicker(sender)
   } else {
    showPicker(sender)
   }
  delegate?.updateCellHeight()
 }

 @IBAction func clickToAcceptCopyOfEmail(_ sender: UIButton) {
   if sender.isSelected {
    selectedView.backgroundColor = .clear
    sender.isSelected = false
   } else {
    selectedView.backgroundColor = defaultColor
    sender.isSelected = true
  }
}
    
func resetValues() {
  feedbackMessage.text = ""
  selectedRow = 0
    buttonReason.setTitle(SupportList.reasonButtonText.localized(), for: .normal)
  buttonReason.setTitleColor(defaultColor, for: .normal)
  arrowImage.tintColor = defaultColor
  emailCopyButton.isSelected = false
  selectedView.backgroundColor = .clear
  updateSubmitButton(shouldInteract: false, opacity: 0.5)
  buttonReason.isSelected = false
  headingHeightConstraint.constant = 54
    headerTitle.text = SupportList.headerTitle.localized()
    headerSubtitle.text = SupportList.subTitte.localized()
  hideDisclaimer()
}
    
func resetValuesForWalletDetail() {
  feedbackMessage.text = ""
  selectedRow = 1
    buttonReason.setTitle(SupportList.pickerList[selectedRow].localized(), for: .normal)
  buttonReason.setTitleColor(.black, for: .normal)
  arrowImage.tintColor = .black
  emailCopyButton.isSelected = false
  selectedView.backgroundColor = .clear
  updateSubmitButton(shouldInteract: false, opacity: 0.5)
  buttonReason.isSelected = false
  headingHeightConstraint.constant = 54
  headerTitle.text = SupportList.headerTitle.localized()
  headerSubtitle.text = SupportList.subTitte.localized()
  showDisclaimer()
}
    
@IBAction func clickToSendFeedbackAgain(_ sender: UIButton) {
  if isFromWalletDetail {
    resetValuesForWalletDetail()
  } else {
    resetValues()
  }
  thankYouView.isHidden = true
  delegate?.updateCellHeight()
}

@IBAction func clickToSubmit(_ sender: UIButton) {
  feedbackMessage.resignFirstResponder()
  if isFormValid() {
    if let concern = buttonReason.currentTitle, let supportMessage = feedbackMessage.text {
        let isMailCopied = emailCopyButton.isSelected
        delegate?.clickToSubmitFeedback(concern, message: supportMessage,
                                        isEmailCopyNeeded: isMailCopied)
    }
  }
 }
}

extension SupportFeedbackCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
  guard let community = UserManager.shared.currentCommunity,
        let colors = community.colors else {
      return
  }
  defaultColor = colors.primary
  submitButton.backgroundColor = colors.primary
  disclaimerLabel.textColor = colors.primary
  thankImage.tintColor = colors.primary
  moreFeedbackButton.setTitleColor(colors.primary, for: .normal)
  feedbackMessage.tintColor = colors.primary
    submitButton.setTitle("Submit".localized(), for: .normal)
  }
}

extension SupportFeedbackCell: UITextViewDelegate {
 func textViewDidChange(_ textView: UITextView) {
    _ = isFormValid()
 }
}
