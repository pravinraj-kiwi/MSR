//
//  Encoding.swift
//  Contributor
//
//  Created by arvindh on 13/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import Alamofire
import Moya

struct JSONArrayEncoding: Alamofire.ParameterEncoding {
  enum JSONArrayEncodingError: Error {
    case notAnArray
  }
  
  static var `default`: JSONArrayEncoding = JSONArrayEncoding()
  
  func encode(_ urlRequest: URLRequestConvertible, with parameters: Alamofire.Parameters?) throws -> URLRequest {
    var urlRequest = try urlRequest.asURLRequest()
    
    guard let parameters = parameters else { return urlRequest }
    
    do {
      guard let array = parameters["jsonArray"] as? [Any] else {
        throw AFError.parameterEncodingFailed(reason: AFError.ParameterEncodingFailureReason.jsonEncodingFailed(error: JSONArrayEncodingError.notAnArray))
      }
      
      let data = try JSONSerialization.data(withJSONObject: array, options: [])
      
      if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      }
        urlRequest.timeoutInterval = 1000 // 10 secs

      urlRequest.httpBody = data
    } catch {
      throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
    }
    
    return urlRequest
  }
}
