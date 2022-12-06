//
//  GiftCardRemptionOption.swift
//  Contributor
//
//  Created by arvindh on 16/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//


import Foundation
import ObjectMapper

class GiftCardRedemptionOption: NSObject, Mappable {
  var redemptionType: String = "default"
  var localFiatValue: Int = 0
  var decimalValue: Decimal {
    return Decimal(integerLiteral: localFiatValue)
  }
  
  var msrValue: Int = 0
  var enabled: Bool = false
  var formattedFiatValue: String {
    let currency = UserManager.shared.user?.currency ?? .USD
    return "\(currency.symbol)\(localFiatValue)"
  }
  
  var formattedMSRValue: String {
    return "\(msrValue) MSR"
  }
  
  required override init() {
    super.init()
  }
  
  required init(map: Map) {
    super.init()
  }

  func mapping(map: Map) {
    redemptionType <- map["redemption_type"]
    localFiatValue <- map["lcy_amount"]
    msrValue <- map["msr_amount"]
    enabled <- map["enabled"]
  }
}

class GiftCardRedemptionResponse: NSObject, Mappable {
  var giftID: String!
  var status: String!
  var redeemURLString: String!
  var amount: Decimal!
  var currencyCode: String!
  
  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    giftID <- map["gift_id"]
    status <- map["status"]
    redeemURLString <- map["redeem_url"]
    amount <- (map["amount"], DoubleDecimalTransform())
    currencyCode <- map["currency_code"]
  }
}

class GenericRewardRedemptionResponse: NSObject, Mappable {
  var title: String!
  var message: String!
  
  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    title <- map["title"]
    message <- map["message"]
  }
}
