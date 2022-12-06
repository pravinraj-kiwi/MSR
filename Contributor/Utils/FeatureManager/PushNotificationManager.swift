//
//  PushNotificationManager.swift
//  Contributor
//
//  Created by arvindh on 13/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import UserNotifications
import FirebaseMessaging
import SwiftyUserDefaults

class PushNotificationManager: NSObject, MessagingDelegate {
  static let shared: PushNotificationManager = {
    let manager = PushNotificationManager()
    return manager
  }()

  let notificationStatusCheckInterval: TimeInterval = 3600 * 6 // 6 hours

  override init() {
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(onNewAppVersion(_:)), name: NSNotification.Name.newAppVersion, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onDidLogin(_:)), name: NSNotification.Name.didLogin, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onSignUp), name: .signUpFinished, object: nil)
  }
  
  var token: String? {
    didSet {
      updateDeviceToken()
    }
  }

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
     self.token = fcmToken
  }
    
  func callDeviceTokenUpdation(token: String) {
     NetworkManager.shared.updateDeviceToken(token) {
        error in
      if let error = error {
         os_log("Error updating device token: %{public}@", log: OSLog.pushNotificationManager, type: .error, error.localizedDescription)
        }
     }
  }
  
  func updateDeviceToken() {
    guard UserManager.shared.isLoggedIn, let _ = Defaults[.loggedInUserAccessToken] else {
      return
    }
    if let token = token {
      callDeviceTokenUpdation(token: token)
    } else {
       if let savedDeviceToken = Defaults[.currentDeviceToken] {
          callDeviceTokenUpdation(token: savedDeviceToken)
        }
    }
    Defaults[.currentDeviceToken] = token
  }
  
  @objc func onDidLogin(_ notification: Notification) {
    updateDeviceToken()
  }

  @objc func onNewAppVersion(_ notification: Notification) {
    updateDeviceToken()
  }
    
  @objc func onSignUp() {
    updateDeviceToken()
  }
  
  func updateNotificationStatus() {
    if !UserManager.shared.isLoggedIn {
      os_log("Skipping notification flag update, no logged in user.", log: OSLog.pushNotificationManager, type: .info)
      return
    }
    
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { (settings) in
      let lastCheck = Defaults[.previousNotificationStatusCheck]
      let date = Date()
      
      let update = {
        (authorizationStatus: UNAuthorizationStatus) in
        
        let isAuthorised = [UNAuthorizationStatus.authorized, UNAuthorizationStatus.provisional].contains(authorizationStatus)
        let userInfo: [User.CodingKeys: Any] = [
          User.CodingKeys.isReceivingNotifications: isAuthorised
        ]
        
        NetworkManager.shared.updateUser(userInfo) {
          [weak self] (error) in
          
          if let error = error {
            os_log("Error updating user with notifications flags: %{public}@", log: OSLog.notifications, type: .error, error.localizedDescription)
          } else {
            Defaults[.previousNotificationStatusCheck] = NotificationStatusCheck(date: Date(), status: settings.authorizationStatus.rawValue)
          }
        }
      }
      
      if let check = lastCheck {
        if date.timeIntervalSince(check.date) > self.notificationStatusCheckInterval && settings.authorizationStatus.rawValue != check.status {
          update(settings.authorizationStatus)
        }
      } else {
        // No previous check
        update(settings.authorizationStatus)
      }
    }
  }
}
