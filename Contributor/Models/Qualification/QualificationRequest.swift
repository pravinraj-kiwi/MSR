//
//  QualificationRequest.swift
//  Contributor
//
//  Created by John Martin on 3/2/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import ObjectMapper
import SwiftyJSON

class QualificationRequest: NSObject, Mappable {
  enum POPVersion: String {
    case version1 = "1"
    case version2 = "2"
  }
  
  var sampleRequestIDString: String!
  var targetingString: String!
  var quotaItems: [String]?
  var callbackURLString: String!
  var popVersion: POPVersion = .version1

  required init?(map: Map) {
    super.init()
  }

  var sampleRequestID: Int? {
    if let sampleRequestID = Int(sampleRequestIDString) {
      return sampleRequestID
    }
    return nil
  }
  
  var callbackURL: URL? {
    if let urlString = callbackURLString {
      return URL(string: urlString)
    }
    return nil
  }

  var targeting: JSON? {
    if let dataFromString = targetingString.data(using: .utf8, allowLossyConversion: false) {
      if let targeting = try? JSON(data: dataFromString) {
        return targeting
      }
    }
    return nil
  }

  func mapping(map: Map) {
    sampleRequestIDString <- map["sample_request_id"]
    targetingString <- map["targeting"]
    callbackURLString <- map["callback_url"]
    popVersion <- map["pop_version"]

    // special handling for quota items to support [String] or a string of JSON
    var quotaItemsData: Any?
    quotaItemsData <- map["quota_items"]
    if let quotaItemsString = quotaItemsData as? String {
      if let dataFromString = quotaItemsString.data(using: .utf8, allowLossyConversion: false) {
        if let parsedQuotaItems = try? JSON(data: dataFromString) {
          var items: [String] = []
          for (_, ref) in parsedQuotaItems {
            items.append(ref.stringValue)
          }
          quotaItems = items
        }
      }
    } else if let items = quotaItemsData as? [String] {
      quotaItems = items
    }
  }
}
