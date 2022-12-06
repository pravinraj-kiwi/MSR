//
//  NetworkManager+Community.swift
//  Contributor
//
//  Created by Mini on 22/05/20.
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
 func getCommunity(communitySlug: String, completion: @escaping (Community?, Error?) -> Void) -> Cancellable? {
   let communityApiPath = ContributorAPI.getCommunity(communitySlug: communitySlug)
   return provider.request(communityApiPath) { [weak self] (result) in
     guard let _ = self else {
       return
     }
     switch result {
     case .failure(let error):
       completion(nil, error)
     case .success(let response):
       do {
         let community = try response.map(Community.self)
         completion(community, nil)
       } catch {
         completion(nil, error)
       }
     }
   }
 }
 
 @discardableResult
 func joinCommunity(_ params: JoinCommunityParams, completion: @escaping (Error?) -> Void) -> Cancellable? {
   return provider.request(ContributorAPI.joinCommunity(params)) { [weak self] (result) in
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
}
