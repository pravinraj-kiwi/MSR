//
//  DataInboxSupportManager.swift
//  Contributor
//
//  Created by KiwiTech on 5/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import SwiftyJSON

class DataInboxSupportManager: NSObject {

static let shared: DataInboxSupportManager = {
  let manager = DataInboxSupportManager()
  return manager
}()

let dataInboxInterval: TimeInterval = 3600 * 24 // 24 hrs

fileprivate var backgroundTaskRunner: BackgroundTaskRunner!

/*
 Get Latest Profile Item data from server.
 */
func getInboxDataPackage() {
    backgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
    backgroundTaskRunner.startTask {
    NetworkManager.shared.getProfileData { [weak self] (profile, error) in
        guard let this = self else { return }
        if error == nil {
         if let profileData = profile?.json {
            this.processInboxDataPackage(profileData)
         } else {
            this.processInboxDataPackage([:])
         }
       }
     }
      self.backgroundTaskRunner.endTask()
  }
}

/*
 Check if it's been 24hr before data inbox package processed.
 */
func updateDataInboxSupportIfNeeded() {
  var timeForUpdateDataInbox = false
  guard UserManager.shared.isLoggedIn, let _ = UserManager.shared.user else {
    return
  }
  let now = Date()
  if let lastPatchDate = Defaults[.previousDataInboxSupportDate] {
    if now.timeIntervalSince(lastPatchDate) > dataInboxInterval {
      timeForUpdateDataInbox = true
    }
  } else {
    timeForUpdateDataInbox = true
  }
  if timeForUpdateDataInbox {
    getInboxDataPackage()
  }
}

/*
  Get data inbox data from /api/v1/data-packages?status=10,
  then data is processed according to it's type then inbox support
  id is removed thru the POST /api/v1/mark-data-packages-as-processed
  api by giving the package id's and then profile data is
  updated on the server and locally also.
 */
func processInboxDataPackage(_ updatedProfile: [String: AnyHashable]) {
  Defaults[.previousDataInboxSupportDate] = Date()
  NetworkManager.shared.getDataInboxPackage { [weak self] (dataInbox, error) in
        guard let this = self else { return }
        if error == nil {
            if let profileStore = UserManager.shared.profileStore {
                if let inboxSupportData = dataInbox, !inboxSupportData.isEmpty,
                   let package = inboxSupportData.map({$0.package}) as? [[String: Any]] {
                    this.runAlgoAccordingToDataPackage(profileStore.values,
                                                       dataInbox: package) { (updatedValues) in
                    this.markDataAsProcessed(inboxSupportData)
                    if let processedProfileValues = updatedValues {
                        this.saveUpdatedProfileData(processedProfileValues)
                    }
                  }
                }
            }
        }
    }
}
 
/*
 Here Data is processed by it's type stated in DataInboxSupportType enum
 Brief Explaination
 insert_or_replace - Update dict by replacing the value provided in the key
 insert_or_extend/insert_or_merge - Update dict by merging
  the value with the existing value provided in the key
 insert_if_does_not_exist - Insert new value in the dict
*/
func runAlgoAccordingToDataPackage(_ updatedProfile: [String: AnyHashable], dataInbox: [[String: Any]],
                                   completion: @escaping ([String: Any]?) -> Void) {
    
    var dataPackageUpdatedProfile: [String: Any] = updatedProfile
    _ = dataInbox.compactMap { (inboxPackageDict) in
    for inboxPackage in inboxPackageDict {
        let packageType = DataInboxSupportType(rawValue: inboxPackage.key)
        switch packageType {
        case .replace:
            if let replaceExistingValue = inboxPackage.value as? [String: Any] {
                dataPackageUpdatedProfile.merge(replaceExistingValue) {(_, new) in new }
            }

        case .merge, .extend:
            if let unmergedValue = inboxPackage.value as? [String: Any] {
                 let mergedDict = getCombinedDict(unmergedValue, dataPackageUpdatedProfile)
                 dataPackageUpdatedProfile.merge(mergedDict) {(_, new) in new }
            }

        case .dataNotExist:
            if let insertNewValue = inboxPackage.value as? [String: Any] {
               dataPackageUpdatedProfile.merge(insertNewValue) {(_, current) in current }
            }

        default:
            break
        }
    }
    completion(dataPackageUpdatedProfile)
    }
}

func getCombinedDict(_ unmergedDict: [String: Any], _ originalDict: [String: Any]) -> [String: Any] {
    var mergedDict = [String: Any]()
    for (key, unmergedValue) in unmergedDict {
        let intersectDict =  originalDict.filter({$0.key == key})
         for (_, originalValue) in intersectDict {
            let nestedArray = [unmergedValue] + [originalValue]
            let flattenedArray = nestedArray.flattenValues()
            let filteredArray: NSOrderedSet = NSOrderedSet(array: flattenedArray)
            mergedDict[key] = filteredArray.array
        }
        if intersectDict.isEmpty {
            mergedDict[key] = unmergedValue
        }
    }
    return mergedDict
}
  
/*
 POST /api/v1/mark-data-packages-as-processed api id called by giving the package id's
 and last processed date is saved
 */
func markDataAsProcessed(_ inboxPackage: [DataInboxSupport]) {
    NetworkManager.shared.deleteProcessedData(package: inboxPackage) { (deletedPackage, error) in
        if error == nil, let deletedResponse = deletedPackage,
            let processTime = deletedResponse.processedOn {
            if let date = Utilities.updateToDate(dateString: processTime) {
                Defaults[.previousDataInboxSupportDate] = date
            }
        }
    }
 }
        
/*
 Updated processed profile data is updated on the server and locally.
*/
func saveUpdatedProfileData(_ updatedProfileValue: [String: Any]) {
    if let currentUser = UserManager.shared.user,
       let profileStore = UserManager.shared.profileStore {
        ServerProfileBackUp.shared.uploadNewUserProfileDataToServer(for: currentUser,
                                                                    values: updatedProfileValue) { (_, error) in
            if error == nil {
                NetworkManager.shared.getProfileData { (profile, error) in
                    if error == nil {
                     if let profileData = profile?.json {
                        profileStore.set(values: profileData)
                        if profileStore.values[ProfileItemRefs.age] == nil {
                          _ = profileStore.updateAgeFromDOB()
                        }
                      }
                    }
                }
            }
        }
     }
   }
}

extension Array {
    func flattenValues() -> [Any] {
        return self.flatMap { element -> [Any] in
            if let elementAsArray = element as? [Any] {
                return elementAsArray.flattenValues()
            } else {
                return [element]
            }
        }
    }
}
