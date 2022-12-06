//
//  ProfileBackUpManager.swift
//  Contributor
//
//  Created by arvindh on 16/04/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import CloudKit
import SwiftyUserDefaults

class ProfileBackUpManager: NSObject {
  static let shared: ProfileBackUpManager = {
    let manager = ProfileBackUpManager()
    return manager
  }()
  
  enum CloudKitManagerError: Error {
    case general
  }

  var privateDatabase: CKDatabase?
  var container: CKContainer?
  
  override init() {
    super.init()
    configureCloudKit()
  }
    
  /*
    This check Config.getAppCommunity() == Constants.defaultCommunity is added
    because broccoli app will not have cloudKit as no measure user will
    able to sign on broccoli.
  */
  func configureCloudKit() {
    if config.getAppCommunity() == Constants.defaultCommunity {
        container = CKContainer.default()
        privateDatabase = container?.privateCloudDatabase
      }
  }
  
  /*
    This gets the data from the server if user has migrated otherwise from iCloud
     and uploaded to server MAIN METHOD
  */
  func fetchOrCreateProfile(for user: User,
                            completion: @escaping (Profile?, Error?) -> Void) {
        ServerProfileBackUp.shared.migrateTheProfileBackUpData(user: user) {[weak self] (profile, error) in
         guard let _ = self else { return }
         if let error = error {
                completion(nil, error)
            } else {
                completion(profile, nil)
          }
      }
  }
    
  /*
     Getting Data from iCloud for those user who had already filled any survey before migration.
  */
  func getDataFromiCloud(for user: User,
                         completion: @escaping (Profile?, Error?, [CKRecord]?) -> Void) {
     let predicate = NSPredicate(format: "userID = %i", user.userID)
     let query = CKQuery(recordType: Profile.recordType, predicate: predicate)
     
    let token = FileManager.default.ubiquityIdentityToken
    if token == nil {
        completion(nil, nil, nil)
        return
    }
    privateDatabase?.perform(query, inZoneWith: nil) { [weak self] (results, error) in
         guard let _ = self else {
           return
         }
     DispatchQueue.main.async {
        if let error = error {
            completion(nil, error, nil)
        } else {
            if let result = results?.first {
             let profile = Profile(record: result)
             if profile.voteGUID == nil {
                 profile.voteGUID = Profile.generateVoteGUID()
               }
               completion(profile, nil, results)
             } else {
               completion(nil, nil, nil)
             }
          }
        }
     }
  }

  /*
   API calling to send survey filled by the user on server.
  */
  func saveProfile(for user: User, values: [String: AnyHashable],
                   completion: @escaping (Profile?, Error?) -> Void) {
        ServerProfileBackUp.shared.uploadNewUserProfileDataToServer(for: user,
                                                                    values: values) { (profile, error) in
            if let error = error {
              completion(nil, error)
            } else {
                completion(profile, nil)
            }
        }
     }
  }
