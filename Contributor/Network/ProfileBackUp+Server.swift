//
//  ProfileBackUp+Server.swift
//  Contributor
//
//  Created by KiwiTech on 3/25/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import CloudKit
import SwiftyUserDefaults

class ServerProfileBackUp: NSObject {
  static let shared: ServerProfileBackUp = {
    let manager = ServerProfileBackUp()
    return manager
  }()
    
 /*
  Convert CloudKit data to json string.
  Checking if the json contains an array then convert
  it to comma seperated string.
 */
func convertedBackUpData(_ jsonFromCloudKit: [String: Any]) -> String {
    var dataArray = [String: String]()
     for (item, rawValue) in jsonFromCloudKit {
        var preparedValue: String
        switch rawValue {
        case let stringValue as String:
            preparedValue = stringValue
        case let stringValueArray as [String]:
            preparedValue = stringValueArray.joined(separator: ", ")
        default:
            preparedValue = "\(rawValue)"
        }
        dataArray[item] = preparedValue
    }
    if let string = try? toJSON(array: dataArray) {
      return string
    }
    return ""
 }
    
 /*
  converting icloud backUp data to string.
 */
  func toJSON(array: [String: String]) throws -> String {
    let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
    return String(data: data, encoding: .utf8)!
 }
    
 /*
  Checking if user that has loggedIn has data on profile backup server.
 */
 func isProfileDataExistOnServer(completion: @escaping (Profile?, Bool) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
    NetworkManager.shared.getProfileData { [weak self] (profile, error) in
        guard self != nil else {
            return
        }
        if let _ = error {
          completion(nil, false)
        } else {
            if profile?.data == nil {
                completion(nil, false)
            } else {
                completion(profile, true)
            }
         }
      }
    })
 }
    
 /*
  If it's an existing user and do not have data on server
  then get the data from iCloud encrypt it and dump it on
  to the server.
 */
 func dumpDataFromCloudKitToServer(for user: User, completion: @escaping (Profile?, Error?) -> Void) {
    ProfileBackUpManager.shared.getDataFromiCloud(for: user) { [weak self] (profile, error, _) in
        guard let this = self else { return }
        if let error = error {
            debugPrint("Failed to get profile data from server")
            completion(nil, error)
          } else {
           if let loggedInUserData = profile {
            let profileBackUpData = this.getJsonFromiCloudData(loggedInUserData)
            this.uploadDataToServer(user: user, profileDataString: profileBackUpData) { (profile, error) in
                if let error = error {
                    debugPrint("Failed to uploaded the profile data from iCloud to server")
                    completion(nil, error)
                  } else {
                   debugPrint("Successfully uploaded the profile data from iCloud to server")
                   completion(profile, nil)
                }
              }
           } else {
                completion(nil, error)
            }
        }
    }
 }
 
 /*
  Converting iCloudData to json format.
 */
 func getJsonFromiCloudData(_ loggedUserBackUp: Profile) -> [String: Any] {
   if let dataUrl = loggedUserBackUp.record["data"] as? CKAsset {
    guard let url = dataUrl.fileURL else {
      return [:]
    }
    do {
        let data = try Data(contentsOf: url)
         let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
         return json
       } catch {}
    }
    return [:]
 }

 /*
  If it's an existing user than get data from the server decrypt
  it and update the model.
  */
 func getDataFromServer(completion: @escaping (Profile?, Error?) -> Void) {
    /*Delay added as when app launch userManager class initialize and taken some time for
    Network Manger class to initialize which causes crash*/
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
    NetworkManager.shared.getProfileData { (profile, error) in
        if let error = error {
            debugPrint("Failed to upload profile data to server: \(error)")
            completion(nil, error)
          } else {
           completion(profile, nil)
        }
      }
    })
 }

  /*
   If it's a existing user and data is from iCloud then encrypt it and
   dump it on the the profile backup api.
  */
    func uploadDataToServer(user: User, profileDataString: [String: Any],
                            completion: @escaping (Profile?, Error?) -> Void) {
    if let userId = user.userID {
        let iCloudProfileArray = convertedBackUpData(profileDataString)
        let profileBackupData = AESGCMEncryptionDecryption().encryptData(profileSurveyData: iCloudProfileArray,
                                                                         "\(userId)")
        NetworkManager.shared.uploadProfileData(profileData: profileBackupData,
                                                tag: TagObject.TAG_ALL.rawValue) { (profile, error) in
         if let error = error {
           debugPrint("Failed to upload profile data to server: \(error)")
           completion(nil, error)
         } else {
           completion(profile, nil)
        }
      }
    }
  }
    
  /*
   Get data from profile backup service if data is migrated from iCloud initially.
  */
  func migrateTheProfileBackUpData(user: User, completion: @escaping (Profile?, Error?) -> Void) {
    if Defaults[.isdataMigratedFromiCloud] {
        ServerProfileBackUp.shared.getDataFromServer { (profile, error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(profile, nil)
            }
        }
    } else {
        migrateDataFromiCloud(for: user) { (profile, error) in
             if let error = error {
                completion(nil, error)
            } else {
                completion(profile, nil)
            }
        }
    }
  }
  
  /*
   Migrating data from iCloud to profile backup service incase of
   updated version.
  */
  func migrateDataFromiCloud(for user: User, completion: @escaping (Profile?, Error?) -> Void) {
    ServerProfileBackUp.shared.isProfileDataExistOnServer { [weak self] (profile, isProfileDataOnServer) in
    if isProfileDataOnServer {
        Defaults[.isdataMigratedFromiCloud] = true
        completion(profile, nil)
  } else {
    if config.getAppCommunity() != Constants.defaultCommunity {
        completion(nil, nil)
        return
    }
    ServerProfileBackUp.shared.dumpDataFromCloudKitToServer(for: user) { (profile, error) in
        if let error = error {
            completion(nil, error)
        } else {
            completion(profile, nil)
        }
      }
     }
    }
   }
  
  /*
    If it's a new user then get profile data encrypt it and
    upload it on the the profile backup api.
   */
  func uploadNewUserProfileDataToServer(for user: User,
                                        values: [String: Any],
                                        completion: @escaping (Profile?,
                                                               Error?) -> Void) {
    uploadDataToServer(user: user, profileDataString: values) { (profile, error) in
        if let error = error {
          debugPrint("Failed to upload profile data to server: \(error)")
          completion(nil, error)
        } else {
          completion(profile, nil)
        }
     }
  }
}
