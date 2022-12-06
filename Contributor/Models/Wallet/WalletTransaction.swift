//
//  WalletTransaction.swift
//  Contributor
//
//  Created by arvindh on 29/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import ObjectMapper

enum TransactionDetailType: String {
  case transDetail = "txn_details"
  case giftTransDetail = "gift_details"
  case referalBonusTrans = "referral_bonus_details"
}

class WalletTransaction: NSObject, Mappable {
  var transactionID: Int?
  var type: TransactionDetailType?
  var title: String?
  var guid: String?
  var titleStyle: String?
  var descriptionStyle: String?
  var transactionDescription: String?
  var transactionType: Int?
  var amountMSR: Int?
  var transactionDetail: Bool = false
  var date: String?
  var updatedDate: String?
  var shouldShowTopCorners: Bool = false
  var shouldShowBottomCorners: Bool = false
  var amountMSRString: String {
    if let amount = amountMSR {
        return "\(amount.stringWithCommas) MSR"
    }
    return "0"
  }
  
  required init?(map: Map) {
    super.init()
  }

 private func parseDate(_ str: String) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US_POSIX")
    dateFormat.dateFormat = DateFormatType.serverDateFormat.rawValue
    if let date = dateFormat.date(from: str) {
        let newFormat = DateFormatter()
        newFormat.dateFormat = DateFormatType.shortDateFormat.rawValue
        newFormat.timeZone = TimeZone(abbreviation: "UTC")
        return newFormat.string(from: date)
    }
    return ""
  }
    
  func mapping(map: Map) {
    transactionID <- map["id"]
    type <- map["type"]
    title <- map["title"]
    titleStyle <- map["title_style"]
    descriptionStyle <- map["description_style"]
    guid <- map["guid"]
    transactionDetail <- map["details_available"]
    transactionType <- map["transaction_type"]
    amountMSR <- map["amount_msr"]
    transactionDescription <- map["description"]
    date <- map["transaction_date"]
    if let transDate = date {
      updatedDate = parseDate(transDate)
    }
  }
}

class WalletTransactionsHolder: NSObject {
  var transactions: [WalletTransaction] = []
  
  init(transactions: [WalletTransaction]) {
    self.transactions = transactions
    super.init()
  }
}
