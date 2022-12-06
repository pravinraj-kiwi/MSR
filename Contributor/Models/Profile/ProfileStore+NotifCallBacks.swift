//
//  ProfileStore+NotifCallBacks.swift
//  Contributor
//
//  Created by KiwiTech on 6/2/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import os
import UIKit
import SwiftyUserDefaults

extension ProfileStore {
    @objc func onOnBoardingFinished(notification: NSNotification) {
        fetchProfile { (profile, error) in
            NotificationCenter.default.post(name: .profileUpdated, object: nil, userInfo: nil)
        }

    }
@objc func onProfileSurveyFinished(notification: NSNotification) {
  backgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
  backgroundTaskRunner.startTask {
    guard let itemRefs = notification.userInfo!["itemRefs"] as? [String] else {
        return
    }
    
    // Note: this computed field processing should/will be generalized, but until then this will be a dumping ground
    let group = DispatchGroup()
    
    // special case for DOB, derive age
    if values[ProfileItemRefs.age] == nil {
       _ = updateAgeFromDOB()
    }
    
    // special case for postal code, derive other geo items
    for postalCodeStringRef in ProfileItemRefs.postalCodeStrings {
        if itemRefs.contains(postalCodeStringRef) {
            group.enter()
            updateGeoFromPostalCode {
                group.leave()
            }
            break
        }
    }
    
    group.notify(queue: DispatchQueue.main) {
        [weak self] in
        guard let this = self else {
            return
        }
        
        this.backup {
            NotificationCenter.default.post(name: .profileUpdated, object: nil, userInfo: nil)
        }
    }
    self.backgroundTaskRunner.endTask()
  }
}

@objc func backup(completion: (() -> Void)? = nil) {
    os_log("Backing up profile to CK...", log: OSLog.profileStore, type: .info)
    
    ProfileBackUpManager.shared.saveProfile(for: user, values: values) {
        (profile, error) in
        if let error = error {
            os_log("Backup failed: %{public}@", log: OSLog.profileStore, type: .error, error.localizedDescription)
        } else {
            os_log("Backup success", log: OSLog.profileStore, type: .info)
            let backupStatus = Defaults[.profileBackupStatus] ?? ProfileBackupStatus()
            backupStatus.modifiedAt = profile?.modifiedAt ?? Date()
            Defaults[.profileBackupStatus] = backupStatus
        }
        completion?()
    }
}

@objc func onNewAppVersion() {
    // one time upgrade for geo
    if !Defaults[.haveResolvedGeo] {
        updateGeoFromPostalCode {
            self.backup()
        }
    }
}

@objc func fetchProfileIfRequired() {
    guard let profileBackupStatus = Defaults[.profileBackupStatus] else {
        fetchProfile()
        return
    }
    
    let currentDate = Date()
    if let fetchDate = profileBackupStatus.fetchDate, currentDate.timeIntervalSince(fetchDate) > profileFetchInterval {
        fetchProfile()
    }
}

func fetchProfile(_ completion: ((Profile?, Error?) -> ())? = nil) {
    ProfileBackUpManager.shared.fetchOrCreateProfile(for: user) { [weak self] (profile, error) in
        guard let this = self else {
            return
        }
        
        if let error = error {
            completion?(nil, error)
        } else {
            if profile?.data != nil {
                this.profile = profile
                if let updatedValue = profile?.json {
                    this.set(values: updatedValue)
                    completion?(profile, nil)
                }
            } else {
                completion?(nil, error)
            }
        }
    }
}
    
func getUpdatedValueJson(filename fileName: String) -> Array<Any>? {
  let extensionName = Constants.jsonFileExtension
  if let url = Bundle.main.url(forResource: fileName, withExtension: extensionName) {
    do {
      let data = try Data(contentsOf: url)
      let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])
      return Array(arrayLiteral: jsonObject)
    } catch {
        debugPrint("error:\(error)")
     }
   }
  return nil
}

func compareAndUpdateOldValues() -> [[String: [String: AnyHashable]]] {
 var updatedJsonFileArray = [[String: [String: AnyHashable]]]()
 var updatedJsonFileDict = [String: [String: AnyHashable]]()
 if let updatedValueJson = getUpdatedValueJson(filename: Constants.updateProfileValueJson),
    let updatedValueArray = updatedValueJson.map({$0}).first as? [String: [String: AnyHashable]] {
    _ = updatedValueArray.compactMap({ (keyDict, valueDict) in
        var dataDict = [String: AnyHashable]()
        for (_, valueData) in valueDict.enumerated() {
            let updatedKey = String(describing: valueData.key).filter { !" \n\t\r".contains($0) }.trimTrailingWhitespaces()
            let updateKey = updatedKey.replacingOccurrences(of: "’", with: "")
            dataDict.updateValue(valueData.value, forKey: updateKey.lowercased())
        }
        updatedJsonFileDict.updateValue(dataDict, forKey: keyDict)
     })
   }
  updatedJsonFileArray.append(updatedJsonFileDict)
  return updatedJsonFileArray
  }
}
