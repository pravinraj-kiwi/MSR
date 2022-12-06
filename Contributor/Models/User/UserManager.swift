//
//  UserManager.swift
//  Contributor
//
//  Created by arvindh on 28/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import Foundation
import UIKit
import Moya
import KeychainSwift
import SwiftyUserDefaults
import Kingfisher
import Alamofire

class UserManager: NSObject {
  static let shared: UserManager = {
    let manager = UserManager()
    return manager
  }()
  
  private var defaults: UserDefaults!
  private var previousBalance = 0
  
  private(set) var user: User? {
    didSet {
      save(user: user)
      if let user = user {
        wallet = Wallet(user: user)
        
        if let _ = user.selectedCommunitySlug,
           let selectedCommunity = user.selectedCommunity {
            defaults[.community] = selectedCommunity
            currentCommunity = selectedCommunity
        } else {
          // this should probably only reach here on upgrades from pre 1.9
          currentCommunity = loadDefaultCommunity()
          user.selectedCommunitySlug = currentCommunity?.slug
        }
        
        // create this only if new user is being set, in case of login or at app launch.
        if oldValue == nil {
          profileStore = ProfileStore(user: user)
          
          // update the ID used for analytics
          AnalyticsManager.shared.setAnalyticsUser("\(user.userID!)")
        }
      }
    }
  }
  
  var wallet: Wallet?
  var profileStore: ProfileStore?
  var currentlyTakingInternalSurvey = false
  var currentlyTakingExternalSurvey = false
  
  var currentlyTakingSurvey: Bool {
    return currentlyTakingInternalSurvey || currentlyTakingExternalSurvey
  }
  
  var currentCommunity: Community? {
    didSet {
      preFetchImages()
      let themeApplied = NSNotification.Name.communityThemeApplied
      NotificationCenter.default.post(name: themeApplied,
                                      object: currentCommunity)
        if let _ = user?.selectedCommunitySlug,
           let selectedCommunity = user?.selectedCommunity {
            currentCommunity = selectedCommunity
            defaults[.community] = selectedCommunity
        }
    }
  }
  
  var isDefaultCommunity: Bool {
    if let community = currentCommunity, community.slug != Constants.defaultCommunitySlug {
      return false
    }
    return true
  }
  
  // a dict of offer IDs and finish date
  var recentlyClosedOffers: [Int: Date] = [:]
  
  var isLoggedIn: Bool {
    return user != nil
  }

  // these are populated by a deep link to bridge until a user is created/authenticated
  var deepLinkCommunitySlug: String?
  var deepLinkCommunityUserID: String?
  var deepLinkURLString: String?
  var deepLinkInviteCode: String?
  var deepLinkOnboardTemplate: String?
  // saves the current empty message
  var selectedEmptyMessageIndex: Int = 0

  weak var networkManager: NetworkManager?
  
  init(defaults: UserDefaults = Defaults) {
    super.init()
    self.defaults = defaults
    
    if Defaults[.community] != nil {
        currentCommunity = Defaults[.community]
    } else {
        currentCommunity = loadDefaultCommunity()
    }
    loadCurrentUser()
    addObserver()
  }

  func logout() {
    guard let _ = self.user else {
      return
    }
    
    if let userId = self.user?.userID {
        UserDefaults.standard.removeObject(forKey: "profileStore-\(userId)")
        UserDefaults.standard.removeObject(forKey: "nonProfileStore-\(userId)")
        UserDefaults.standard.removeObject(forKey: "alreadyCompleted-\(userId)")
    }
    self.user = nil
    
    deepLinkCommunitySlug = nil
    deepLinkCommunityUserID = nil
    deepLinkURLString = nil
    deepLinkInviteCode = nil
    recentlyClosedOffers = [:]

    Defaults.remove(.shownFirstTimeEmptyOffersMessage)
    Defaults.remove(.previousNotificationStatusCheck)
    Defaults.remove(.previousNetworkVoteDate)
    Defaults.remove(.profileBackupStatus)
    Defaults.remove(.haveResolvedGeo)
    Defaults.remove(.isdataMigratedFromiCloud)
    Defaults.remove(.previousDataInboxSupportDate)
    Defaults.remove(.loggedInUserAccessToken)
    Defaults.remove(.loggedInUserRefreshToken)
    Defaults.remove(.previousFeedFetchDate)
    Defaults.remove(.feedDidLoadRunBefore)
    Defaults.remove(.notifAppeared)
    Defaults.remove(.tripleCurrentPassword)
    Defaults.remove(.tripleNewPassword)
    Defaults.remove(.tripleConfirmPassword)
    Defaults.remove(.accountNewPassword)
    Defaults.remove(.accountConfirmPassword)
    Defaults.remove(.accountSelectedDate)
    Defaults.remove(.shouldRefreshWallet)
    Defaults.remove(.closeReferFriendView)
    Defaults.remove(.retroVideoFileSize)
    Defaults.remove(.retroVideoApproxUploadSpeed)
    UserDefaults.standard.removeObject(forKey: Constants.percentageDefault)
    currentCommunity = Defaults[.community]
    if let userDefaults = UserDefaults(suiteName: Constants.appGroup) {
        userDefaults.removeObject(forKey: SuitDefaultName.userFirstName)
        userDefaults.removeObject(forKey: SuitDefaultName.userBalance)
        userDefaults.removeObject(forKey: SuitDefaultName.userCommunity)
        userDefaults.removeObject(forKey: SuitDefaultName.accessToken)
    }
  }
  
  func save(user: User?) {
    defaults[.user] = user
    if defaults[.user]  != nil {
        if let userDefaults = UserDefaults(suiteName: Constants.appGroup) {
            userDefaults.set(defaults[.user]?.firstName as AnyObject,
                             forKey: SuitDefaultName.userFirstName)
            userDefaults.set(defaults[.user]?.balanceMSR as AnyObject,
                             forKey: SuitDefaultName.userBalance)
            userDefaults.set(defaults[.user]?.selectedCommunity?.colors.primary.hexString(),
                             forKey: SuitDefaultName.userCommunity)
            if let token = Defaults[.loggedInUserAccessToken] {
                userDefaults.set(token,
                                 forKey: SuitDefaultName.accessToken)

            }
            userDefaults.synchronize()
        }
    }
  }
  
  fileprivate func loadCurrentUser() {
    var user: User?
    user = defaults[.user]
    self.user = user
  }
  
  func setUser(_ user: User) {
    self.user = user

    if user.balanceMSR != previousBalance {
      previousBalance = user.balanceMSR
      NotificationCenter.default.post(name: NSNotification.Name.balanceChanged, object: user)
    }
    NotificationCenter.default.post(name: NSNotification.Name.userChanged, object: user)
  }

  func addObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(onProfileSurveyFinished),
                                           name: .profileSurveyFinished, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onOfferFinished(_:)),
                                           name: .offerCompleted, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onOfferFinished(_:)),
                                           name: .offerDeclined, object: nil)
  }
    
  func getAccessToken() -> String {
    if let accessToken = Defaults[.loggedInUserAccessToken] {
        return accessToken
    }
    return ""
  }
    
  func saveAccessToken(user: User) {
    if let currentUserAccessToken = user.accessToken {
        Defaults[.loggedInUserAccessToken] = currentUserAccessToken
    }
  }
    
  func saveRefreshToken(user: User) {
    if let currentUserRefreshToken = user.refreshToken {
        Defaults[.loggedInUserRefreshToken] = currentUserRefreshToken
    }
  }
    
  func deletePassword() {
    guard let user = self.user else {
      return
    }
    let keychain = KeychainSwift()
    keychain.delete(user.email)
  }
    
  // MARK: community themes

  func loadDefaultCommunity() -> Community? {
    guard let communityAsset = NSDataAsset(name: "defaultCommunity") else {
      fatalError("Missing data asset: defaultCommunity")
    }
    
    var defaultCommunity: Community?
    do {
      let data = communityAsset.data
      let decoder = JSONDecoder()
      defaultCommunity = try decoder.decode(Community.self, from: data)
    } catch {
      fatalError("Problem loading or parsing defaultCommunity data asset.")
    }
    return defaultCommunity
  }
  
  func loadCommunityFromDeepLink(completion: @escaping (Community?, Error?) -> Void) {
    guard let communitySlug = UserManager.shared.deepLinkCommunitySlug else {
      return
    }
    NetworkManager.shared.getCommunity(communitySlug: communitySlug) {
      [weak self] (community, error) in
      guard let this = self else {
        return
      }
      if let error = error {
        completion(nil, error)
      } else {
        Defaults[.community] = community
        UserManager.shared.currentCommunity = community
        NotificationCenter.default.post(name: NSNotification.Name.deepLinkCommunityLoaded, object: nil, userInfo: nil)
        completion(community, nil)
      }
    }
  }
    
  fileprivate func preFetchImages() {
    guard let community = currentCommunity else {
      return
    }
    ImagePrefetcher(urls: community.imageURLs).start()
  }
  
  // MARK: data source toggles
  
  func toggle(dataSource: DataSource, completion: @escaping (Error?) -> ()) {
    guard let _ = user else {
      return
    }
    
    let currentStatus = isOn(dataSource: dataSource)
    let userInfo = [
      dataSource.key: !currentStatus
    ]
    networkManager?.updateUser(userInfo) { (error) in
      completion(error)
    }
  }
  
  func isOn(dataSource: DataSource) -> Bool {
    guard let user = user else {
      return false
    }
    return user[keyPath: dataSource.keyPath]
  }
  
  // MARK: survey handling
  
  @objc func onProfileSurveyFinished(notification: NSNotification) {
    guard let categoryRef = notification.userInfo!["categoryRef"] as? String else {
      return
    }
    
    // special case for basic demos, we update the main user record
    if categoryRef == "basic" {
      updateUserWithCountry()
    }
    
    let itemRefs = notification.userInfo!["itemRefs"]! as! [String]
    networkManager?.addProfileEvent(source: categoryRef, itemRefs: itemRefs) { _ in }
  }
  
  func updateUserWithCountry() {
    guard let profileStore = profileStore else {
      return
    }

    if let countryUID = profileStore["country_of_residence"] as? String {
      let userInfo: [User.CodingKeys: Any] = [
        User.CodingKeys.country: CountryCodeLookup[countryUID] as Any,
        User.CodingKeys.currency: CurrencyLookup[countryUID]?.rawValue as Any,
        User.CodingKeys.hasFilledBasicDemos: true
      ]
      NetworkManager.shared.updateUser(userInfo) { _ in }
    }
  }
  
  func cleanOutOldClosedOffers() {
    // clean out anything older than an hour
    let secondsinAnHour: Double = 60 * 60.0
    let anHourAgo = Date(timeIntervalSinceNow: -secondsinAnHour)
    for (offerID, date) in recentlyClosedOffers {
      if date < anHourAgo {
        recentlyClosedOffers.removeValue(forKey: offerID)
      }
    }
  }
  
  @objc func onOfferFinished(_ notification: Notification) {
    guard let offerID = notification.userInfo?["offerID"] as? Int else {
      return
    }
    
    // default to true
    var useSmallDelay = true
    
    // optionally override if it is specified in the notification
    if let overrideUseSmallDelay = notification.userInfo?["useSmallDelay"] as? Bool {
      useSmallDelay = overrideUseSmallDelay
    }
    
    recentlyClosedOffers[offerID] = Date()
    let userInfo: [String: Bool] = ["useSmallDelay": useSmallDelay]
    NotificationCenter.default.post(name: NSNotification.Name.feedChanged, object: nil, userInfo: userInfo)
    
    cleanOutOldClosedOffers()
  }
}
