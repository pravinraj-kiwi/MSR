//
//  ProfileItemResolutionResponse.swift
//  Contributor
//
//  Created by John Martin on 12/29/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import ObjectMapper

class ProfileItemResolutionResponse: NSObject, Mappable {
  var found: Bool!
  var items: [String: String] = [:]
  
  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    found <- map["found"]
    items <- map["items"]
  }
}
