//
//  NetworkRequestRetrier.swift
//  Contributor
//
//  Created by arvindh on 20/02/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import Alamofire
import Moya
import SwiftyUserDefaults
import KeychainSwift

class NetworkRequestRetrier: NSObject, RequestRetrier {
  var retries: [String: Int] = [:]
  
  func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {  
    guard let error = error as? AFError, let statusCode = error.responseCode else {
      completion(false, 0)
      return
    }

    if [401, 403].contains(statusCode) {
      os_log("Got an HTTP 403 error, posting a shouldLogout notification.", log: OSLog.network, type: .error)
        //Refresh token with the current login user
        let currentVersion = "\(Bundle.main.releaseVersionNumber ?? "0.0").\(Bundle.main.buildVersionNumber ?? "0")"
        if let refreshToken = Defaults[.loggedInUserRefreshToken],
            let _ = Defaults[.loggedInUserAccessToken],
            Defaults[.currentAppVersion] == currentVersion {
            if ConnectivityUtils.isConnectedToNetwork() == false {
                completion(false, 0)
                return
            }
            NetworkManager.shared.refreshToken(refreshToken) { (accessToken, statusCode, error) in
                if error != nil {
                    NotificationCenter.default.post(name: NSNotification.Name.shouldLogout, object: nil, userInfo: nil)
                    completion(false, 0)
                    return
                } else {
                    if statusCode == 200 {
                        Defaults[.loggedInUserAccessToken] = accessToken
                    }
                    completion(false, 0)
                    return
                }
            }
        }
    }
    
    guard canRetry(statusCode: statusCode) else {
      completion(false, 0)
      return
    }
    
    guard let urlString = request.response?.url?.absoluteString else {
      completion(false, 0)
      return
    }
    
    let retryCount = retries[urlString] ?? 0
    let newRetryCount = retryCount + 1
    let retryInterval = pow(Double(newRetryCount), 2)
    
    if retryCount < 5 {
      os_log("Retrying in the NetworkRequestRetrier, attempt %{public}d for %{public}@", log: OSLog.network, type: .error, retryCount, urlString)
      retries[urlString] = newRetryCount
      completion(true, retryInterval)
    }
    else {
      os_log("Giving up in the NetworkRequestRetrier for %{public}@", log: OSLog.network, type: .error, urlString)
      retries.removeValue(forKey: urlString)
      completion(false, 0)
    }
  }
  
  fileprivate func canRetry(statusCode: Int) -> Bool {
    return statusCode >= 500
  }
}
