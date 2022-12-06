//
//  ProfileStore.swift
//  Contributor
//
//  Created by arvindh on 29/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import SwiftyUserDefaults

class ProfileStore: NSObject {
  fileprivate(set) var values: [String: AnyHashable] = [:]
  
  var user: User
  let key: String
  
  subscript(key: String) -> AnyHashable? {
    return self.values[key]
  }
  
  init(user: User) {
    self.user = user
    self.key = "profileStore-\(self.user.userID!)"
    super.init()
    
    loadValues()
  }
  
  func keys() -> Array<String> {
    return Array(self.values.keys)
  }
  
  fileprivate func loadValues() {
    self.values = UserDefaults.standard.value(forKey: self.key) as? [String: AnyHashable] ?? [:]
  }
    
  
  func save() {
    UserDefaults.standard.set(values, forKey: self.key)
  }
  
  func set(values newValues: [String: AnyHashable]) {
    for (k, v) in newValues {
      self.values[k] = v
    }
    
    os_log("Num keys in store is now: %{public}d", log: OSLog.profileStore, type: .info, values.count)

    save()
  }
  
  func values(for survey: Survey) -> [String: BlockResponseComponent] {
    var valuesForSurvey: [String: BlockResponseComponent] = [:]
    
    for page in survey.pages {
      for block in page.blocks {
        guard let Response = block.widgetType?.associatedClass, let jsonValue = self[block.blockID] else {
          continue
        }
        
        valuesForSurvey[block.blockID] = Response.init(jsonValue: jsonValue)
      }
    }
    
    return valuesForSurvey
  }
}
