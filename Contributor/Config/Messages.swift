//
//  Message.swift
//  Contributor
//
//  Created by arvindh on 13/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation

class MessageHolder: NSObject {
  var message: Message
  var customValues: [String: String] = [:]
  
  init(message: Message, customValues: [String: String] = [:]) {
    self.message = message
    self.customValues = customValues
  }

  var messageType: Message.MessageType {
    return message.messageType
  }
  
  var title: String? {
    return message.title.replaced(dict: customValues)
  }
  
  var detail: String? {
    return message.detail.replaced(dict: customValues)
  }
  
  var image: Image? {
    return message.image
  }

  var buttonTitle: String? {
    return message.buttonTitle?.replaced(dict: customValues)
  }
}

enum Message {
  case notificationPermission
  case emailValidation
  case ageRequirementNotMet
  case profileSurveyIntro
  case profileSurveyCompletion
  case surveyCompletion
  case externalSurveyCompletion
  case completeData
  case myData
  case myProfileData
  case redeemGiftCardAlert
  case redeemGiftCardSuccess
  case redeemGenericRewardAlert
  case appIntro
  case genericFetchError
  case genericActionError
  case fraudError
  case forgotPassword
  case passwordResetSuccess
  
  enum MessageType {
    case standard, error
  }

  var messageType: MessageType {
    switch self {
    case .genericFetchError, .genericActionError:
      return .error
    default:
      return .standard
    }
  }
  
  var title: String {
    switch self {
    case .appIntro:
        return "Welcome to Measure".localized()
    case .notificationPermission:
      return "Turn on notifications".localized()
    case .emailValidation:
      return "Validate your email address".localized()
    case .ageRequirementNotMet:
      return "Sorry, you must be over 18".localized()
    case .profileSurveyIntro:
      return "Hey there!".localized()
    case .profileSurveyCompletion, .surveyCompletion, .externalSurveyCompletion:
      return "Job completed".localized()
    case .completeData:
      return "Browse the latest jobs".localized()
    case .myData:
      return "Manage your data".localized()
    case .redeemGiftCardAlert:
      return "Redeem MSR".localized()
    case .redeemGiftCardSuccess:
      return "All done!".localized()
    case .redeemGenericRewardAlert:
      return "Redeem MSR".localized()
    case .forgotPassword:
      return "Forgot your password?".localized()
    case .passwordResetSuccess:
      return "Email sent".localized()
    case .myProfileData:
        return ""
    case .genericFetchError, .genericActionError:
      return "An error occurred".localized()
    case .fraudError:
      return "Your account is on hold".localized()
    }
  }
  
  var detail: String {
    switch self {
    case .appIntro:
      return ""
    case .notificationPermission:
      return "We'll send you notifications only when you qualify for new data jobs and get paid for those you complete.".localized()
    case .emailValidation:
      return "We've sent an email to the address you entered — go to your inbox now and click on the link to continue.".localized()
    case .ageRequirementNotMet:
      return "This app is only available to users who are 18 years of age or older.".localized()
    case .profileSurveyIntro:
      return "Before we get started, please tell us just a bit more about yourself, to help us tailor the Measure experience just for you.".localized()
    case .profileSurveyCompletion, .surveyCompletion:
      return "Nice work adding to your profile.".localized()
    case .externalSurveyCompletion:
      return "Nice work completing that job.".localized()
    case .completeData:
      return "In your feed you'll find a list of survey jobs and messages tailored to your profile.".localized()
    case .myData:
      return "Click on the categories below to add profile data and qualify for jobs.".localized()
    case .redeemGiftCardAlert:
      return "Are you sure you want to redeem {{AMOUNT}} using {{MSR}}?".localized()
    case .redeemGiftCardSuccess:
      return "Your redemption order is being finalized. You'll receive an email shortly with details.".localized()
    case .redeemGenericRewardAlert:
      return "Are you sure you want to redeem {{TYPE}} using {{MSR}}?".localized()
    case .forgotPassword:
      return "Enter your email address and we'll send you a password reset link.".localized()
    case .passwordResetSuccess:
      return "An email with a reset link is on the way. Check your inbox and follow the instructions.".localized()
    case .genericFetchError:
      return "Sorry, we weren't able to load the data you requested right now.".localized()
    case .genericActionError:
      return "Sorry, we weren't able to process your request right now.".localized()
    case .fraudError:
      return "Your account has been marked as a duplicate and put on hold. If you believe this is in error, contact support and we'll work with you to resolve it.".localized()
    case .myProfileData:
        return ""
    }
  }
  
  var buttonTitle: String? {
    switch self {
    case .notificationPermission:
      return "Stay notified".localized()
    case .emailValidation:
      return "Resend email".localized()
    case .ageRequirementNotMet:
      return "OK".localized()
    case .profileSurveyIntro:
      return "Let's begin".localized()
    case .profileSurveyCompletion:
      return "Next".localized()
    case .surveyCompletion, .externalSurveyCompletion:
      return "Finish".localized()
    case .redeemGiftCardSuccess:
      return "Done".localized()
    case .appIntro:
      return "Get started".localized()
    case .passwordResetSuccess:
      return "Go back".localized()
    case .genericFetchError, .genericActionError:
      return "Try again".localized()
    case .fraudError:
      return "Refresh account".localized()
    default:
      return nil
    }
  }
  
  var image: Image? {
    switch self {
    case .appIntro:
      return Image.logoPurple
    case .notificationPermission:
      return Image.notifications
    case .emailValidation:
      return Image.email
    case .ageRequirementNotMet:
      return Image.age
    case .profileSurveyCompletion, .surveyCompletion, .externalSurveyCompletion:
      return Image.surveyCompletionBadge
    case .redeemGiftCardSuccess:
      return Image.giftRedemption
    case .completeData:
      return Image.feed
    case .myData:
      return Image.myData
    case .genericFetchError, .genericActionError:
      return Image.fetchError
    case .fraudError:
      return Image.warning
    default:
      return nil 
    }
  }
}
