//
//  FormAcceptanceCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/6/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

protocol FormAcceptanceDelegate: class {
 func clickToOpenTerms()
 func clickoOpenPrivacy()
 func acceptedTermsCondition(_ isSelected: Bool)
}

class FormAcceptanceCell: UITableViewCell {
    
@IBOutlet weak var termLabel: UILabel!
@IBOutlet weak var acceptanceButton: UIButton!
@IBOutlet weak var acceptedView: UIView!
@IBOutlet weak var outerView: UIView!
var screenType: ScreenType = .personalDetail
weak var acceptanceDelegate: FormAcceptanceDelegate?
var defaultColor = Color.primary.value

 override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    outerView.layer.borderWidth = 1
    outerView.layer.borderColor = Utilities.getRgbColor(0, 0, 0, 0.15).cgColor
    applyCommunityTheme()
    addTapGestureOnLabel()
}
    
@IBAction func clickToAcceptTerms(_ sender: UIButton) {
  if sender.isSelected {
    acceptedView.backgroundColor = .clear
    sender.isSelected = false
  } else {
    acceptedView.backgroundColor = defaultColor
    sender.isSelected = true
  }
  acceptanceDelegate?.acceptedTermsCondition(sender.isSelected)
}
    
func addTapGestureOnLabel() {
  let tap = UITapGestureRecognizer(target: self,
                                      action: #selector(acceptanceButtonClicked(tap:)))
  termLabel.addGestureRecognizer(tap)
  termLabel.isUserInteractionEnabled = true
}
   
@objc func acceptanceButtonClicked(tap: UITapGestureRecognizer) {
   if let range = termLabel.text?.range(of: Text.privacy.localized())?.nsRange {
    if tap.didTapAttributedTextInLabel(label: termLabel,
                                       inRange: range) {
            acceptanceDelegate?.clickoOpenPrivacy()
        }
    }
    if let range = termLabel.text?.range(of: Text.termsCondition.localized())?.nsRange {
        if tap.didTapAttributedTextInLabel(label: termLabel,
                                           inRange: range) {
            acceptanceDelegate?.clickToOpenTerms()
        }
      }
    if let range = termLabel.text?.range(of: Text.registeredEmail.localized())?.nsRange {
        if tap.didTapAttributedTextInLabel(label: termLabel,
                                           inRange: range) {
            acceptanceDelegate?.clickToOpenTerms()
        }
      }
   }
}

extension FormAcceptanceCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
   if let community = UserManager.shared.currentCommunity,
      let colors = community.colors {
       defaultColor = colors.primary
    }
    updateUI()
  }
    func updateUI() {
        var termsAttributedText = Text.termsText.localized().lineSpaced(4.0, with: Font.regular.of(size: 15))
        let linkFontAttributes = [
          Attribute.textColor(defaultColor),
          Attribute.underlineStyle(.single),
          Attribute.underlineColor(defaultColor)
        ]
        if screenType == .redeemScreen {
            termsAttributedText = Text.redmeemPaypalText.localized().lineSpaced(4.0, with: Font.regular.of(size: 15))
            let links = [Text.registeredEmail.localized()]
            termsAttributedText.addAttributesToTerms(linkFontAttributes, to: links)
        } else {
            
            let links = [Text.termsCondition.localized(), Text.privacy.localized()]
            termsAttributedText.addAttributesToTerms(linkFontAttributes, to: links)
        }
       
        termLabel.attributedText = termsAttributedText
    }
}
