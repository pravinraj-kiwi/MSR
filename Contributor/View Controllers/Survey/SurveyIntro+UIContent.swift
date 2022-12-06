//
//  SurveyIntro+UIContent.swift
//  Contributor
//
//  Created by KiwiTech on 10/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

extension SurveyIntroViewController {
    
func updateContent() {
  switch surveyManager.surveyType {
  case .externalOffer(let offerItem),
       .embeddedOffer(let offerItem, _):
    updateOfferContent(offerItem)
    
  case .categoryOffer(let offerItem, _):
    updateCategoryOfferUI(offerItem)
    
  case .category(let category):
    updateCategoryData(category)
    
  case .welcome:
    updateWelcomeUI()
  }
  setStackViewMargins()
}
    
func updateCommunity(_ offerItem: OfferItem) {
  var community: Community? = nil
  if let slug = offerItem.communitySlug {
    community = UserManager.shared.user?.getCommunityForSlug(slug: slug)
  } else {
    if UserManager.shared.user?.communities.count == 1
            && !UserManager.shared.isDefaultCommunity {
       community = UserManager.shared.currentCommunity
    }
  }
 if let community = community {
    jobTypeLabel.text = SurveyText.communitySurvey.localized()
    jobTypeHeadingLabel.text = SurveyText.communityJobTitleText.localized()
   if let introBlurb = community.text.introBlurb {
     jobTypeContentLabel.attributedText = introBlurb.lineSpaced(1.2)
   }
   privacyContentLabel.attributedText = SurveyText.communityJobPrivacyText.localized().lineSpaced(1.2)
     if community.text.privacyPolicyURL != nil {
       communityPrivacyPolicyButton.isHidden = false
     }
     if community.text.termsOfServiceURL != nil {
       communityTermsOfServiceButton.isHidden = false
     }
     if community.text.accessibilityURL != nil {
       communityAccessibilityButton.isHidden = false
     }
     if community.text.contactURL != nil {
        communityContactButton.isHidden = false
     }
   }
}
    
func updateExpiryLabel(_ offerItem: OfferItem) {
  if let expiryString = offerItem.expiryString,
     let minutesUntilExpiry = offerItem.minutesUntilExpiry {
    if minutesUntilExpiry < 60 {
        let prefix = SurveyText.expiresIn.localized().withAttributes([
          Attribute.font(Font.regular.of(size: 16)),
          Attribute.textColor(Color.lightText.value)
        ])
        
        let suffix = expiryString.withAttributes([
          Attribute.font(Font.regular.of(size: 16)),
          Attribute.textColor(UIColor.red)
        ])
        expiryLabel.attributedText = prefix + suffix
     } else {
        expiryLabel.text = "\(SurveyText.expires.localized()) \(expiryString)"
     }
  } else {
     expiryLabel.isHidden = true
  }
}

func updateImage(_ offerItem: OfferItem) {
  if let url = offerItem.imageURL {
    imageView.kf.setImage(with: url)
    switch offerItem.layoutType {
    case .topImage1x1:
     showImage(widthRatio: 1.0, heightRatio: 1.0)
    case .topImage2x1:
     showImage(widthRatio: 2.0, heightRatio: 1.0)
    case .topImage3x1:
     showImage(widthRatio: 3.0, heightRatio: 1.0)
    default:
     hideImage()
       }
   } else {
      hideImage()
   }
}
    
func updateEarningLabel(_ offerItem: OfferItem) {
  if offerItem.estimatedEarnings > 0 {
    msrLabel.text = offerItem.estimatedEarnings.formattedMSRString
  } else {
    hideMSRPill()
  }
 }
}
