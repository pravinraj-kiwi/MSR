//
//  SettingSection.swift
//  Contributor
//
//  Created by KiwiTech on 9/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

enum Setting: String {
  case personalDetails, changePassword, referFriend,
       logout, version, faq, terms, privacy, support,
       dumpProfile, deleteRandomProfileItems,
       runProfileMaintenance, runNetworkVote, testACOnboard,
       testBroccoliOnboard, testGamerOnboard,
       runDataInboxSupport, deleteAcount, changeLanguage
  enum SettingType {
    case detail, value
  }

  var type: SettingType {
    switch self {
    case .version: return .value
    default: return .detail
    }
  }

  var title: String {
    switch self {
    case .personalDetails: return Text.personalDetails.localized()
    case .changePassword: return Text.changePassword.localized()
    case .referFriend: return Text.referFriend.localized()
    case .logout: return Text.logout.localized()
    case .deleteAcount: return Text.deleteAcount.localized()
    case .version: return Text.version.localized()
    case .terms: return Text.terms.localized()
    case .faq: return Text.faq.localized()
    case .privacy: return Text.privacy.localized()
    case .support: return Text.support.localized()
    case .dumpProfile: return Text.dumpProfile.localized()
    case .deleteRandomProfileItems: return Text.deleteRandomProfileItems.localized()
    case .runProfileMaintenance: return Text.runProfileMaintenance.localized()
    case .runNetworkVote: return Text.runNetworkVote.localized()
    case .runDataInboxSupport: return Text.runDataInboxSupport.localized()
    case .testACOnboard: return Text.testACOnboard.localized()
    case .testBroccoliOnboard: return Text.testBroccoliOnboard.localized()
    case .testGamerOnboard: return Text.testGamerOnboard.localized()
    case .changeLanguage: return Text.changeLanguage.localized()
    }
  }

  var value: String {
    switch self {
    case .version:
      return "\(Bundle.main.releaseVersionNumber ?? "?").\(Bundle.main.buildVersionNumber ?? "?")"
    default:
      return ""
    }
  }
}

class SettingsSection: NSObject {
  var title: String = ""
  var items: [Setting] = []
  init(title: String, items: [Setting]) {
    self.title = title
    self.items = items
    super.init()
  }
}
