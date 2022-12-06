//
//  SupportFeedbackCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol SupportDelegate: class {
  func updateCellHeight()
  func clickToSubmitFeedback(_ concern: String, message: String,
                             isEmailCopyNeeded: Bool)
}

class SupportFeedbackCell: UITableViewCell {

 @IBOutlet weak var buttonReason: UIButton!
 @IBOutlet weak var reasonPickerView: UIPickerView!
 @IBOutlet weak var arrowImage: UIImageView!
 @IBOutlet weak var disclaimerLabel: UILabel!
 @IBOutlet weak var diclaimerImage: UIImageView!
 @IBOutlet weak var feedbackMessage: UITextView!
 @IBOutlet weak var emailCopyButton: UIButton!
 @IBOutlet weak var submitButton: UIButton!
 @IBOutlet weak var outerView: UIView!
 @IBOutlet weak var selectedView: UIView!
 @IBOutlet weak var pickerView: UIView!
 @IBOutlet weak var thankYouView: UIView!
 @IBOutlet weak var pickerHeightConstraint: NSLayoutConstraint!
 @IBOutlet weak var disclaimerHeightConstraint: NSLayoutConstraint!
 @IBOutlet weak var feedbackTopConstraint: NSLayoutConstraint!
 @IBOutlet weak var dividerView: UIView!
 @IBOutlet weak var thankImage: UIImageView!
 @IBOutlet weak var moreFeedbackButton: UIButton!
 @IBOutlet weak var headingHeightConstraint: NSLayoutConstraint!
 @IBOutlet weak var headerTitle: UILabel!
 @IBOutlet weak var headerSubtitle: UILabel!
@IBOutlet weak var yesPleaseTitle: UILabel!

 weak var delegate: SupportDelegate?
 var isPickerOpened = false
 var selectedRow = 0
 var defaultColor = Color.primary.value
 let radius = SupportList.pickerRadius
 let textInset = UIEdgeInsets(top: 13, left: 12, bottom: 13, right: 12)
 var isFromWalletDetail = false
    
 override func awakeFromNib() {
   super.awakeFromNib()
   // Initialization code
    NotificationCenter.default.addObserver(self, selector: #selector(updateThankYouView),
                                           name: NSNotification.Name.showSupportThankView, object: nil)
    thankYouView.isHidden = true
    yesPleaseTitle.text = SupportList.yesPlease.localized()
    applyCommunityTheme()
 }

 override func setSelected(_ selected: Bool, animated: Bool) {
   super.setSelected(selected, animated: animated)
   // Configure the view for the selected state
}
    
@objc func updateThankYouView() {
  thankYouView.isHidden = false
}
    
override func layoutSubviews() {
  super.layoutSubviews()
  if isPickerOpened {
    pickerView.roundCorners(corners: [.topLeft, .topRight], radius: radius)
  } else {
    pickerView.layer.cornerRadius = radius
  }
  reasonPickerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: radius)
}

func updateTextViewUI() {
    feedbackMessage.placeholder = SupportList.placeholderText.localized()
  feedbackMessage.placeholderColor = Utilities.getRgbColor(102, 102, 102)
  feedbackMessage.textColor = .black
  feedbackMessage.textContainerInset = textInset
  feedbackMessage.delegate = self
}

func updatePickerUI() {
  reasonPickerView.delegate = self
  reasonPickerView.dataSource = self
  reasonPickerView.reloadAllComponents()
  if isFromWalletDetail {
    selectedRow = 1
    buttonReason.setTitle(SupportList.pickerList[selectedRow].localized(), for: .normal)
    buttonReason.setTitleColor(.black, for: .normal)
    arrowImage.tintColor = .black
  } else {
    selectedRow = -1
    buttonReason.setTitle(SupportList.reasonButtonText.localized(), for: .normal)
    buttonReason.setTitleColor(defaultColor, for: .normal)
    arrowImage.tintColor = defaultColor
  }
  hidePicker(buttonReason)
}

func updateInitialUI() {
  updateTextViewUI()
  updatePickerUI()
  arrowImage.image = Image.iconBottom.value
  reasonPickerView.delegate = self
  reasonPickerView.dataSource = self
  reasonPickerView.reloadAllComponents()
  outerView.layer.borderWidth = 1
  updateSubmitButton(shouldInteract: false, opacity: 0.5)
  outerView.layer.borderColor = Utilities.getRgbColor(0, 0, 0, 0.15).cgColor
    headerTitle.text = SupportList.headerTitle.localized()
    headerSubtitle.text = SupportList.subTitte.localized()
}

func showPicker(_ sender: UIButton) {
 reasonPickerView.isHidden = false
 arrowImage.image = Image.iconUp.value
 pickerHeightConstraint.constant = SupportList.pickerHeightConstant
 buttonReason.setTitleColor(.black, for: .normal)
 arrowImage.tintColor = .black
 updatePickerWhenOpen()
 dividerView.isHidden = false
 pickerView.layer.cornerRadius = 0.0
 isPickerOpened = true
 sender.isSelected = true
}
    
func updatePickerWhenOpen() {
  if selectedRow != -1 {
    buttonReason.setTitle(SupportList.pickerList[selectedRow].localized(), for: .normal)
    reasonPickerView.selectRow(selectedRow, inComponent: 0, animated: false)
  } else {
    buttonReason.setTitle(SupportList.pickerList[0].localized(), for: .normal)
    reasonPickerView.selectRow(0, inComponent: 0, animated: false)
  }
  DispatchQueue.main.async {
    self.reasonPickerView.reloadAllComponents()
  }
}

func showDisclaimer() {
 disclaimerHeightConstraint.constant = 34
 feedbackTopConstraint.constant = 16
 disclaimerLabel.isHidden = false
 diclaimerImage.isHidden = false
    disclaimerLabel.text = SupportList.disclaimerText.localized()
}
    
func hideDisclaimer() {
 disclaimerHeightConstraint.constant = 0
 feedbackTopConstraint.constant = 0
 disclaimerLabel.isHidden = true
 diclaimerImage.isHidden = true
 disclaimerLabel.text = ""
}

func hidePicker(_ sender: UIButton) {
 reasonPickerView.isHidden = true
 arrowImage.image = Image.iconBottom.value
 pickerHeightConstraint.constant = 0
 feedbackTopConstraint.constant = 0
 isPickerOpened = false
 dividerView.isHidden = true
 sender.isSelected = false
 if selectedRow != -1 {
    buttonReason.setTitle(SupportList.pickerList[selectedRow].localized(), for: .normal)
    buttonReason.setTitleColor(.black, for: .normal)
    arrowImage.tintColor = .black
 } else {
    buttonReason.setTitleColor(defaultColor, for: .normal)
    arrowImage.tintColor = defaultColor
 }
    if buttonReason.currentTitle == SupportList.pickerList[1].localized() {
    showDisclaimer()
 } else {
    hideDisclaimer()
 }
 _ = isFormValid()
}
    
func updateSubmitButton(shouldInteract interact: Bool, opacity: Float) {
  submitButton.isUserInteractionEnabled = interact
  submitButton.layer.opacity = opacity
}
    
func isFormValid() -> Bool {
    if !feedbackMessage.text.isEmpty && buttonReason.currentTitle != SupportList.reasonButtonText.localized() {
    updateSubmitButton(shouldInteract: true, opacity: 1.0)
    return true
  }
  updateSubmitButton(shouldInteract: false, opacity: 0.5)
  return false
  }
}
