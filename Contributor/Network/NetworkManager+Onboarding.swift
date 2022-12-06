//
//  NetworkManager+Onboarding.swift
//  Contributor
//
//  Created by KiwiTech on 1/12/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import Moya_ObjectMapper
import Alamofire
import os
import Kingfisher
import SDWebImage

extension NetworkManager {
    
@discardableResult
func getOnboardingTemplate(template: String, completion: @escaping ([OnboardingMessage]?,
                                                                    Error?) -> Void) -> Cancellable? {
  return provider.request(ContributorAPI.getOnboardingTemplate(template)) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        debugPrint(response)
        let template = try response.map([OnboardingMessage].self)
        completion(template, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
 }
}
