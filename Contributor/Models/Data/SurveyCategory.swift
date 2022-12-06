//
//  DataSurveyCategory.swift
//  Contributor
//
//  Created by arvindh on 18/12/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import ObjectMapper

class Category: NSObject, Mappable {
  var statTiles: [StatTiles]?
  var totalCount: Int?
  var completedCount: Int?
  var surveyCategory: [SurveyCategory]?
    
  required init?(map: Map) {
    super.init()
  }
    
  func mapping(map: Map) {
    statTiles <- map["stat_tiles"]
    totalCount <- map["total_count"]
    completedCount <- map["completed_count"]
    surveyCategory <- map["categories"]
   }
}

class StatTiles: NSObject, Mappable {
  var tileType: String?
  var title: String?
  var subtitle: String?
  var value: String?
  var showPercentageSign: Bool?
  var showProgressBar: Bool?
  var progressBarPercentage: Int?
  var color: String?
    
  required init?(map: Map) {
    super.init()
  }
    
  func mapping(map: Map) {
    tileType <- map["tile_type"]
    title <- map["title"]
    subtitle <- map["subtitle"]
    value <- map["value"]
    showPercentageSign <- map["show_percentage_sign"]
    showProgressBar <- map["show_progress_bar"]
    progressBarPercentage <- map["progress_bar_percentage"]
    color <- map["color"]
   }
}

class SurveyCategory: NSObject, Mappable {
    var title: String!
    var introText: String?
    var titlePt: String?
    var introTextPt: String?
  var imageURLString: String!
  var source: String!
  var ref: String!
  var categoryID: String!
  var order: Int!
  var isCompleted: Bool = false
  var color: String?
  
  var imageURL: URL? {
    if let urlString = imageURLString {
      return URL(string: urlString)
    }
    return nil
  }

  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    title <- map["label.en"]
    titlePt <- map["label.pt"]
    introText <- map["intro_text.en"]
    introTextPt <- map["intro_text.pt"]
    imageURLString <- map["preferred_icon.white_png_120px"]
    source <- map["source"]
    ref <- map["ref"]
    categoryID <- map["uid"]
    order <- map["order"]
    isCompleted <- map["completed"]
    color <- map["color"]
  }
}

class SurveyCategoryHolder: NSObject {
  var items: [SurveyCategory] = []
  
  init(items: [SurveyCategory]) {
    self.items = items
    super.init()
  }
}
