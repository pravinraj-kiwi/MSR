//
//  NetworkManager+Setting.swift
//  Contributor
//
//  Created by KiwiTech on 10/14/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya
import SwiftyUserDefaults
import ObjectMapper
import Moya_ObjectMapper
import Alamofire
import os

extension NetworkManager {
@discardableResult
func updatePassword(currentPassword: String, _ password: String,
                    completion: @escaping (Error?) -> Void) -> Cancellable? {
   guard let _ = self.userManager?.user else {
      completion(APIError.invalidUser)
      return nil
    }
    let path = ContributorAPI.updatePassword(currentPassword, password)
    return provider.request(path) { [weak self] (result) in
      guard let _ = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(error)
      case .success(_):
        completion(nil)
      }
   }
}
    
@discardableResult
func logoutUser(accessToken: String, completion: @escaping (Int, Error?) -> Void) -> Cancellable? {
  return provider.request(ContributorAPI.logout(accessToken)) { [weak self] (result) in
    guard let _ = self else {
     return
    }
   switch result {
   case .failure(let error):
    if let error = error as? MoyaError,
        let statusCode = error.response?.statusCode {
      completion(statusCode, error)
    }
    case .success(let response):
      completion(response.statusCode, nil)
    }
  }
}
    
@discardableResult
func deletAccount(completion: @escaping (Error?) -> Void) -> Cancellable? {
   return provider.request(ContributorAPI.deleteAccountRequest) { [weak self] (result) in
     guard let _ = self else {
         return
      }
       completion(result.error)
   }
}
        
@discardableResult
func sendSupportEmail(selectedConcern: String, _ message: String,
                      shouldSendEmailCopy: Bool,
                      completion: @escaping (Error?) -> Void) -> Cancellable? {
    let path = ContributorAPI.supportEmail(selectedConcern, message, shouldSendEmailCopy)
    return provider.request(path) { [weak self] (result) in
      guard let _ = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(error)
      case .success(_):
        completion(nil)
      }
   }
}
  
@discardableResult
func checkIfIsTestUser(completion: @escaping (StatusData?,
                                              Error?) -> Void) -> Cancellable? {
  let path = ContributorAPI.getTestUserStatus
  return provider.request(path) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
        do {
            let status = try response.map(StatusData.self)
            completion(status, nil)
        } catch {
            completion(nil, error)
        }
    }
   }
  }
}

struct StatusData: Codable {
    var isTestUser: Bool = false
   
    private enum CodingKeys: String, CodingKey {
        case isTestUser = "is_test_user"
    }
}
