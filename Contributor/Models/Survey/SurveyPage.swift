//
//  SurveyPage.swift
//  Contributor
//
//  Created by arvindh on 30/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import ObjectMapper

class SurveyPage: NSObject, Mappable {
    var title: String = ""
    var titlePt: String = ""
    var blocks: [SurveyBlock] = []
    var includeIf: [String: Any] = [:]
    
    required init?(map: Map) {
        super.init()
    }
    
    func mapping(map: Map) {
        blocks <- map["blocks"]
        title <- map["title.en"]
        titlePt <- map["title.pt"]
        includeIf <- map["include_if"]
    }
}
