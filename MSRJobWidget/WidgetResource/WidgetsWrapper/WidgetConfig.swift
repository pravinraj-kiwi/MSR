//
//  WidgetConfig.swift
//  Contributor
//
//  Created by KiwiTech on 10/20/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import Foundation

enum App {
  case staging2Widget, productionWidget
}

class WidgetConfig: NSObject {
fileprivate static let shared: WidgetConfig = {
    let config = WidgetConfig()
    return config
}()
  
let currentApp: App = {
 guard let targetName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
    return .staging2Widget
 }
 switch targetName {
 case "MSRJobWidget": return .productionWidget
 case "MSRJobWidget Staging 2": return .staging2Widget
 default: return .staging2Widget
 }
}()
  
func getAppCommunity() -> String {
  let currentApp = widgetConfig.currentApp
  switch currentApp {
  case .staging2Widget, .productionWidget:
    return "measure"
  }
}
    
func getApiURL() -> String {
  let currentApp = widgetConfig.currentApp
  switch currentApp {
  case .staging2Widget:
    return "http://contributor-dev-2.measureprotocol.com"
  case .productionWidget:
    return "https://contributor.measureprotocol.com"
   }
}

func getAppGroup() -> String {
  let currentApp = widgetConfig.currentApp
  switch currentApp {
  case .staging2Widget:
    return "group.com.measureprotocol.contributor.staging2"
  case .productionWidget:
    return "group.com.measureprotocol.contributor.production"
   }
  }
}

let widgetConfig = WidgetConfig.shared
