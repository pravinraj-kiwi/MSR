//
//  ProfileMaintenanceManager.swift
//  Contributor
//
//  Created by John Martin on 10/29/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import Foundation
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults

class ProfileMaintenanceManager: NSObject {
  static let shared: ProfileMaintenanceManager = {
    let manager = ProfileMaintenanceManager()
    return manager
  }()
  
  let patchInterval: TimeInterval = 3600 * 24 * 7  // i.e. 7 days

  fileprivate var backgroundTaskRunner: BackgroundTaskRunner!
  
  func findProfileItemsToPatch(completion: @escaping ([ProfileItem]?, Error?) -> Void) {
    
    // for now we're just looking at the basic category
    NetworkManager.shared.getProfileItemsForCategory(category: SurveyType.welcome) {
      (items, error) in
      
      if let error = error {
        completion(nil, error)
      } else {
        var missingItems: [ProfileItem] = []
        
        if let items = items, let profileStore = UserManager.shared.profileStore {
          // pull out any items that are not in the profile
          for item in items {
            let hasTests = !item.applicableIf.isEmpty
            if !hasTests || (hasTests && evaluateJSONLogicTest(tests: item.applicableIf, data: profileStore.values)) {
              if profileStore.values[item.ref] == nil {
                missingItems.append(item)
              }
            }
          }
        }
        completion(missingItems, nil)
      }
    }
  }
  
  func patchProfileIfNeeded() {
    var timeForPatch = false
    
    guard UserManager.shared.isLoggedIn, let user = UserManager.shared.user, user.isAcceptingOffers else {
      return
    }
    
    let now = Date()
    if let lastPatchDate = Defaults[.previousPatchDate] {
      if now.timeIntervalSince(lastPatchDate) > patchInterval {
        timeForPatch = true
      }
    } else {
      timeForPatch = true
    }
    
    if timeForPatch {
      patchProfile()
    }
  }

 func patchProfile() {
    guard UserManager.shared.isLoggedIn,
          let user = UserManager.shared.user, user.isAcceptingOffers else {
      return
    }
    
    Defaults[.previousPatchDate] = Date()
    findProfileItemsToPatch {
      (items, error) in
      
      if let _ = error {
        os_log("findProfileItemsToPatch failed", log: OSLog.profileMaintenance, type: .error)
      } else {
        if let items = items, !items.isEmpty {
          NetworkManager.shared.createProfileMaintenanceJob(items: items) { _ in }
        }
      }
    }
  }
}
