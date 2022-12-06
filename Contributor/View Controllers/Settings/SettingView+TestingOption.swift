//
//  SettingView+TestingOption.swift
//  Contributor
//
//  Created by KiwiTech on 10/7/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension SettingViewController {

func showHTMLString(_ string: String) {
  let webContentViewController = WebContentViewController()
  let pageHTMLString = WebContentViewController.createAppPageHTMLString(string)
  webContentViewController.startHTMLString = pageHTMLString
  webContentViewController.startBaseURL = Constants.baseContributorAPIURL
  show(webContentViewController, sender: self)
}
    
func dumpProfile() {
  guard let profileStore = UserManager.shared.profileStore else { return }
  let profileHTMLString = profileStore.dumpKeysAndValuesToHTMLString()
  showHTMLString("/v1\(profileHTMLString)")
}

func deleteRandom() {
  guard let profileStore = UserManager.shared.profileStore else { return }
  let allBasicItemRefs = [ "country_of_residence",
                           "us_state_of_residence",
                           "us_city_of_residence",
    "us_county_of_residence",
    "us_zip_code_of_residence",
    "us_zip_code_of_residence_string",
    "au_state_of_residence",
    "au_city_of_residence",
    "au_county_of_residence",
    "au_postal_code_of_residence",
    "au_postal_code_of_residence_string",
    "uk_region_of_residence",
    "uk_town_of_residence",
    "uk_postal_code_of_residence_string",
    "ca_province_of_residence",
    "ca_city_of_residence",
    "ca_postal_code_of_residence",
    "ca_postal_code_of_residence_string",
    "gender",
    "dob",
    "age",
    "education",
    "employment",
    "household_income_us",
    "household_income_au",
    "household_income_uk",
    "household_income_ca"
  ]
  var basicItemsInProfile: [String] = []
  for ref in allBasicItemRefs {
    if profileStore.values.keys.contains(ref) {
      basicItemsInProfile.append(ref)
    }
  }
    
  let numItemsToDelete = basicItemsInProfile.count < 3 ? basicItemsInProfile.count : 3
  if numItemsToDelete == 0 { return }
  var resultHTMLString = "<p>Deleting \(numItemsToDelete) profile items...</p>\n"
  for i in 1...numItemsToDelete {
    if let k = basicItemsInProfile.randomElement() {
        resultHTMLString += "\(i). \(k)<br>\n"
        basicItemsInProfile = basicItemsInProfile.filter { $0 != k }
        profileStore.removeValue(forKey: k)
    }
  }
  showHTMLString("\(resultHTMLString)")
}
    
func runProfileMaintenance() {
  ProfileMaintenanceManager.shared.patchProfile()
  let resultHTMLString = "<p>Running profile maintenance check ... <b>done</b>.</p>\n"
  showHTMLString("\(resultHTMLString)")
}

func runNetworkVote() {
  NetworkCharacterizationManager.shared.makeVote()
  let resultHTMLString = "<p>Running network vote ... <b>done</b>.</p>\n"
  showHTMLString("\(resultHTMLString)")
}

func runDataInboxSupport() {
  DataInboxSupportManager.shared.getInboxDataPackage()
  let resultHTMLString = "<p>Running Inbox support ... <b>done</b>.</p>\n"
  showHTMLString("\(resultHTMLString)")
}

func testACOnboard() {
  Defaults[DefaultsKeys.onboardingDone] = true
  UserManager.shared.deepLinkCommunitySlug = "ac"
  UserManager.shared.loadCommunityFromDeepLink { (_,_) in }
  let userInfo = ["testCommunityOnboardingSlug": "ac"]
  NotificationCenter.default.post(name: NSNotification.Name.shouldLogout, object: self, userInfo: userInfo)
}

func testBroccoliOnboard() {
  Defaults[DefaultsKeys.onboardingDone] = true
  UserManager.shared.deepLinkCommunitySlug = "broccoli"
  UserManager.shared.loadCommunityFromDeepLink { (_,_) in }
  let userInfo = ["testCommunityOnboardingSlug": "broccoli"]
  NotificationCenter.default.post(name: NSNotification.Name.shouldLogout, object: self, userInfo: userInfo)
}

func testGamerOnboard() {
  Defaults[DefaultsKeys.onboardingDone] = true
  UserManager.shared.deepLinkCommunitySlug = "ggg"
  UserManager.shared.loadCommunityFromDeepLink { (_,_) in }
  let userInfo = ["testCommunityOnboardingSlug": "ggg"]
  NotificationCenter.default.post(name: NSNotification.Name.shouldLogout, object: self, userInfo: userInfo)
  }
}
