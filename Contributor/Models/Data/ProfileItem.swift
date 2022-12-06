//
//  ProfileItem.swift
//  Contributor
//
//  Created by John Martin on 10/29/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import ObjectMapper

class ProfileItem: NSObject, Mappable {
  var ref: String!
  var uid: String!
  var label: String!
  var labelPt: String?
  var applicableIf: [String: Any] = [:]
  
  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    ref <- map["ref"]
    uid <- map["uid"]
    label <- map["label.en"]
    labelPt <- map["label.pt"]
    applicableIf <- map["applicable_if"]
  }
}
