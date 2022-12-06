//
//  LinkedinValidationModel.swift
//  Contributor
//
//  Created by KiwiTech on 3/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import ObjectMapper

struct ConnectedAppData: Codable {
    var id: Int?
    var userId: Int?
    var type: String?
    var setUpStatus: String?
    var group: String?
    var setUpRunningStatus: String?
    var adClicked: Bool?
    var displayAd: Bool?
    var details: ItemDetail?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user"
        case type
        case group
        case setUpStatus = "setup_status"
        case setUpRunningStatus = "running_status"
        case adClicked = "ad_clicked"
        case displayAd = "display_ad"
        case details
    }
}

struct ItemDetail: Codable {
   var profileItems: [ProfileItems]?
  
  private enum CodingKeys: String, CodingKey {
      case profileItems = "profile_items"
  }
}

struct ProfileItems: Codable {
   var label: LabelType?
   var ref: String?
   private enum CodingKeys: String, CodingKey {
       case label
       case ref
   }
}

struct LabelType: Codable {
   var en: String?
  private enum CodingKeys: String, CodingKey {
      case en
  }
}

struct LinkedinAccount: Codable {
    var linkedinId: String?
    var vanityName: String?
    
    private enum CodingKeys: String, CodingKey {
        case linkedinId = "id"
        case vanityName
    }
}

class DynataJobDetail: NSObject, Mappable {
 var earnedMsr: Int?
 var pendingMsr: Int?
 var jobs: [WalletTransaction]?

 required init?(map: Map) {
  super.init()
 }

 func mapping(map: Map) {
    earnedMsr <- map["earned_msr"]
    pendingMsr <- map["pending_msr"]
    jobs <- map["jobs"]
 }
}

struct Jobs: Codable {
   var title: String?
   var status: Int?
   var paidEarningsMsr: Int?
   var date: String?
    
    private enum CodingKeys: String, CodingKey {
        case title
        case paidEarningsMsr = "paid_earnings_msr"
        case status
        case date
    }
}
