//
//  ProfileBackUp+API.swift
//  Contributor
//
//  Created by Kiwitech on 27/03/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya
import Alamofire
import SwiftyUserDefaults
import ObjectMapper
import Moya_ObjectMapper
import os

extension NetworkManager {
 /*
  Calling api to upload profile data on profile backup service
  POST /api/v1/profile-backup
 */
 @discardableResult
 func uploadProfileData(profileData: String, tag: String,
                        completion: @escaping (Profile?, Error?) -> Void) -> Cancellable? {
    debugPrint("Updated the profile data to server")
    return provider.request(ContributorAPI.updateProfileBackUp(profileData, tag)) {[weak self] (result) in
      guard let _ = self else {
            return
        }
        switch result {
        case .failure(let error):
            completion(nil, error)
        case .success(let response):
            do {
              let profileData = try response.map(ProfileBackUpData.self)
              let profile = Profile()
                if let dateString = profileData.modifiedDate,
                   let date = Utilities.updateToDate(dateString: dateString) {
                 profile.modifiedAt = date
              }
              completion(profile, nil)
            } catch {
              completion(nil, error)
            }
        }
    }
 }
    
 /*
  Calling api to get profile data from profile backup service
  GET /api/v1/profile-backup/all
 */
 @discardableResult
 func getProfileData(completion: @escaping (Profile?, Error?) -> Void) -> Cancellable? {
    debugPrint("Getting profile data from server")
    return provider.request(ContributorAPI.getProfileBackUpData) { [weak self] (result) in
          guard let _ = self else {
                return
            }
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let response):
                do {
                    let profileData = try response.map(ProfileBackUpData.self)
                    if profileData.encryptedData != nil {
                        let profile = Profile()
                        profile.data = profileData.encryptedData
                        if let dateString = profileData.modifiedDate,
                           let date = Utilities.updateToDate(dateString: dateString) {
                           profile.modifiedAt = date
                        }
                        profile.changeTag = profileData.tag
                        profile.userID = profileData.userId
                        completion(profile, nil)
                    } else {
                        completion(nil, nil)
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
 }
