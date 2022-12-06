//
//  AppDelegate.swift
//  Contributor
//
//  Created by arvindh on 20/06/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import AZTabBar
import Firebase
import FirebaseMessaging
import FirebaseRemoteConfig
import UserNotifications
import SwiftyUserDefaults
import FirebaseDynamicLinks
import AppsFlyerLib
import IQKeyboardManagerSwift
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import KeychainSwift
import FirebaseCore
import netfox
import TwitterKit
import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder {
    
    let appGotActive = NSNotification.Name.appGotActive
    let currentAppVersion = "\(Bundle.main.releaseVersionNumber ?? "0.0").\(Bundle.main.buildVersionNumber ?? "0")"
    
    var tabs: Tabs = Tabs()
    var tabViewController: AZTabBarController? {
        let rootVC = window?.rootViewController as? RootViewController
        return rootVC?.viewController as? AZTabBarController
    }
    
    var window: UIWindow?
    lazy var remoteFirebaseConfig = RemoteConfig.remoteConfig()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        if let selectedLanguage = AppLanguageManager.shared.getLanguage() {
            AppLanguageManager.shared.setAppLanguage(selectedLanguage)
        } else {
            let languageCode = Locale.preferredLanguages[0]
            if Languages.isLanguageAvailable(languageCode){
                AppLanguageManager.shared.setAppLanguage(languageCode)
            }else{
                AppLanguageManager.shared.setAppLanguage("en")
            }
        }
        getUserTokenOnAppUpdate(application)
        setupRemoteConfig()
        setUpIQKeyboard()
        setUpTwitterKeys()
        window = UIWindow(frame: UIScreen.main.bounds)
        UINavigationBar.appearance().titleTextAttributes = Font.bold.asTextAttributes(size: 18)
        UIApplication.shared.setMinimumBackgroundFetchInterval(Constants.backgroundRefreshInterval)
        self.navigateToRootView()
        // #if DEBUG
           //NFX.sharedInstance().start()
        
        // #endif
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        if #available(iOS 15.0, *) {
          let navigationBarAppearance = UINavigationBarAppearance()
          navigationBarAppearance.configureWithOpaqueBackground()
          navigationBarAppearance.shadowImage = nil
          navigationBarAppearance.shadowColor = .none
          UINavigationBar.appearance().standardAppearance = navigationBarAppearance
          UINavigationBar.appearance().compactAppearance = navigationBarAppearance
          UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
          UINavigationBar.appearance().compactScrollEdgeAppearance = navigationBarAppearance
        }
        
        return true
    }
  
    @available(iOS 14, *)
    func appTracking() {
        ATTrackingManager.requestTrackingAuthorization { (status) in
            switch status {
            case .authorized, .denied, .notDetermined, .restricted:
              debugPrint("No Action needed")
            
            @unknown default:
              debugPrint("No Action needed")
              break
            }
        }
    }
  
    func navigateToRootView() {
        var rootVC: UIViewController?
        if UserManager.shared.isLoggedIn {
            let user = UserManager.shared.user!
            if !user.hasDecidedNotifications {
                let permissionsViewController = NotificationPermissionViewController()
                rootVC = LoginNavigationViewController(rootViewController: permissionsViewController)
            } else if !user.hasValidatedEmail {
                let emailValidationViewController = EmailValidationViewController()
                rootVC = LoginNavigationViewController(rootViewController: emailValidationViewController)
            } else {
                rootVC = self.loggedInViewController()
            }
        } else {
            let introVC = AppIntroViewController()
            let introNav = LoginNavigationViewController(rootViewController: introVC)
            rootVC = introNav
        }
        if let rootView = rootVC {
            let rootVCContainer = RootViewController(viewController: rootView)
            window?.rootViewController = rootVCContainer
            window?.makeKeyAndVisible()
        }
        showTheRedDot(tabBar: tabViewController)
    }
    
    func showTheRedDot(tabBar: AZTabBarController?) {
        if Defaults[.hadSeenMyDataTutorial] {
            tabBar?.setBadgeText(nil, atIndex: 1)
        } else {
            tabBar?.setBadgeText("●", atIndex: 1)
        }
    }
    
    func checkAppVersion() {
        var isNewVersion = true
        if let previousAppVersion = Defaults[.currentAppVersion] {
            if currentAppVersion == previousAppVersion {
                isNewVersion = false
            }
        }
        if isNewVersion {
            Defaults[.currentAppVersion] = currentAppVersion
            Defaults[.isdataMigratedFromiCloud] = false
            NotificationCenter.default.post(name: .newAppVersion, object: nil, userInfo: nil)
        }
    }
    
    func onNewVersion(_ application: UIApplication, completion: @escaping (Bool) -> Void) {
        if let currentUserEmail = Defaults[.user]?.email {
            let keychain = KeychainSwift()
            if let currentUserPassword = keychain.get(currentUserEmail) {
                let param = ["username": currentUserEmail,
                             "password": currentUserPassword]
                Alamofire.request("\(Constants.baseContributorAPIURL)/v1/login",
                                  method: .post, parameters: param, encoding: JSONEncoding.default)
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .success(let response):
                            if let result = response as? NSDictionary,
                               let accessToken = result.value(forKey: "access") as? String,
                               let refreshToken = result.value(forKey: "refresh") as? String {
                                Defaults[.loggedInUserAccessToken] = accessToken
                                Defaults[.loggedInUserRefreshToken] = refreshToken
                                completion(true)
                            }
                        case .failure(_):
                            completion(false)
                        }
                    }
            } else {
                if let _ = Defaults[.loggedInUserAccessToken] {
                    initializeOtherSingleton(application)
                }
            }
        }
    }
    
    func deletePassword() {
        guard let user = Defaults[.user] else {
            return
        }
        let keychain = KeychainSwift()
        keychain.delete(user.email)
    }
    
    func getUserTokenOnAppUpdate(_ application: UIApplication) {
        let currentAppVersion = "\(Bundle.main.releaseVersionNumber ?? "0.0").\(Bundle.main.buildVersionNumber ?? "0")"
        if let previousAppVersion = Defaults[.currentAppVersion] {
            if currentAppVersion != previousAppVersion {
                onNewVersion(application) { [weak self] (isSuccess) in
                    guard let this = self else { return }
                    if isSuccess {
                        this.deletePassword()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            this.initializeOtherSingleton(application)
                            NotificationCenter.default.post(name: this.appGotActive, object: nil, userInfo: nil)
                        }
                    }
                }
            } else {
                initializeOtherSingleton(application)
            }
        } else {
            initializeOtherSingleton(application)
        }
    }
    
    func initializeOtherSingleton(_ application: UIApplication) {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        setupForPushNotifications(application)
        _ = UserManager.shared
        _ = AnalyticsManager.shared
        _ = NetworkManager.shared
        _ = PushNotificationManager.shared
        _ = ProofOfProfileManager.shared
        _ = SurveyCallbackManager.shared
        _ = NetworkCharacterizationManager.shared
        _ = ProfileMaintenanceManager.shared
        _ = ServerProfileBackUp.shared
        //Get Data Inbox Package and merge into profile
        DataInboxSupportManager.shared.updateDataInboxSupportIfNeeded()
        checkAppVersion()
        if Defaults[.loggedInUserAccessToken] != nil {
            if let userDefaults = UserDefaults(suiteName: Constants.appGroup) {
                userDefaults.set(Defaults[.loggedInUserAccessToken] as AnyObject, forKey: SuitDefaultName.accessToken)
                userDefaults.synchronize()
            }
        }
    }
    
    func setUpIQKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    func setupRemoteConfig() {
        let configSettings = RemoteConfigSettings()
        remoteFirebaseConfig.configSettings = configSettings
        
        remoteFirebaseConfig.setDefaults([
            FirebaseRemoteConfigKey.shouldFetchProfileOnSurveyStart.rawValue: NSNumber(booleanLiteral: true)
        ])
        let expirationDuration: TimeInterval = 0
        remoteFirebaseConfig.fetch(withExpirationDuration: expirationDuration) { (_, _) in
            self.remoteFirebaseConfig.activate(completion: nil)
        }
    }
    func setUpTwitterKeys () {
        TWTRTwitter.sharedInstance().start(withConsumerKey: Constants.twitterConsumerApiKeys,
                                           consumerSecret: Constants.twitterConsumerSecretApiKeys)
        
    }
    
    fileprivate func setupForPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        
        Messaging.messaging().delegate = PushNotificationManager.shared
        application.registerForRemoteNotifications()
    }
    
    func loggedInViewController() -> UIViewController {
        var viewControllers: [UIViewController] = []
        
        for tab in tabs.order {
            let vc = tab.viewController
            if tab.usesNavigationController {
                let nav = NavigationViewController(rootViewController: vc)
                tabs.viewControllers[tab] = vc
                viewControllers.append(nav)
            } else {
                tabs.viewControllers[tab] = vc
                viewControllers.append(vc)
            }
        }
        
        let images = (viewControllers as? [Tabbable])?.compactMap { (viewController) -> UIImage? in
            return viewController.tabImage.value
        } ?? []
        
        let _ = (viewControllers as? [Tabbable])?.compactMap { (viewController) -> UIImage? in
            return viewController.tabHighlightedImage.value
        } ?? []
        
        let tabBarController = AZTabBarController(withTabIcons: images)
        tabBarController.selectionIndicatorHeight = 0
        
        for (index, vc) in viewControllers.enumerated() {
            tabBarController.setViewController(vc, atIndex: index)
            if let vc = vc as? Tabbable {
                tabBarController.setTitle(vc.tabName, atIndex: index)
            }
        }
        showTheRedDot(tabBar: tabBarController)
        tabBarController.notificationBadgeAppearance.textColor = .red
        tabBarController.notificationBadgeAppearance.backgroundColor = .clear
        tabBarController.notificationBadgeAppearance.textAlignment = .left
        applyCommunityThemeToTabBar(tabViewController: tabBarController)
        return tabBarController
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {
      
        if #available(iOS 14, *) {
            appTracking()
        }

        application.applicationIconBadgeNumber = 0
        AppsFlyerLib.shared().start()
        guard let _ = Defaults[.loggedInUserAccessToken] else {
            AnalyticsManager.shared.trackAppLaunch()
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateStatusAsAppBecomeActive),
                                                   name: appGotActive, object: nil)
            return
        }
        updateStatusAsAppBecomeActive()
    }
    
    @objc func updateStatusAsAppBecomeActive() {
        guard let user = UserManager.shared.user else {
            return
        }
        AnalyticsManager.shared.setAnalyticsUser(user.userIDForAnalytics)
        AnalyticsManager.shared.trackAppLaunch()
        PushNotificationManager.shared.updateNotificationStatus()
        NotificationCenter.default.post(name: .shouldCheckForPendingQualifications, object: nil, userInfo: ["source": "app-became-active"])
        NetworkCharacterizationManager.shared.makePeriodicVoteIfNeeded()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {}
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard UserManager.shared.isLoggedIn else {
            completionHandler(.noData)
            return
        }
        ProofOfProfileManager.shared.checkForPendingQualifications(source: "bg-fetch-pending") { (numberOfQualifications, _) in
            if let numberOfQualifications = numberOfQualifications, numberOfQualifications > 0 {
                completionHandler(.newData)
            } else {
                completionHandler(.noData)
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UserManager.shared.currentlyTakingExternalSurvey {
            return .allButUpsideDown
        }
        return .portrait
    }
}

extension AppDelegate {
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        let isValidAppsFlyerLink = installData["media_source"] != nil
        guard isValidAppsFlyerLink else {
            return
        }
        var joinParams: [String] = []
        for name in installData.keys {
            if let value = installData[name]  as? String,
               let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                joinParams.append("\(name)=\(encodedValue)")
            }
        }
        
        let joinURLString = "http://appsflyer.campaign.com/?" + joinParams.joined(separator: "&")
        UserManager.shared.deepLinkURLString = joinURLString
        
        // look for community slug
        var foundNonDefaultCommunitySlug = false
        if let communitySlug = installData["community_slug"] as? String {
            foundNonDefaultCommunitySlug = true
            NotificationCenter.default.post(name: .deepLinkCommunityFound, object: nil, userInfo: nil)
            UserManager.shared.deepLinkCommunitySlug = communitySlug
            if let communityUserID = installData["uid"] as? String {
                UserManager.shared.deepLinkCommunityUserID = communityUserID
            }
            UserManager.shared.loadCommunityFromDeepLink { (_, _) in
            }
        }
        
        if let inviteCode = installData["code"] as? String {
            UserManager.shared.deepLinkInviteCode = inviteCode
        }
        
        if let onboardTemplate = installData["onboard_template"] as? String {
            UserManager.shared.deepLinkOnboardTemplate = onboardTemplate
            NotificationCenter.default.post(name: .onboardTemplateFound, object: nil, userInfo: nil)
        }
        
        if !foundNonDefaultCommunitySlug {
            NotificationCenter.default.post(name: .deepLinkCommunityNotFound, object: nil, userInfo: nil)
        }
    }
}
