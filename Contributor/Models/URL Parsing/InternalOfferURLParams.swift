//
//  SurveyURLParams.swift
//  Contributor
//
//  Created by arvindh on 02/02/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import ObjectMapper

protocol InternalOfferURLParams {}

class CategoryOfferURLParams: NSObject, Mappable, InternalOfferURLParams {
  var category: String!
  var categorySurveyRef: String!
  
  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    category <- map["category"]
    categorySurveyRef <- map["ref"]
  }
}

class EmbeddedOfferURLParams: NSObject, Mappable, InternalOfferURLParams {
  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    // nothing
  }
}
