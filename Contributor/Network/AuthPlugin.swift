//
//  AuthPlugin.swift
//  Contributor
//
//  Created by arvindh on 28/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import Moya
import SwiftyUserDefaults

public struct AuthPlugin: PluginType {
  public let tokenClosure: () -> String?
  
  public init(tokenClosure: @escaping @autoclosure () -> String?) {
    self.tokenClosure = tokenClosure
  }
  
  public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    
    guard let authorizable = target as? AccessTokenAuthorizable else { return request }
    guard let token = tokenClosure(), !token.isEmpty else {return request}
    
    let authorizationType = authorizable.authorizationType
    
    var request = request
    let modelName = UIDevice.modelName
    let iosVersion = UIDevice.current.systemVersion
    switch authorizationType {
    case .bearer:
        let authValue = "Bearer \(Defaults[.loggedInUserAccessToken] ?? "")"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        request.setValue(AppLanguageManager.shared.getLanguage() ?? "en", forHTTPHeaderField: "Accept-Language")
        request.setValue(modelName, forHTTPHeaderField: "device_model")
        request.setValue(iosVersion, forHTTPHeaderField: "device_os_version")
    default:
      break
    }
    
    return request
  }
}
