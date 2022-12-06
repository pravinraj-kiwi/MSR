//
//  Image.swift
//  Contributor
//
//  Created by arvindh on 21/06/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import UIKit

enum Image: String {

  case logo
  case logoPurple
  case logoGray
  case filePlaceholder
  case shapesGray
  case shapesColored
  case arrow
  case chevron
  case error
  case warning
  case privacy
  case survey
  case linkedin
  case facebook
  case dynata
  case surveyPartner
  case profileValidation
  case bitmap
  case backward
  case backicon
  case dynataLogo
  case linkedInLogo
  case fbLogo
  case checkmark
  case profileValidate
  case pollfish
  case pollfishLogo
  case kantar
  case kantarLogo
  case precisionSample
  case precisionSampleLogo
  case measureLocal
  case measureProd
  case measureStage
  case walletpollfish
  case walletkantar
  case walletcint
  case walletmsr
  case walletdynata
  case checkIcon
  case addIcon
  case surveyCompletionBadge
  case completedJob
  case disqualifiedJob
  case inReviewJob
  case giftRedemption
  case dummyProfile
  case settingIcon
  case starEmpty, starFull
  case time, feedArrow, feedCheck, rightDottedArrow, opener
  case onboardingPattern, validationSuccess, validationFailure, validationEmpty
  case emptyTab, emptyTabHighlighted
  case feedTab, data, wallet, settings
  case feedIcon, myDataIcon, walletIcon, settingsIcon
  case feed, myData
  case notifications, email, age, fetchError
  case location, health, amazon, spotify
  case launch
  case onboarding1, onboarding2, onboarding3, onboarding4
  case iconUp
  case iconBottom
  case fiftyRedeem, tenRedeem, twentyRedeem, crossWhite
  case paypal, tick, whiteCross
    
  var value: UIImage {
    if let image = UIImage(named: self.rawValue) {
      return image
    }
    return UIImage()
  }
}
