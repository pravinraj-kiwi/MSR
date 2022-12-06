//
//  SurveyIntro+OfferContent.swift
//  Contributor
//
//  Created by KiwiTech on 10/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension SurveyIntroViewController {
    
func updateOfferContent(_ offerItem: OfferItem) {
  jobTypeLabel.text = offerItem.offerTypeLabel
  updateEarningLabel(offerItem)
  updateExpiryLabel(offerItem)
  if let estimatedMinutes = offerItem.estimatedMinutes {
    if estimatedMinutes == 1 {
      timeLabel.text = SurveyText.minuteComplete.localized()
    } else {
      timeLabel.text = "\(estimatedMinutes) \(SurveyText.complete.localized())"
    }
  } else {
     timeLabel.isHidden = true
  }
  if let title = offerItem.title, !title.isEmpty {
    titleLabel.attributedText = title.lineSpaced(1.2)
  } else {
    titleLabel.isHidden = true
  }
  if let detail = offerItem.itemDescription, !detail.isEmpty {
    detailLabel.attributedText = detail.lineSpaced(1.2)
  } else {
    detailLabel.isHidden = true
  }
  if ConnectivityUtils.isConnectedToNetwork() == false {
     disclaimerWebView.loadHTMLString(StaticHtml().surveyStartPageHtml(),
                                      baseURL: Constants.baseContributorAPIURL)
  } else {
    if let disclaimer = offerItem.disclaimer, let url = URL(string: disclaimer) {
        var request = URLRequest(url: url)
        request.setValue(AppLanguageManager.shared.getLanguage() ?? "en", forHTTPHeaderField: "Accept-Language")
        disclaimerWebView.load(request)
      //disclaimerWebView.load(URLRequest(url: url))
    }
  }

  updateImage(offerItem)
  if offerItem.sampleRequestType != SampleRequestType.profileMaintenanceJob {
    showDeclineButton()
  }
  actionButton.setTitle(Text.startJob.localized(), for: UIControl.State.normal)
  if offerItem.isProfileMaintenanceSurvey {
    jobTypeHeadingLabel.text = SurveyText.internalSurveyTitleText.localized()
    jobTypeContentLabel.attributedText = SurveyText.internalSurveyTypeText.localized().lineSpaced(1.2)
    privacyContentLabel.attributedText = SurveyText.internalJobPrivacyText.localized().lineSpaced(1.2)
  } else {
    jobTypeHeadingLabel.text = SurveyText.externalSurveyTitleText.localized()
    jobTypeContentLabel.attributedText = SurveyText.externalSurveyTypeText.localized().lineSpaced(1.2)
    privacyContentLabel.attributedText = SurveyText.externalJobPrivacyText.localized().lineSpaced(1.2)
  }
  updateCommunity(offerItem)
}
    
func updateWelcomeUI() {
  jobTypeLabel.text = SurveyText.profileSurveyText.localized()
  hideMSRPill()
  expiryLabel.isHidden = true
  timeLabel.isHidden = true
  titleLabel.attributedText = SurveyText.profileTitleText.localized().lineSpaced(1.2)
  detailLabel.attributedText = SurveyText.profileDetailText.localized().lineSpaced(1.2)
  let widthRatio = OnboardingItemCollectionViewCell.Layout.imageWidthRatio
  let heightRatio = OnboardingItemCollectionViewCell.Layout.imageHeightRatio
  if let community = UserManager.shared.currentCommunity,
     let images = community.images,
     let welcomeCard = images.welcomeCard {
    imageView.setImageWithAssetOrURL(with: welcomeCard)
  } else {
    imageView.image = Image.onboardingPattern.value
  }
  showImage(widthRatio: widthRatio, heightRatio: heightRatio)
  actionButton.setTitle(Text.startJob.localized(), for: .normal)
  jobTypeHeadingLabel.text = SurveyText.internalSurveyTitleText.localized()
  jobTypeContentLabel.attributedText = SurveyText.dataCategorySurveyTypeText.localized().lineSpaced(1.2)
  privacyContentLabel.attributedText = SurveyText.internalJobPrivacyText.localized().lineSpaced(1.2)
 }
}
