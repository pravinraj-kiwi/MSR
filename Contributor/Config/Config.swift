//
//  Config.swift
//  Contributor
//
//  Created by arvindh on 30/07/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation

enum App {
  case local, staging, staging2, production, broccoliLocal,
    broccoliStaging, broccoliProduction
}

class ConfigClass: NSObject {
  fileprivate static let shared: ConfigClass = {
    let config = ConfigClass()
    return config
  }()
  let currentApp: App = {
    guard let targetName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
      return .staging
    }
    switch targetName {
    case "MSR": return .production
    case "Measure Staging": return .staging
    case "Measure Staging 2": return .staging2
    case "Measure Local": return .local
    case "Broccoli Local": return .broccoliLocal
    case "Broccoli Staging 2": return .broccoliStaging
    case "Broccoli": return .broccoliProduction
    default: return .staging
    }
  }()
  var isDevBuild: Bool {
    return [App.local, App.staging, App.staging2].contains(currentApp)
  }
  func getAppCommunity() -> String {
    let currentApp = config.currentApp
    switch currentApp {
    case .production, .staging, .staging2, .local:
        return "measure"
    case .broccoliLocal, .broccoliStaging, .broccoliProduction:
        return "broccoli"
    }
   }
  func getAppGroup() -> String {
     let currentApp = config.currentApp
      switch currentApp {
      case .staging, .staging2, .local:
        return "group.com.measureprotocol.contributor.staging2"
      case .production:
        return "group.com.measureprotocol.contributor.production"
      default: break
       }
    return ""
    }
 }
let config = ConfigClass.shared
