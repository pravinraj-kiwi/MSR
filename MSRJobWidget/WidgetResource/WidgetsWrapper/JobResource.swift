//
//  JobResource.swift
//  Contributor
//
//  Created by KiwiTech on 10/20/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

enum RequestStatus: Int {
  case started = 4
  case open = 10
}

protocol JobResourceProtocol {
  func getJobOffer(completionHandler: @escaping (Result<[JobOffer], Error>) -> Void)
}

struct JobResource: JobResourceProtocol {
   
 private let kAppGroupName = widgetConfig.getAppGroup()
    
func getRequest() -> URLRequest {
  let path = "/api/v1/offers?ordering=-offer_date&max_response_status=10&request_status=10&declined=false"
  var request = URLRequest(url: URL(string: "\(widgetConfig.getApiURL())\(path)")!)
  request.httpMethod = "GET"
  var accessTokens = ""
  if let sharedContainer = UserDefaults(suiteName: kAppGroupName),
     let accessToken = sharedContainer.string(forKey: SuitDefaultName.accessToken) {
    accessTokens = "Bearer \(accessToken)"
  }
  let httpHeader = ["platform": "ios",
                    "version": "1.27.0.0",
                    "edition": widgetConfig.getAppCommunity(),
                    "Content-Type": "application/json",
                    "Authorization": "\(accessTokens)"]
    request.allHTTPHeaderFields = httpHeader
    return request
}

func getJobOffer(completionHandler: @escaping (Result<[JobOffer], Error>) -> Void) {
  URLSession.shared.dataTask(with: getRequest()) { data, _, error in
    guard error == nil else {
       completionHandler(.failure(error!))
       return
    }
    do {
      let offer = try JSONDecoder().decode([JobOffer].self, from: data!)
      debugPrint(offer)
      completionHandler(.success(offer))
    } catch {
      debugPrint(error)
      completionHandler(.failure(error))
    }
   }.resume()
  }
}
