//
//  AppDelegate+Deeplink.swift
//  Contributor
//
//  Created by KiwiTech on 9/21/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import AZTabBar
import FirebaseMessaging
import AppsFlyerLib
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
extension AppDelegate: AppsFlyerLibDelegate {
    
func handleOfferNotifications(_ userInfo: [AnyHashable: Any], _ goToTarget: Bool, _ isNotifPresented: Bool) {
 guard let offerID = userInfo["offer_id"] as? String else {
   return
 }

 if goToTarget {
   guard let tabViewController = tabViewController else {
      return
  }
  
  let index = tabs.order.firstIndex(of: Tabs.Tab.feed) ?? 0
  tabViewController.setIndex(index)
}

let itemInfo: [String: Any] = [
  "offerID": offerID,
  "goToTarget": goToTarget,
  "notificationPresented": isNotifPresented
]

 if isNotifPresented {
   Defaults[.notifAppeared] = true
   NotificationCenter.default.post(name: NSNotification.Name.updatedFeedOnServer, object: nil, userInfo: itemInfo)
 } else {
   NotificationCenter.default.post(name: NSNotification.Name.deeplinkFeedOffer, object: nil, userInfo: itemInfo)
  }
 }
    
func handlePaymentDeeplink(_ userInfo: [AnyHashable: Any], _ goToTarget: Bool, _ isNotifPresented: Bool) {
 var sampleRequestID: Int = 0
 if let sampleId = userInfo["sample_request_id"] as? String, let sampleIdInteger = Int(sampleId) {
   sampleRequestID = sampleIdInteger
 }

 guard let transactionID = Int(userInfo["transaction_id"] as? String ?? "") else {
   return
 }

 if goToTarget {
  guard let tabViewController = tabViewController else {
      return
  }
  
  let index = tabs.order.firstIndex(of: Tabs.Tab.wallet) ?? 0
  tabViewController.setIndex(index)
}

let paymentInfo: [String: Any] = [
  "sampleRequestID": sampleRequestID,
  "transactionID": transactionID,
  "notificationPresented": isNotifPresented
]

NetworkManager.shared.reloadCurrentUser {_ in }
if isNotifPresented {
  NotificationCenter.default.post(name: NSNotification.Name.paymentReceived, object: nil, userInfo: paymentInfo)
}
NotificationCenter.default.post(name: NSNotification.Name.updatedFeedOnServer, object: nil, userInfo: nil)
}
    
func handleQualifyDeeplink(_ userInfo: [AnyHashable: Any], _ isNotifPresented: Bool) {
 if isNotifPresented {
    return
 }
 guard let transactionID = Int(userInfo["transaction_id"] as? String ?? "") else {
      return
 }
 let paymentInfo: [String: Any] = [
    "transactionID": transactionID
 ]
 NotificationCenter.default.post(name: NSNotification.Name.paymentDetail, object: nil, userInfo: paymentInfo)
}
        
func onConversionDataFail(_ error: Error) {  }
func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {}
func onAppOpenAttributionFailure(_ error: Error) {  }

}

extension AppDelegate: CommunityThemeConfigurable {
func applyCommunityThemeToTabBar(tabViewController: AZTabBarController) {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
        return
    }
    tabViewController.view.backgroundColor = colors.background
    tabViewController.buttonsBackgroundColor = colors.lightBackground
    tabViewController.defaultColor = colors.unselected
    tabViewController.selectedColor = colors.primary
}

@objc func applyCommunityTheme() {
    if let tabViewController = tabViewController {
        applyCommunityThemeToTabBar(tabViewController: tabViewController)
    }
}
}
extension AppDelegate: customPopDelegate {}

extension AppDelegate: UNUserNotificationCenterDelegate {

func procesNotification(userInfo: [AnyHashable: Any], goToTarget: Bool, isNotificationPresented: Bool) {
    guard let notificationTypeString = userInfo["notification_type"] as? String else {
        return
    }
    guard let notificationType = VisibleNotificationType(rawValue: notificationTypeString) else {
        return
    }
    switch notificationType {
    case .offer:
        handleOfferNotifications(userInfo, goToTarget, isNotificationPresented)
    case .payment:
        handlePaymentDeeplink(userInfo, goToTarget, isNotificationPresented)
    case .quality:
        handleQualifyDeeplink(userInfo, isNotificationPresented)
    }
}

func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    procesNotification(userInfo: userInfo, goToTarget: false, isNotificationPresented: true)
    completionHandler([.alert, .sound, .badge])
}

func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    guard let notificationTypeString = userInfo["notification_type"] as? String else {
        return
    }
    if notificationTypeString == VisibleNotificationType.quality.rawValue {
        procesNotification(userInfo: userInfo, goToTarget: true, isNotificationPresented: false)
    } else {
        if UserManager.shared.currentlyTakingSurvey {
            completionHandler()
            return
        }
        procesNotification(userInfo: userInfo, goToTarget: true, isNotificationPresented: false)
    }
    completionHandler()
}

func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    guard UserManager.shared.isLoggedIn else {
        completionHandler(.noData)
        return
    }
    guard let notificationString = userInfo["notification_type"] as? String,
          let notificationType = BackgroundNotificationType(rawValue: notificationString) else {
        return
    }
    switch notificationType {
    case .proofOfProfile:
     guard let userInfo = userInfo as? [String: Any],
           let qualificationRequest = QualificationRequest(JSON: userInfo as [String: Any]) else {
        return
     }
    _ = ProofOfProfileManager.shared.runProofOfProfile(qualificationRequest,
                                                               source: "bg-notification-pop")
    case .checkForPendingQualifications:
        ProofOfProfileManager.shared.checkForPendingQualifications(source: "bg-notification-pending") { _, _ in }
        
    case .quality: return
    }
    completionHandler(UIBackgroundFetchResult.newData)
}

func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    AppsFlyerLib.shared().registerUninstall(deviceToken)
  }
}

extension AppDelegate: UIApplicationDelegate {
func parseDeepLinkURL(from url: URL) -> URL? {
    if let queryItems = URLComponents(url: url,
                                      resolvingAgainstBaseURL: true)?.queryItems {
        if let urlString = queryItems.first(where: { $0.name == "deep_link_id" })?.value {
            return URL(string: urlString)
        }
        if let urlString = queryItems.first(where: { $0.name == "link" })?.value {
            return URL(string: urlString)
        }
    }
    return url
}

func parseCommunitySlug(from url: URL) -> String? {
    guard let queryItems = URLComponents(url: url,
                                         resolvingAgainstBaseURL: true)?.queryItems else {
        return nil
    }
    return queryItems.first(where: { $0.name == "community_slug" })?.value ?? nil
}

func parseCommunityUserID(from url: URL) -> String? {
    guard let queryItems = URLComponents(url: url,
                                         resolvingAgainstBaseURL: true)?.queryItems else {
        return nil
    }
    return queryItems.first(where: { $0.name == "uid" })?.value ?? nil
}

func parseInviteCode(from url: URL) -> String? {
    guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
        return nil
    }
    return queryItems.first(where: { $0.name == "code" })?.value ?? nil
}

func parseOnboardingTemplate(from url: URL) -> String? {
    guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
        return nil
    }
    return queryItems.first(where: { $0.name == "onboard_template" })?.value ?? nil
}

func application(_ application: UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)

guard let outerURL = userActivity.webpageURL, let url = parseDeepLinkURL(from: outerURL) else {
    return false
}
if let communitySlug = parseCommunitySlug(from: url) {
    let communityUserID = parseCommunityUserID(from: url)
    guard let topMost = UIViewController.topMost else {
        return false
    }
if UserManager.shared.isLoggedIn {
    if #available(iOS 13.0, *) {
        Router.shared.route(
            to: Route.customPopUp(communitySlug: communitySlug,
                                  communityUserID: communityUserID,
                                  type: .communityType, delegate: self),
            from: topMost,
            presentationType: .modal(presentationStyle: .overFullScreen,
                                     transitionStyle: .crossDissolve)
        )
    } else {
        let joinCommunityViewController = JoinCommunityViewController (communitySlug: communitySlug,
                                                                       communityUserID: communityUserID,
                                                                       popupType: .communityType)
        joinCommunityViewController.popupDelegate = self
        joinCommunityViewController.ctrl = joinCommunityViewController
        joinCommunityViewController.modalPresentationStyle = .fullScreen
        window?.addSubview(joinCommunityViewController.view)
    }
} else {
    guard let rootVC = window?.rootViewController as? RootViewController else {
        return false
    }
    if communitySlug != Constants.defaultCommunitySlug {
        UserManager.shared.deepLinkCommunitySlug = communitySlug
        UserManager.shared.deepLinkCommunityUserID = communityUserID
    }
    UserManager.shared.deepLinkURLString = url.absoluteString
    let introVC = AppIntroViewController()
    let introNav = LoginNavigationViewController(rootViewController: introVC)
    rootVC.viewController = introNav
  }
} else if let inviteCode = self.parseInviteCode(from: url) {
  UserManager.shared.deepLinkInviteCode = inviteCode
  }
 return true
}

@available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if url.scheme?.caseInsensitiveCompare(("twitterkit-" + Constants.twitterConsumerApiKeys)) == .orderedSame {
            return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        } else {
            AppsFlyerLib.shared().handleOpen(url, options: options)
            ApplicationDelegate.shared.application(app, open: url,
                                                   sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                   annotation: options [UIApplication.OpenURLOptionsKey.annotation])
            return application(app, open: url,
                               sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                               annotation: "")
        }
    }
    
func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
    let isValidFirebaseLink = !url.absoluteString.contains("No%20pre%2Dinstall%20link%20matched")
    guard isValidFirebaseLink else {
        return false
    }
    guard let url = parseDeepLinkURL(from: url) else {
        NotificationCenter.default.post(name: .deepLinkCommunityNotFound,
                                        object: nil, userInfo: nil)
        return false
    }
    guard !UserManager.shared.isLoggedIn else {
        NotificationCenter.default.post(name: .deepLinkCommunityNotFound,
                                        object: nil, userInfo: nil)
        return false
    }
    var foundNonDefaultCommunitySlug = false
    
    if let communitySlug = parseCommunitySlug(from: url) {
        if communitySlug != Constants.defaultCommunitySlug {
            foundNonDefaultCommunitySlug = true
            NotificationCenter.default.post(name: .deepLinkCommunityFound,
                                            object: nil, userInfo: nil)
            UserManager.shared.deepLinkCommunitySlug = communitySlug
            if let communityUserID = parseCommunityUserID(from: url) {
                UserManager.shared.deepLinkCommunityUserID = communityUserID
            }
            UserManager.shared.loadCommunityFromDeepLink { (community, error) in
                if error == nil {
                    Defaults[.community] = community
                    UserManager.shared.currentCommunity = community
                }
            }
        }
        UserManager.shared.deepLinkURLString = url.absoluteString
    }
    
    if !foundNonDefaultCommunitySlug {
        NotificationCenter.default.post(name: .deepLinkCommunityNotFound, object: nil, userInfo: nil)
    }

    if let onboardTemplate = parseOnboardingTemplate(from: url) {
        UserManager.shared.deepLinkOnboardTemplate = onboardTemplate
        NotificationCenter.default.post(name: .onboardTemplateFound, object: nil, userInfo: nil)
    }
    
    if let inviteCode = self.parseInviteCode(from: url) {
        UserManager.shared.deepLinkInviteCode = inviteCode
    }
    
    return true
}
}
