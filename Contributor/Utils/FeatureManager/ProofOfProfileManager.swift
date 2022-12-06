//
//  ProofOfProfileManager.swift
//  Contributor
//
//  Created by John Martin on 1/4/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import Foundation
import Alamofire
import SwiftyJSON
import CommonCrypto

fileprivate extension String {
  func sha256() -> String {
    if let stringData = self.data(using: String.Encoding.utf8) {
      return hexStringFromData(input: digest(input: stringData as NSData))
    }
    return ""
  }
  
  private func digest(input : NSData) -> NSData {
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
    var hash = [UInt8](repeating: 0, count: digestLength)
    CC_SHA256(input.bytes, UInt32(input.length), &hash)
    return NSData(bytes: hash, length: digestLength)
  }
  
  private func hexStringFromData(input: NSData) -> String {
    var bytes = [UInt8](repeating: 0, count: input.length)
    input.getBytes(&bytes, length: input.length)
    
    var hexString = ""
    for byte in bytes {
      hexString += String(format: "%02x", UInt8(byte))
    }
    
    return hexString
  }
}

class ProofOfProfileManager: NSObject {
  static let shared: ProofOfProfileManager = {
    let manager = ProofOfProfileManager()
    return manager
  }()
  
  fileprivate var callbackBackgroundTaskRunner: BackgroundTaskRunner!
  fileprivate var ackBackgroundTaskRunner: BackgroundTaskRunner!
  
  override init() {
    super.init()
    
    NotificationCenter.default.addObserver(self, selector: #selector(onShouldCheckForPendingQualifications(_:)), name: NSNotification.Name.shouldCheckForPendingQualifications, object: nil)
  }
  
  func checkForPendingQualifications(source: String, completion: @escaping (Int?, Error?) -> Void) {
    if UserManager.shared.isLoggedIn && (UserManager.shared.user?.isAcceptingOffers ?? false) {
      os_log("Getting pending qualifications", log: OSLog.qualification, type: .info)
      NetworkManager.shared.getPendingQualifications(source: source) {
        [weak self] (qualificationRequests, error) in
        guard let this = self else {
          return
        }
        
        if let error = error {
          os_log("Error getting pending notifications on app became active.", log: OSLog.qualification, type: .error)
          completion(nil, error)
        } else {
          
          var foundMatch = false
          for qualificationRequest in qualificationRequests {
            let match = this.runProofOfProfile(qualificationRequest, source: source, postFeedLikelyToChangeOnMatch: false)
            if match {
              foundMatch = true
            }
          }
          
          if foundMatch {
            NotificationCenter.default.post(name: .feedLikelyToChangeSoon, object: nil, userInfo: nil)
          }
          
          completion(qualificationRequests.count, nil)
        }
      }
    }
  }
  
  @objc func onShouldCheckForPendingQualifications(_ notification: Notification) {
    checkForPendingQualifications(source: notification.userInfo?["source"] as? String ?? "unknown") { _, _  in }
  }

  private func matchWithUnencryptedTargeting(targeting: JSON, profileStore: ProfileStore) -> Int {
    var intersectCount = 0
    
    for (item, values) in targeting {
      if item == "age" {
        if let age = profileStore.updateAgeFromDOB() {
          let lower = values["lower"].int ?? Int.min
          let upper = values["upper"].int ?? Int.max
          
          if age >= lower && age <= upper {
            intersectCount += 1
          }
        } else {
          os_log("Age check requested but age not available in profile store.", log: OSLog.qualification, type: .info)
        }
      } else {
        guard let stringValues = values.array else {
          os_log("Unexpected value list found in proof-of-profile request. Expected [String].", log: OSLog.qualification, type: .error)
          return 0
        }
        
        for value in stringValues {
          if let profileValueOfUnknownType = profileStore[item] {
            var profileValues: [AnyHashable]
            if profileValueOfUnknownType is [AnyHashable] {
              profileValues = profileValueOfUnknownType as! [AnyHashable]
            } else {
              profileValues = [profileValueOfUnknownType]
            }
            
            for profileValue in profileValues {
              if profileValue as? String == value.stringValue {
                intersectCount += 1
                break
              }
            }
          }
        }
      }
    }
    return intersectCount
  }
  
  private func matchWithSHA256Targeting(targeting: JSON, profileStore: ProfileStore) -> Int {
    var intersectCount = 0
    for (item, values) in targeting {
      if item == "age" {
        if let age = profileStore.updateAgeFromDOB() {
          let lower = values["lower"].int ?? Int.min
          let upper = values["upper"].int ?? Int.max
          
          if age >= lower && age <= upper {
            intersectCount += 1
          }
        }
        else {
          os_log("Age check requested but age not available in profile store.", log: OSLog.qualification, type: .info)
        }
      } else {
        guard let stringValues = values.array else {
          os_log("Unexpected value list found in proof-of-profile request. Expected [String].", log: OSLog.qualification, type: .error)
          return 0
        }
        
        for value in stringValues {
          var foundValue = false
          
          if let profileValueOfUnknownType = profileStore[item] {
            var profileValues: [AnyHashable]
            if profileValueOfUnknownType is [AnyHashable] {
              profileValues = profileValueOfUnknownType as! [AnyHashable]
            } else {
              profileValues = [profileValueOfUnknownType]
            }

            for profileValue in profileValues {
              if (profileValue as? String)?.sha256() == value.stringValue {
                intersectCount += 1
                foundValue = true
                break
              }
            }
          }

          if foundValue {
            break
          }
        }
      }
    }
    return intersectCount
  }

  func runProofOfProfile(_ qualificationRequest: QualificationRequest, source: String, postFeedLikelyToChangeOnMatch: Bool = true) -> Bool {
    os_log("Starting proof-of-profile with PoP version %{public}@ for sample request %{public}@", log: OSLog.qualification, type: .info, qualificationRequest.popVersion.rawValue, qualificationRequest.sampleRequestIDString)
    
    guard let sampleRequestID = qualificationRequest.sampleRequestID, let callbackURL = qualificationRequest.callbackURL else {
      os_log("Error pulling out bits from qualification request", log: OSLog.qualification, type: .error)
      return false
    }
    
    // send an ack if we are minimally able to parse the request
    ackBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
    ackBackgroundTaskRunner.startTask {
      NetworkManager.shared.ackQualification(sampleRequestID: sampleRequestID, source: source) {
        [weak self] error in
        
        if let _ = error {
          os_log("Qualification ack failed", log: OSLog.qualification, type: .error)
        }
        
        self?.ackBackgroundTaskRunner.endTask()
      }
    }
    
    if !UserManager.shared.isLoggedIn {
      os_log("No logged in user, exiting", log: OSLog.qualification, type: .error)
      return false
    }
    
    guard let profileStore = UserManager.shared.profileStore else {
      os_log("There is no profile store available, giving up on proof-of-profile.", log: OSLog.qualification, type: .error)
      return false
    }
    
    guard let targeting = qualificationRequest.targeting else {
      os_log("No targeting available for proof-of-profile, skipping notification", log: OSLog.qualification, type: .error)
      return false
    }
    
    var intersectCount = 0
    switch qualificationRequest.popVersion {
    case .version2:
      intersectCount = self.matchWithSHA256Targeting(targeting: targeting, profileStore: profileStore)
    default:
      intersectCount = self.matchWithUnencryptedTargeting(targeting: targeting, profileStore: profileStore)
    }
    
    let foundMatch = intersectCount == targeting.count && intersectCount != 0
    
    // if we match everything, respond to callback
    if foundMatch {
      os_log("Found match for request %{public}@", log: OSLog.qualification, type: .info, qualificationRequest.sampleRequestIDString)
      
      guard let userID = UserManager.shared.user?.userID else {
        os_log("No user ID for some reason, skipping proof-of-profile callback.", log: OSLog.qualification, type: .error)
        return false
      }
      
      let communitySlugs = UserManager.shared.user?.communities.map { $0.slug } ?? []
      
      var quotaValues: [String: AnyHashable] = [:]
      if let quotaItems = qualificationRequest.quotaItems {
        for ref in quotaItems {
          if profileStore.contains(ref) {
            quotaValues[ref] = profileStore[ref]
          }
        }
      }

      let parameters: Parameters = [
        "srid": sampleRequestID,
        "cid": userID,
        "communities": communitySlugs,
        "quota_values": quotaValues
      ]
      
      callbackBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
      callbackBackgroundTaskRunner.startTask {
        Alamofire.request(callbackURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
          .validate()
          .responseJSON {
            [weak self] response in
            switch response.result {
            case .failure(_):
              os_log("Proof-of-profile callback failed", log: OSLog.qualification, type: .error)
            default:
              break
            }

            self?.callbackBackgroundTaskRunner.endTask()
        }
      }

      if postFeedLikelyToChangeOnMatch {
        NotificationCenter.default.post(name: .feedLikelyToChangeSoon, object: nil, userInfo: nil)
      }
    } else {
      os_log("No match", log: OSLog.qualification, type: .info)
    }
    
    return foundMatch
  }
}
