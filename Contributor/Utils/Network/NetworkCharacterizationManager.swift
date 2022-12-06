//
//  NetworkCharacterizationManager.swift
//  Contributor
//
//  Created by John Martin on 5/20/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import Foundation
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
import CommonCrypto

class NetworkCharacterizationManager: NSObject {
  static let shared: NetworkCharacterizationManager = {
    let manager = NetworkCharacterizationManager()
    return manager
  }()
  
  let voteInterval: TimeInterval = 3600 * 24 * 7  // i.e. 7 days

  fileprivate var backgroundTaskRunner: BackgroundTaskRunner!

  override init() {
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(onProfileUpdated),
                                           name: .profileUpdated, object: nil)
  }
  
  func voteProfile(voteType: String = "default") {
    os_log("Starting anonymous profile vote", log: OSLog.networkCharacterization, type: .info)
    
    guard let profileStore = UserManager.shared.profileStore else {
      os_log("There is no profile store available, giving up on network vote", log: OSLog.networkCharacterization, type: .error)
      return
    }
    
    guard let profile = profileStore.profile else {
      os_log("There is no profile in the profile store, giving up on network vote", log: OSLog.networkCharacterization, type: .error)
      return
    }
    
    guard let voteGUID = profile.voteGUID else {
      os_log("There is no vote GUID, giving up on network vote", log: OSLog.networkCharacterization, type: .error)
      return
    }
    
    guard profileStore.values.count > 1 else {
      os_log("Skipping the network vote, there is only 1 (DOB, probably) item in the profile", log: OSLog.networkCharacterization, type: .info)
      return
    }
    
    let communitySlugs = UserManager.shared.user?.communities.map { $0.slug } ?? []
    
    backgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
    backgroundTaskRunner.startTask {
        
    let parameters: Parameters = [
            "guid": voteGUID,
            "type": voteType,
            "items": profileStore.values,
            "communities": communitySlugs,
            "country": profileStore[ProfileItemRefs.country] ?? ""
          ]
          
      let url = Constants.baseContributorAPIURL.appendingPathComponent("/v1/profile/update")
        Alamofire.request(url, method: .post, parameters: parameters,
                          encoding: JSONEncoding.default, headers: Helper.getRequestHeader())
        .validate()
        .responseJSON {
          [weak self] response in
          switch response.result {
          case .failure(_):
            os_log("Network vote failed", log: OSLog.networkCharacterization, type: .error)
          default:
            break
          }
          
          Defaults[.previousNetworkVoteDate] = Date()
          os_log("Finished network vote", log: OSLog.networkCharacterization, type: .info)
          self?.backgroundTaskRunner.endTask()
      }
    }
  }
  
  func makePeriodicVoteIfNeeded() {
    var timeForVote = false
    
    if !UserManager.shared.isLoggedIn {
      return
    }
    
    if let lastVoteDate = Defaults[.previousNetworkVoteDate] {
      let date = Date()
      if date.timeIntervalSince(lastVoteDate) > voteInterval {
        timeForVote = true
      }
    } else {
      timeForVote = true
    }
    
    if timeForVote {
      voteProfile(voteType: "periodic-update")
    }
  }
  
  func makeVote() {
    voteProfile(voteType: "test-update")
  }
  
  @objc func onProfileUpdated() {
    voteProfile(voteType: "profile-update")
  }
}
