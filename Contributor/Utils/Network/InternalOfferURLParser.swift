//
//  InternalOfferURLParser.swift
//  Contributor
//
//  Created by arvindh on 02/02/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import URLNavigator
import ObjectMapper

class InternalOfferURLParser: NSObject {
  static let categoryPattern = "measuresurvey://category/<category>/<ref>"
  static let embeddedPattern = "measuresurvey://embedded"
  
  static let patterns = [
    categoryPattern,
    embeddedPattern
  ]
  
  static func parse(offerItem: OfferItem) -> SurveyType? {
    let matcher = URLMatcher()
    
    guard let url = offerItem.url else {
      return nil
    }
    
    if let result = matcher.match(url, from: patterns) {
      switch result.pattern {
      case categoryPattern:
        if let params = Mapper<CategoryOfferURLParams>().map(JSON: result.values) {
          return SurveyType.categoryOffer(offerItem: offerItem, params: params)
        }
      case embeddedPattern:
        if let params = Mapper<EmbeddedOfferURLParams>().map(JSON: result.values) {
          return SurveyType.embeddedOffer(offerItem: offerItem, params: params)
        }
      default:
        break
      }
    }
    return nil
  }
}
