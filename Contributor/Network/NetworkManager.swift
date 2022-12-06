//
//  NetworkManager.swift
//  Contributor
//
//  Created by arvindh on 28/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import Moya
import SwiftyUserDefaults
import ObjectMapper
import Moya_ObjectMapper
import Alamofire
import KeychainSwift

enum APIError: Error {
  case invalidUser
}

class NetworkManager: NSObject {
  static let shared: NetworkManager = {
  let manager = NetworkManager(userManager: UserManager.shared)
  return manager
}()
  
var userManager: UserManager?
lazy var provider: MoyaProvider<ContributorAPI> = {
    let provider = MoyaProvider<ContributorAPI>(
      plugins: [
        AuthPlugin(
            tokenClosure: Defaults[.loggedInUserAccessToken]
        )
      ]
    )
    provider.manager.retrier = NetworkRequestRetrier()
    return provider
}()
  
convenience init(userManager: UserManager, provider: MoyaProvider<ContributorAPI>? = nil) {
    self.init()
    self.userManager = userManager
    self.userManager?.networkManager = self
    if let provider = provider {
      self.provider = provider
    }
    if let _ = Defaults[.loggedInUserRefreshToken],
        let _ = Defaults[.loggedInUserAccessToken] {
        reloadCurrentUser(completion: {_ in })
        getExchangeRates(completion: {_, _ in })
    }
}
  
@discardableResult
func signup(_ params: SignupParams, completion: @escaping (Error?) -> Void) -> Cancellable {
    return provider.request(ContributorAPI.signup(params)) {
      [weak self] (result) in
      guard let this = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(error)
      case .success(let response):
        do {
          let user = try response.map(User.self)
          this.userManager?.saveAccessToken(user: user)
          this.userManager?.saveRefreshToken(user: user)
          this.userManager?.setUser(user)
          completion(nil)
        } catch {
          completion(error)
        }
      }
    }
}
      
@discardableResult
func loginUser(_ params: AuthParams, completion: @escaping (Error?) -> Void) -> Cancellable {
    return provider.request(ContributorAPI.loginUser(params)) {
      [weak self] (result) in
      guard let this = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(error)
      case .success(let response):
        do {
          let user = try response.map(User.self)
          this.userManager?.saveAccessToken(user: user)
          this.userManager?.saveRefreshToken(user: user)
          this.userManager?.setUser(user)
          completion(nil)
        } catch {
          completion(error)
        }
      }
    }
}
  
@discardableResult
func reloadCurrentUser(completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.reloadCurrentUser) {
        [weak self] (result) in
        guard let this = self else {
          return
        }
        switch result {
        case .failure(let error):
          completion(error)
        case .success(let response):
          do {
            let user = try response.map(User.self)
            this.userManager?.setUser(user)
            completion(nil)
          } catch {
            completion(error)
          }
        }
      }
}
  
@discardableResult
func updateUser(_ userInfo: [User.CodingKeys: Any],
                completion: @escaping (Error?) -> Void) -> Cancellable? {
    os_log("Updating user with NetworkManager", log: OSLog.network, type: .info)
    guard let _ = self.userManager?.user else {
      completion(APIError.invalidUser)
      return nil
    }
    return provider.request(ContributorAPI.updateUser(userInfo)) {
      [weak self] (result) in
      guard let this = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(error)
      case .success(let response):
        do {
          let user = try response.map(User.self)
          this.userManager?.setUser(user)
          completion(nil)
        } catch {
          completion(error)
        }
      }
    }
}
      
@discardableResult
func refreshToken(_ logInRefreshToken: String,
                  completion: @escaping (String, Int,
                                         Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.refreshAccessToken(logInRefreshToken)) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      switch result {
      case .failure(let error):
        if let error = error as? MoyaError,
            let statusCode = error.response?.statusCode {
            completion("", statusCode, error)
        }
      case .success(let response):
        do {
          guard let json = try response.mapJSON() as? [String: String] else {
            return
          }
          completion(json["access"] ?? "", response.statusCode, nil)
        } catch {
          completion("", response.statusCode, nil)
        }
      }
   }
}
  
@discardableResult
func getUserEmailValidationStatus(completion: @escaping (Bool?,
                                                         Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.getUserEmailValidationStatus) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let response):
        do {
          guard let json = try response.mapJSON() as? [String: Bool] else {
            os_log("Error parsing response in getUserEmailValidationStatus", log: OSLog.signUp)
            return
          }
          completion(json["has_validated_email"], nil)
        } catch {
          completion(nil, error)
        }
      }
    }
}

@discardableResult
func getUserStats(completion: @escaping (UserStats?, Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.getUserStats) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let response):
        do {
          let stats = try response.mapObject(UserStats.self)
          completion(stats, nil)
        } catch {
          completion(nil, error)
        }
      }
    }
}

@discardableResult
func resendValidationEmail(_ email: String,
                           completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.resendValidationEmail(email)) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      completion(result.error)
    }
}
    
@discardableResult
func sendOtpOnPhoneNumber(_ params: PhoneNumberParams,
                          completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.getOtpSms(params)) {
        [weak self] (result) in
        guard let _ = self else {
            return
        }
        completion(result.error)
    }
}
    
@discardableResult
func verifyRecievedOtp(_ params: VerifyOtpParams,
                       completion: @escaping (User?,
                                              Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.verifyOtp(params)) {
        [weak self] (result) in
        guard let this = self else {
            return
        }
        switch result {
        case .failure(let error):
            completion(nil, error)
        case .success(let response):
            do {
                let user = try response.map(User.self, atKeyPath: "user")
                this.userManager?.setUser(user)
                completion(user, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
    
@discardableResult
func validateLocation(completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.validateLocation) {
      [weak self] (result) in
      guard let this = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(error)
      case .success(let response):
        do {
          let user = try response.map(User.self, atKeyPath: "user")
          this.userManager?.setUser(user)
          completion(nil)
        } catch {
          completion(error)
        }
      }
   }
}

@discardableResult
func getProfileItemsForCategory(category: SurveyType,
                                completion: @escaping ([ProfileItem]?,
                                                       Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.getProfileItemsForCategory(category: category)) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let response):
        do {
          let items = try response.mapArray(ProfileItem.self)
          completion(items, nil)
        } catch {
          completion(nil, error)
        }
      }
    }
}

@discardableResult
func updateDeviceToken(_ token: String,
                       completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.updateDeviceToken(token)) {
      result in
      completion(result.error)
    }
}

@discardableResult
func deleteDeviceToken(_ token: String,
                       completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.deleteDeviceToken(token)) {
      result in
      completion(result.error)
    }
}

@discardableResult
func updateAppsFlyerIdentifier(_ appsFlyerID: String,
                               completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.updateAppsFlyerIdentifier(appsFlyerID)) {
      result in
      completion(result.error)
    }
}

@discardableResult
func addProfileEvent(source: String,
                     itemRefs: [String],
                     completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.addProfileEvent(source: source, itemRefs: itemRefs)) {
      (result) in
      switch result {
      case .failure(let error):
        completion(error)
      case .success(_):
        completion(nil)
      }
    }
}
    
@discardableResult
func getPendingQualifications(source: String,
                              completion: @escaping ([QualificationRequest],
                                                     Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.getPendingQualifications(source: source)) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      
      switch result {
      case .failure(let error):
        completion([], error)
      case .success(let response):
        do {
          let qualificationRequests = try response.mapArray(QualificationRequest.self)
          completion(qualificationRequests, nil)
        } catch {
          print(error.localizedDescription)
          completion([], error)
        }
      }
   }
}

@discardableResult
func ackQualification(sampleRequestID: Int,
                      source: String,
                      completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.ackQualification(sampleRequestID: sampleRequestID, source: source)) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      completion(result.error)
    }
}
  
@discardableResult
func requestPasswordReset(email: String,
                          completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.resetPassword(email: email)) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      completion(result.error)
    }
}
    
@discardableResult
func resolvePostalCode(countryUID: String,
                       postalCode: String,
                       completion: @escaping (ProfileItemResolutionResponse?,
                                              Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.resolvePostalCode(countryUID: countryUID,
                                                             postalCode: postalCode)) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let response):
        do {
          let profileItemResolutionResponse = try response.mapObject(ProfileItemResolutionResponse.self)
          completion(profileItemResolutionResponse, nil)
        } catch {
          completion(nil, error)
        }
      }
   }
}
  
@discardableResult
func createProfileMaintenanceJob(items: [ProfileItem],
                                 completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.createProfileMaintenanceJob(items: items)) {
      [weak self] (result) in
      guard let _ = self else {
        return
      }
      completion(result.error)
    }
}
    
func getAppsAvailabilityStatus(completion: @escaping (Bool?, MeasureAppStatus) -> Void) {
  print("Measure App Status")
  Alamofire.request(getAppStatusURL(), method: .get, encoding: JSONEncoding.default)
    .validate()
    .responseJSON {
      [weak self] response in
         guard let _ = self else {
           return
         }
         switch response.result {
         case .failure:
             completion(false, .none)
         case .success(let response):
             if let result = response as? NSDictionary,
             let appStatus = result.value(forKey: Constants.appStatusKey) as? String,
             let status = MeasureAppStatus(rawValue: appStatus) {
             completion(true, status)
        }
      }
   }
}

func getAppStatusURL() -> String {
    let randomLength = Int.random(in: 10..<21)
    let randomValue = Utilities.randomString(length: randomLength)
    let url = Constants.appStatusURL + "?\(randomValue)"
    print("App Status URL: \(url)")
    return url
 }
}
