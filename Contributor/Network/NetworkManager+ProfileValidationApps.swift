//
//  NetworkManager+ProfileValidationApps.swift
//  Contributor
//
//  Created by KiwiTech on 3/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya
import Alamofire
import SwiftyUserDefaults
import ObjectMapper
import Moya_ObjectMapper

extension NetworkManager {
enum LinkedinAccounts: String {
    case secretKey = "OziWcilTaVUeRW0Q"
    case cliendId = "81cx5sapmrovjn"
    case redirectURI = "https://www.google.com/"
    case authorizationEndPoint = "https://www.linkedin.com/oauth/v2/authorization"
    case accessTokenEndPoint = "https://www.linkedin.com/oauth/v2/accessToken"
}

@discardableResult
func checkIfAppConnected(completion: @escaping ([ConnectedAppData]?, Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.getConnectedAppStatus) { [weak self] (result) in
        guard let _ = self else {
            return
        }
        switch result {
        case .failure(let error):
            completion(nil, error)
        case .success(let response):
            do {
                let connectedAppData = try response.map([ConnectedAppData].self)
                completion(connectedAppData, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}

@discardableResult
func updateLinkedinStatus(adType: String, completion: @escaping (Error?) -> Void) -> Cancellable? {
    return provider.request(ContributorAPI.linkedinAdClicked(adType)) { [weak self] (result) in
        guard let _ = self else {
            return
        }
        completion(result.error)
    }
}

@discardableResult
func updateAuthenticatedLinkedinUser(linkedinId: String,
                                     completion: @escaping (Error?) -> Void) -> Cancellable? {
    let parameter = LinkedinConnectParams(linkedinId: linkedinId.md5Value)
    return provider.request(ContributorAPI.linkedinConnect(parameter)) { (result) in
        switch result {
        case .failure(let error):
          completion(error)
        case .success(_):
          completion(nil)
        }
    }
}

@discardableResult
func updateAuthenticatedFacebookUser(facebookId: String,
                                     completion: @escaping (Error?) -> Void) -> Cancellable? {
    let parameter = FacebookConnectParams(facebookId: facebookId.md5Value)
    return provider.request(ContributorAPI.facebookConnect(parameter)) { (result) in
        switch result {
        case .failure(let error):
           completion(error)
        case .success(_):
           completion(nil)
        }
    }
}

func getLinkedinUserAccessToken(authorizationCode: String,
                                completion: @escaping (String, Error?) -> Void) {
    let grantType = "authorization_code"
    let redirectURI = LinkedinAccounts.redirectURI.rawValue
    let redirectURL = redirectURI.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)
    var postParams = "?grant_type=\(grantType)&"
    postParams += "code=\(authorizationCode)&"
    postParams += "redirect_uri=\(redirectURL ?? "")&"
    postParams += "client_id=\(LinkedinAccounts.cliendId.rawValue)&"
    postParams += "client_secret=\(LinkedinAccounts.secretKey.rawValue)"
    let url = LinkedinAccounts.accessTokenEndPoint.rawValue + postParams
    Alamofire.request(url, method: .post, parameters: [:], encoding: JSONEncoding.default)
      .validate()
      .responseJSON { response in
        switch response.result {
        case .success(let response):
          if let result = response as? NSDictionary {
            if let accessToken = result["access_token"] as? String {
                completion(accessToken, nil)
            }
          }
        case .failure:
            completion("", response.result.error)
        }
    }
}

func getLinkedinUserData(authorizationCode: String,
                         completion: @escaping (LinkedinAccount?, Error?) -> Void) {
    getLinkedinUserAccessToken(authorizationCode: authorizationCode) { (accessToken, error) in
        let targetUrl = "https://api.linkedin.com/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))"
    Alamofire.request(targetUrl, encoding: JSONEncoding.default,
                      headers: ["Authorization": "Bearer \(accessToken)"])
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let response):
                var data = LinkedinAccount()
                if let result = response as? NSDictionary {
                    data.linkedinId = result["id"] as? String
                    completion(data, nil)
                }
            case .failure:
                completion(nil, response.result.error)
            }
       }
    }
}

func getAuthoriztionURL() -> String {
    let responseType = "code"
    let redirectURI = LinkedinAccounts.redirectURI.rawValue
    let redirectURL = redirectURI.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)
    let state = "linkedin\(Date().timeIntervalSince1970)"
    let scope = "r_liteprofile%20r_emailaddress%20w_member_social"
    var authorizationURL = "\(LinkedinAccounts.authorizationEndPoint.rawValue)?"
    authorizationURL += "response_type=\(responseType)&"
    authorizationURL += "client_id=\(LinkedinAccounts.cliendId.rawValue)&"
    authorizationURL += "redirect_uri=\(redirectURL ?? "")&"
    authorizationURL += "state=\(state)&"
    authorizationURL += "scope=\(scope)"
    return authorizationURL
  }
}
