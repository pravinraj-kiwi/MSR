//
//  AnalyticsManager.swift
//  Contributor
//
//  Created by arvindh on 11/12/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import AppsFlyerLib
import os
import SwiftyUserDefaults

enum AnalyticsEvent {
  case appIntro
  case onboarding1
  case createOrLogin
  case signUpFormDisplayed
  case ageWarningDisplayed
  case signUpFormCompleted
  case emailResent
  case validatedEmail
  case welcomeCardDisplayed
  case startPhoneValidationTapped
  case validatedPhone
  case startBasicProfileTapped
  case startLocationValidationTapped
  case finishedValidation
  case login
  case notificationsEnabled
  case notificationsDisabled
  case friendReferred
  case paidSurveyJobStarted
  case paidSurveyJobCompleted
  case makeWorkProfileJobStarted
  case makeWorkProfileJobCompleted
  case makeWorkSurveyJobStarted
  case makeWorkSurveyJobCompleted
  case selfProfileJobStarted
  case selfProfileJobCompleted
  case selfProfileMaintenanceJobStarted
  case selfProfileMaintenanceJobCompleted
  case rateSurvey

  var name: String {
    switch self {
    case .appIntro: return "app_intro"
    case .onboarding1: return "onboarding_1"
    case .createOrLogin: return "create_or_login"
    case .signUpFormDisplayed: return "sign_up_form_displayed"
    case .ageWarningDisplayed: return "age_warning_displayed"
    case .signUpFormCompleted: return AFEventCompleteRegistration
    case .emailResent: return "email_resent"
    case .validatedEmail: return "validated_email"
    case .welcomeCardDisplayed: return "welcome_card_displayed"
    case .startPhoneValidationTapped: return "start_phone_validation_tapped"
    case .validatedPhone: return "validated_phone"
    case .startBasicProfileTapped: return "start_basic_profile_tapped"
    case .startLocationValidationTapped: return "start_location_validation_tapped"
    case .finishedValidation: return AFEventTutorial_completion
    case .login: return AFEventLogin
    case .notificationsEnabled: return "notifications_enabled"
    case .notificationsDisabled: return "notifications_disabled"
    case .friendReferred: return AFEventInvite
    case .paidSurveyJobStarted: return "paid_survey_job_started"
    case .paidSurveyJobCompleted: return "paid_survey_job_completed"
    case .makeWorkProfileJobStarted: return "mw_profile_job_started"
    case .makeWorkProfileJobCompleted: return "mw_profile_job_completed"
    case .makeWorkSurveyJobStarted: return "mw_survey_job_started"
    case .makeWorkSurveyJobCompleted: return "mw_survey_job_completed"
    case .selfProfileJobStarted: return "self_profile_job_started"
    case .selfProfileJobCompleted: return "self_profile_job_completed"
    case .selfProfileMaintenanceJobStarted: return "self_maint_job_started"
    case .selfProfileMaintenanceJobCompleted: return "self_maint_job_completed"
    case .rateSurvey: return AFEventRate
    }
  }
}

class AnalyticsManager: NSObject {
  static let shared: AnalyticsManager = {
    let manager = AnalyticsManager()
    return manager
  }()
  
  override init() {
    super.init()
    addListeners()
    AppsFlyerLib.shared().appsFlyerDevKey = Constants.appsFlyerDevKey
    AppsFlyerLib.shared().appleAppID = Constants.appleAppID
    AppsFlyerLib.shared().delegate = UIApplication.shared.delegate as? AppsFlyerLibDelegate
    
    // add [App.staging, App.staging2, etc] to get debug logging in other envs
    AppsFlyerLib.shared().isDebug = [App.local,].contains(config.currentApp)
  }
  
  func addListeners() {
    NotificationCenter.default.addObserver(self, selector: #selector(onPotentialUserChange), name: .newAppVersion, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onPotentialUserChange), name: .didLogin, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onPotentialUserChange), name: .signUpFinished, object: nil)
  }
  
  @objc func onPotentialUserChange() {
    if let user = UserManager.shared.user {
      setAnalyticsUser(user.userIDForAnalytics)
    }
    updateAnalyticsID()
  }

  func updateAnalyticsID() {
    if UserManager.shared.isLoggedIn {
      let appsflyerID = AppsFlyerLib.shared().getAppsFlyerUID()
      NetworkManager.shared.updateAppsFlyerIdentifier(appsflyerID) {
        error in
        
        if let _ = error {
          os_log("Error saving the AppsFlyer ID to server.", log: OSLog.analytics, type: .error)
        }
      }
    }
  }
  
  func setAnalyticsUser(_ userID: String) {
    AppsFlyerLib.shared().customerUserID = userID
  }
  
  func trackAppLaunch() {
    AppsFlyerLib.shared().start()
  }
  
  func log(event: AnalyticsEvent, params: [String: Any] = [:]) {
    AppsFlyerLib.shared().logEvent(event.name, withValues: params)
  }

  func logOnce(event: AnalyticsEvent, params: [String: Any] = [:]) {
    if let alreadyTracked = Defaults[.trackedFunnelEvents][event.name], alreadyTracked {
      // skipping log
    } else {
      AppsFlyerLib.shared().logEvent(event.name, withValues: params)
      Defaults[.trackedFunnelEvents][event.name] = true
    }
  }
}
