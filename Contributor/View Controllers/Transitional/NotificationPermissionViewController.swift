//
//  NotificationPermissionViewController.swift
//  Contributor
//
//  Created by arvindh on 13/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import UserNotifications
import SwiftyUserDefaults

class NotificationPermissionViewController: UIViewController {
  struct Layout {
    static let topMargin: CGFloat = 200
    static let contentMaxWidth: CGFloat = 300
    static let imageSize: CGFloat = 100
    static let imageTopMargin: CGFloat = 20
    static let imageBottomMargin: CGFloat = 40
    static let titleBottomMargin: CGFloat = 20
    static let detailBottomMargin: CGFloat = 30
    static let actionButtonBottomMargin: CGFloat = 20
    static let actionButtonWidth: CGFloat = 190
    static let actionButtonHeight: CGFloat = 44
    static let containerInset: CGFloat = 20
  }
  
  let container: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    return view
  }()

  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.backgroundColor = Constants.backgroundColor
    iv.image = Message.notificationPermission.image?.value
    return iv
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 20)
    label.backgroundColor = Constants.backgroundColor
    label.textAlignment = .center
    label.attributedText = Message.notificationPermission.title.lineSpacedAndCentered(1.2)
    return label
  }()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 18)
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.textColor = Color.lightText.value
    label.textAlignment = .center
    label.attributedText = Message.notificationPermission.detail.lineSpacedAndCentered(1.2)
    return label
  }()
  
  let actionButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.font = Font.regular.of(size: 18)
    button.setTitle(Message.notificationPermission.buttonTitle, for: .normal)
    button.layer.cornerRadius = Constants.buttonCornerRadius
    return button
  }()
  
  @objc let skipButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.font = Font.regular.of(size: 18)
    button.setTitle(Text.skipNow.localized(), for: .normal)
    return button
  }()
  
  var permissionRequested: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.checkPushNotificationPermissionStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
    
    hideBackButtonTitle()
    setupViews()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.notificationSetUpScreen)
  }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override func setupViews() {
    view.backgroundColor = Constants.backgroundColor
    
    view.addSubview(container)
    container.snp.makeConstraints { (make) in
      make.top.equalTo(view).offset(Layout.topMargin)
      make.centerX.equalTo(view)
      make.width.lessThanOrEqualTo(Layout.contentMaxWidth)
      make.left.greaterThanOrEqualToSuperview().offset(Layout.containerInset).priority(750)
      make.right.greaterThanOrEqualToSuperview().offset(-Layout.containerInset).priority(750)
    }

    container.addSubview(imageView)
    imageView.snp.makeConstraints { (make) in
      make.top.equalTo(container).offset(Layout.imageTopMargin)
      make.width.equalTo(Layout.imageSize)
      make.height.equalTo(Layout.imageSize)
      make.centerX.equalTo(container)
    }
    
    container.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(imageView.snp.bottom).offset(Layout.imageBottomMargin)
      make.centerX.equalTo(container)
      make.width.equalTo(container)
    }

    container.addSubview(detailLabel)
    detailLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(Layout.titleBottomMargin)
      make.centerX.equalTo(container)
      make.width.equalTo(container)
    }

    container.addSubview(actionButton)
    actionButton.snp.makeConstraints { (make) in
      make.top.equalTo(detailLabel.snp.bottom).offset(Layout.detailBottomMargin)
      make.width.equalTo(Layout.actionButtonWidth)
      make.height.equalTo(Layout.actionButtonHeight)
      make.centerX.equalTo(container)
    }
    actionButton.addTarget(self, action: #selector(self.requestPermission), for: UIControl.Event.touchUpInside)

    container.addSubview(skipButton)
    skipButton.snp.makeConstraints { (make) in
      make.top.equalTo(actionButton.snp.bottom).offset(Layout.actionButtonBottomMargin)
      make.width.equalTo(Layout.actionButtonWidth)
      make.centerX.equalTo(container)
      make.bottom.equalTo(container)
    }
    skipButton.addTarget(self, action: #selector(self.skipPermission), for: UIControl.Event.touchUpInside)
    
    applyCommunityTheme()
  }
  
  @objc func checkPushNotificationPermissionStatus() {

    if permissionRequested {
      // If we've requested permission and the alert has been displayed, there's no need to check for the status here, since the authorisation callback will also be called. This method is only intended to be used when we have directed the user to settings, and they change the setting there.
      return
    }
    
    UNUserNotificationCenter.current().getNotificationSettings {
      [weak self] (settings) in
      guard let this = self else {
        return
      }
      
      DispatchQueue.main.async {
        this.updateToken()
        
        if settings.authorizationStatus == .authorized {
          os_log("Already authed", log: OSLog.signUp, type: .info)
          // User has authorised, go to next step.
          let userInfo = [
            User.CodingKeys.hasDecidedNotifications: true,
            User.CodingKeys.isReceivingNotifications: true
          ]
      
          NetworkManager.shared.updateUser(userInfo) {
            [weak self] (error) in
            guard let this = self else {
              return
            }
            
            if let _ = error {
              os_log("Error updating user with notifications flags (true, true).", log: OSLog.signUp, type: .error)
            }
            this.finish()
          }
        }
      }
    }
  }
  
  @objc func requestPermission() {
    UNUserNotificationCenter.current().getNotificationSettings {
      [weak self] (settings) in
      guard let this = self else {
        return
      }
      
      DispatchQueue.main.async {
        if settings.authorizationStatus == .denied {
          // Ask user to update settings
          let alerter = Alerter(viewController: this)
          alerter.alert(
            title: NotificationPermissionAlertText.title.localized(),
            message: NotificationPermissionAlertText.message.localized(),
            confirmButtonTitle: NotificationPermissionAlertText.settings.localized(),
            cancelButtonTitle: Text.cancel.localized(),
            onConfirm: {
              if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
              }
          },
            onCancel: nil
          )
        } else {
          // Request auth
          this.permissionRequested = true
          
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {
             authorised, _ in
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
              // Add artificial delay, so that the alert is dismissed fully
              this.permissionRequested = false
              this.updateToken()
              
              if authorised {
                os_log("Notifications authorized, updating user", log: OSLog.signUp, type: .info)
                
                AnalyticsManager.shared.log(event: .notificationsEnabled)
                
                let userInfo = [
                  User.CodingKeys.hasDecidedNotifications: true,
                  User.CodingKeys.isReceivingNotifications: true
                ]
                
                NetworkManager.shared.updateUser(userInfo) {
                  [weak self] (error) in
                  guard let this = self else {
                    return
                  }
                  
                  if let _ = error {
                    os_log("Error updating user with notifications flags (true, true).", log: OSLog.signUp, type: .error)
                  }
                  this.finish()
                }
              }
              else {
                AnalyticsManager.shared.log(event: .notificationsDisabled)
              }
            })
          }
        }
      }
    }
  }
  
  func updateToken() {
    os_log("Update device token", log: OSLog.signUp, type: .info)
    PushNotificationManager.shared.updateDeviceToken()
  }
  
  @objc func skipPermission() {
    os_log("Notifications skipped, updating user", log: OSLog.signUp, type: .info)
    
    let userInfo = [
      User.CodingKeys.hasDecidedNotifications: true,
      User.CodingKeys.isReceivingNotifications: false
    ]
    
    NetworkManager.shared.updateUser(userInfo) {
      [weak self] (error) in
      guard let this = self else {
        return
      }

      if let _ = error {
        os_log("Error updating user with notifications flags (true, false).", log: OSLog.signUp, type: .error)
      }
      
      this.updateToken()
      this.finish()
    }
  }
  
  func finish() {
    Defaults[DefaultsKeys.onboardingDone] = true
    Router.shared.route(
      to: Route.emailValidation,
      from: self,
      presentationType: PresentationType.root(embedInNav: false)
    )
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension NotificationPermissionViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    actionButton.setDarkeningBackgroundColor(color: colors.primary)
    actionButton.setTitleColor(colors.background, for: .normal)
    skipButton.backgroundColor = colors.background
    skipButton.setTitleColor(colors.primary, for: .normal)
  }
}
