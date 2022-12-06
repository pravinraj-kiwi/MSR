//
//  PayPalFormHeader.swift
//  Contributor
//
//  Created by Shashi Kumar on 09/03/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

protocol PayPalFormHeaderDelegate: class {
    func clickToWebSiteDetails()
}
class PayPalFormHeader: UIView {
    @IBOutlet weak var text1Label: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    var defaultColor = Color.primary.value
    weak var headerDelegate: PayPalFormHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyCommunityTheme()
        addTapGestureOnLabel()
    }
    func addTapGestureOnLabel() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(acceptanceButtonClicked(tap:)))
        text1Label.addGestureRecognizer(tap)
        text1Label.isUserInteractionEnabled = true
    }
    @objc func acceptanceButtonClicked(tap: UITapGestureRecognizer) {
        
        if let range = text1Label.text?.range(of: Text.websiteDetail.localized())?.nsRange {
            if tap.didTapAttributedTextInLabel(label: text1Label,
                                               inRange: range) {
                headerDelegate?.clickToWebSiteDetails()
            }
        }
    }
}
extension PayPalFormHeader: CommunityThemeConfigurable {
    @objc func applyCommunityTheme() {
        if let community = UserManager.shared.currentCommunity,
           let colors = community.colors {
            defaultColor = colors.primary
        }
        updateUI()
    }
    func updateUI() {
        let termsAttributedText = Text.websiteDetailPayPalText.localized().lineSpaced(4.0, with: Font.bold.of(size: 15))
        let linkFontAttributes = [
            Attribute.textColor(defaultColor),
            Attribute.underlineStyle(.single),
            Attribute.underlineColor(defaultColor)
        ]
        
        let links = [Text.websiteDetail.localized()]
        termsAttributedText.addAttributesToTerms(linkFontAttributes, to: links)
        
        text1Label.attributedText = termsAttributedText
        descLabel.text = Text.paypalDesc.localized()
    }
}
