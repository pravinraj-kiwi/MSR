//
//  SurveyIntro+CategoryUI.swift
//  Contributor
//
//  Created by KiwiTech on 10/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension SurveyIntroViewController {
    
func updateCategoryOfferUI(_ offerItem: OfferItem) {
  jobTypeLabel.text = offerItem.offerTypeLabel
  updateEarningLabel(offerItem)
  updateExpiryLabel(offerItem)
  if let category = surveyManager.survey?.category {
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        if let title = category.titlePt {
           titleLabel.attributedText = title.lineSpaced(1.2)
        } else {
            if let title = category.title {
               titleLabel.attributedText = title.lineSpaced(1.2)
            } else {
               titleLabel.isHidden = true
            }
        }
        if let introText = category.introTextPt {
           detailLabel.attributedText = introText.lineSpaced(1.2)
        } else {
            if let introText = category.introText {
               detailLabel.attributedText = introText.lineSpaced(1.2)
            } else {
               detailLabel.isHidden = true
            }
        }
    } else {
        if let title = category.title {
           titleLabel.attributedText = title.lineSpaced(1.2)
        } else {
           titleLabel.isHidden = true
        }
        if let introText = category.introText {
           detailLabel.attributedText = introText.lineSpaced(1.2)
        } else {
           detailLabel.isHidden = true
        }
    }
     
  }
  updateImage(offerItem)
  showDeclineButton()
  actionButton.setTitle(Text.startJob.localized(), for: UIControl.State.normal)
    jobTypeHeadingLabel.text = SurveyText.internalSurveyTitleText.localized()
  jobTypeContentLabel.attributedText = SurveyText.internalSurveyTypeText.localized().lineSpaced(1.2)
  privacyContentLabel.attributedText = SurveyText.internalJobPrivacyText.localized().lineSpaced(1.2)
  if ConnectivityUtils.isConnectedToNetwork() == false {
    disclaimerWebView.loadHTMLString(StaticHtml().surveyStartPageHtml(),
                                     baseURL: Constants.baseContributorAPIURL)
  } else {
     if let disclaimer = offerItem.disclaimer, let url = URL(string: disclaimer) {
        var request = URLRequest(url: url)
        request.setValue(AppLanguageManager.shared.getLanguage() ?? "en", forHTTPHeaderField: "Accept-Language")
        disclaimerWebView.load(request)
       // disclaimerWebView.load(URLRequest(url: url))
     }
  }
}
    
func updateCategoryData(_ category: SurveyCategory) {
  jobTypeLabel.text = SurveyText.profileSurveyText.localized()
  expiryLabel.isHidden = true
  timeLabel.isHidden = true
  hideMSRPill()
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        if let titlePt = category.titlePt {
            titleLabel.attributedText = titlePt.lineSpaced(1.2)
        } else {
            titleLabel.attributedText = category.title.lineSpaced(1.2)
        }
        if let introText = category.introTextPt {
          detailLabel.attributedText = introText.lineSpaced(1.2)
        } else {
            if let introText = category.introText {
              detailLabel.attributedText = introText.lineSpaced(1.2)
            } else {
              detailLabel.isHidden = true
            }
          //detailLabel.isHidden = true
        }
    } else {
        titleLabel.attributedText = category.title.lineSpaced(1.2)
        if let introText = category.introText {
          detailLabel.attributedText = introText.lineSpaced(1.2)
        } else {
          detailLabel.isHidden = true
        }
    }
  
  actionButton.setTitle(Text.startJob.localized(), for: UIControl.State.normal)
  if let url = category.imageURL {
    imageView.kf.setImage(with: url)
  }
  let color1 = colorListLight[category.order % colorListLight.count].value
  let color2 = colorList[category.order % colorList.count].value
  updateGradientColors(color1: color1, color2: color2)
  showCategoryImage()
  jobTypeHeadingLabel.text = SurveyText.internalSurveyTitleText.localized()
  jobTypeContentLabel.attributedText = SurveyText.dataCategorySurveyTypeText.localized().lineSpaced(1.2)
  privacyContentLabel.attributedText = SurveyText.internalJobPrivacyText.localized().lineSpaced(1.2)
  }
}
