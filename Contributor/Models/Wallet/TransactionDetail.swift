//
//  TransactionDetail.swift
//  Contributor
//
//  Created by KiwiTech on 8/31/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import ObjectMapper

class TransactionDetail: NSObject, Mappable {
  var transactionID: Int?
  var titleIcon: String?
  var title: String?
  var subTitle: String?
  var detailHeader: [Sections]?
  
  required init?(map: Map) {
    super.init()
  }
    
  func mapping(map: Map) {
    transactionID <- map["id"]
    titleIcon <- map["title_icon"]
    title <- map["title"]
    subTitle <- map["sub_title"]
    detailHeader <- map["sections"]
  }
}

class Sections: NSObject, Mappable {
  var heading: String?
  var data: [TransactionData]?
  
  required init?(map: Map) {
    super.init()
  }
    
  func mapping(map: Map) {
    heading <- map["heading"]
    data <- map["data"]
  }
}

class TransactionData: NSObject, Mappable {
  var label: String?
  var type: String?
  var value: Any?
  var style: String?
  var detailsAvailable: Bool?
  var detailType: String?
  var detailURL: String?
  var shouldShowTopCorners: Bool = false
  var shouldShowBottomCorners: Bool = false

  required init?(map: Map) {
    super.init()
 }
    
func mapping(map: Map) {
  label <- map["label"]
  type <- map["type"]
  value <- map["value"]
  style <- map["style"]
  detailsAvailable <- map["details_available"]
  detailType <- map["type"]
  detailURL <- map["details_url"]
  }
}
