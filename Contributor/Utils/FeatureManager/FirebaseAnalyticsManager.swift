//
//  FirebaseAnalyticsManager.swift
//  Contributor
//
//  Created by KiwiTech on 11/25/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum FirebaseScreenView {
  case introScreen
  case onboardingScreen
  case landingScreen
  case signInScreen
  case signUpScreen
  case feedScreen
  case myDataScreen
  case walletScreen
  case settingScreen
  case supportScreen
  case startJobScreen
  case exitJobScreen
  case jobStatusScreen(status: String)
  case transactionDetailScreen(type: String)
  case redeemGiftScreen
  case profileCategoryExitScreen
  case surveyPartnerConnectScreen(name: String)
  case surveyPartnerDetailScreen(name: String)
  case profileValidationConnectScreen(name: String)
  case myAttributeDetailScreen
  case privacyPolicyScreen
  case termsConditionScreen
  case faqScreen
  case personalDetailScreen
  case changePasswordScreen
  case phoneValidationScreen
  case verifyOtpScreen
  case welcomeScreen
  case emailVerificationScreen
  case forgotPasswordScreen
  case notificationSetUpScreen
  case fraudScreen
  case maintScreen
  case appValidationSuccessScreen(appName: String)
  case appValidationFailureScreen(appName: String)
  case referFriend
  case connectAppType(connectType: String)
  case changeLanguage
    
  var screenName: String {
    switch self {
    case .introScreen: return "INTRO"
    case .onboardingScreen: return "ONBOARDING"
    case .landingScreen: return "LANDING"
    case .signInScreen: return "LOGIN"
    case .signUpScreen: return "SIGN_UP"
    case .feedScreen: return "FEED"
    case .myDataScreen: return "MY_DATA"
    case .walletScreen: return "WALLET"
    case .settingScreen: return "SETTINGS"
    case .supportScreen: return "SUPPORT_PAGE"
    case .startJobScreen: return "START_JOB"
    case .exitJobScreen: return "EXIT_JOB"
    case .jobStatusScreen(let status): return "EXIT_JOB_\(status)"
    case .transactionDetailScreen(let type): return "TRANSACTION_DETAILS_\(type)"
    case .redeemGiftScreen: return "REDEEM_GIFT_CARD"
    case .profileCategoryExitScreen: return "PROFILE_CATEGORY_EXIT"
    case .surveyPartnerConnectScreen(let name): return "SP_\(name)_CONNECT"
    case .surveyPartnerDetailScreen(let name): return "SP_\(name)_DETAILS"
    case .profileValidationConnectScreen(let name): return "PV_\(name)_CONNECT"
    case .myAttributeDetailScreen: return "MY_ATTRIBUTES_DETAILS"
    case .privacyPolicyScreen: return "PRIVACY_POLICY"
    case .termsConditionScreen: return "TERMS_AND_CONDITIONS"
    case .faqScreen: return "FAQ_SCREEN"
    case .personalDetailScreen: return "PERSONAL_DETAILS"
    case .changePasswordScreen: return "CHANGE_PASSWORD"
    case .phoneValidationScreen: return "PHONE_VALIDATION"
    case .verifyOtpScreen: return "VERIFY_OTP"
    case .welcomeScreen: return "WELCOME_CARD"
    case .emailVerificationScreen: return "EMAIL_VERIFICATION"
    case .forgotPasswordScreen: return "FORGOT_PASSWORD"
    case .notificationSetUpScreen: return "SETUP_APP_NOTIFICATIONS"
    case .fraudScreen: return "FRAUD_PAGE"
    case .maintScreen: return "MAINTENANCE_PAGE"
    case .appValidationSuccessScreen(let appName): return "PV_\(appName)_CONNECT_SUCCESS"
    case .appValidationFailureScreen(let appName): return "PV_\(appName)_CONNECT_FAILURE"
    case .referFriend: return "REFER_FRIEND"
    case .connectAppType(let connectType): return "\(connectType)_APPS"
    case .changeLanguage : return "Select Preferred Language"
    }
  }
}

class FirebaseAnalyticsManager: NSObject {
  static let shared: FirebaseAnalyticsManager = {
     let manager = FirebaseAnalyticsManager()
     return manager
  }()
        
  func logFirebaseAnalytics(_ screen: FirebaseScreenView) {
    Analytics.logEvent(Constants.kScreenKey,
                       parameters: [Constants.kOpenScreenKey: screen.screenName.uppercased()])
  }
}
