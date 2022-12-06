//
//  Defaults+Extensions.swift
//  Contributor
//
//  Created by arvindh on 28/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
  static let user = DefaultsKey<User?>("user")
  static let community = DefaultsKey<Community?>("community")
  static let exchangeRates = DefaultsKey<ExchangeRates?>("exchangeRates")
  static let onboardingDone = DefaultsKey<Bool>("onboardingDone", defaultValue: false)
  static let seeAllClicked = DefaultsKey<Bool>("seeAllClicked", defaultValue: false)
  static let readMoreClicked = DefaultsKey<Bool>("readMoreClicked", defaultValue: false)
  static let isdataMigratedFromiCloud = DefaultsKey<Bool>("isdataMigratedFromiCloud", defaultValue: false)
  static let shownFirstTimeEmptyOffersMessage = DefaultsKey<Bool>("shownFirstTimeEmptyOffersMessage",
                                                                  defaultValue: false)
  static let currentDeviceToken = DefaultsKey<String?>("currentDeviceToken")
  static let currentAppVersion = DefaultsKey<String?>("currentAppVersion")
  static let previousNotificationStatusCheck = DefaultsKey<NotificationStatusCheck?>("previousNotificationStatusCheck")
  static let previousNetworkVoteDate = DefaultsKey<Date?>("previousNetworkVoteDate")
  static let previousPatchDate = DefaultsKey<Date?>("previousPatchDate")
  static let previousDataInboxSupportDate = DefaultsKey<Date?>("previousDataInboxSupportDate")
  static let profileBackupStatus = DefaultsKey<ProfileBackupStatus?>("profileBackupStatus")
  static let haveResolvedGeo = DefaultsKey<Bool>("haveResolvedGeo", defaultValue: false)
  static let trackedFunnelEvents = DefaultsKey<[String: Bool]>("trackedFunnelEvents", defaultValue: [:])
  static let hadSeenMyDataTutorial = DefaultsKey<Bool>("hadSeenMyDataTutorial", defaultValue: false)
  static let loggedInUserAccessToken = DefaultsKey<String?>("loggedInUserAccessToken")
  static let loggedInUserRefreshToken = DefaultsKey<String?>("loggedInUserRefreshToken")
  static let previousFeedFetchDate = DefaultsKey<Date?>("previousFeedFetchDate")
  static let feedDidLoadRunBefore = DefaultsKey<Bool>("feedDidLoadRunBefore", defaultValue: false)
  static let notifAppeared = DefaultsKey<Bool>("notifAppeared", defaultValue: false)
  static let tripleCurrentPassword = DefaultsKey<Bool>("tripleCurrentPassword", defaultValue: false)
  static let tripleNewPassword = DefaultsKey<Bool>("tripleNewPassword", defaultValue: false)
  static let tripleConfirmPassword = DefaultsKey<Bool>("tripleConfirmPassword", defaultValue: false)
  static let accountNewPassword = DefaultsKey<Bool>("accountNewPassword", defaultValue: false)
  static let accountConfirmPassword = DefaultsKey<Bool>("accountConfirmPassword", defaultValue: false)
  static let accountSelectedDate = DefaultsKey<Date?>("accountSelectedDate")
  static let shouldRefreshWallet = DefaultsKey<Bool>("shouldRefreshWallet", defaultValue: true)
  static let closeReferFriendView = DefaultsKey<Bool>("closeReferFriendView", defaultValue: false)
  static let appLaunchCount = DefaultsKey<Int?>("appLaunchCount", defaultValue: 1)
  static let retroVideoFileSize = DefaultsKey<String?>("retroVideoFileSize")
  static let retroVideoApproxUploadSpeed = DefaultsKey<String?>("retroVideoApproxUploadSpeed")
}
