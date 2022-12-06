//
//  Survey.swift
//  Contributor
//
//  Created by arvindh on 30/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import ObjectMapper

class Survey: NSObject, Mappable {
  var title: String = ""
  var titlePt: String = ""
  var pages: [SurveyPage] = []
  var usePageTitles = true
  var category: SurveyCategory?
  var allowLandscape = false
  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    title <- map["title.en"]
    titlePt <- map["title.pt"]
    pages <- map["pages"]
    usePageTitles <- map["options.use_page_titles"]
    category <- map["category"]
  }
}

class NativeOfferSurvey: NSObject, Mappable {
  var type: String = ""
  var nativeSurvey: Survey?
  required init?(map: Map) {
   super.init()
 }
 
 func mapping(map: Map) {
   type <- map["type"]
   nativeSurvey <- map["spec"]
 }
}

class ExternalSurveyCompletion {
  var eventMsg: String?
  var eventShowPayment: Bool = true
}
