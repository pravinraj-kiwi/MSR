//
//  Balance.swift
//  Contributor
//
//  Created by John Martin on 8/12/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

final class Balance: NSObject, Codable, DefaultsSerializable  {
  enum CodingKeys: String, CodingKey {
    case balanceType = "type"
    case walletTitle = "wallet_title"
    case walletDescription = "wallet_description"
    case balanceMSR = "balance_msr"
    case redemptionCurrencyAmount = "redemption_currency_amount"
    case redemptionCurrency = "redemption_currency"
    case showDefaultRedemptionCatalog = "show_redemption_catalog"
    case redeemDenominations = "redeem_denominations"
    case redeemFullBalance = "redeem_full_balance"
  }
  
  var balanceType: String
  var walletTitle: String
  var walletDescription: String
  var balanceMSR: Int
  var redemptionCurrencyAmount: Decimal?
  var redemptionCurrency: String?
  var showDefaultRedemptionCatalog: Bool
  var redeemDenominations: Bool
  var redeemFullBalance: Bool
  
    var isDefaultBalance: Bool {
        return balanceType == "default"
    }
    var paymentType: PaymentType {
        if balanceType == PaymentType.giftCard.rawValue{
            return .giftCard
        }
        if balanceType == PaymentType.paypal.rawValue {
            return .paypal
        }
        return .giftCard
    }
  var redemptionCurrencyAmountString: String {
    if let redemptionCurrencyAmount = self.redemptionCurrencyAmount {
      let decimalFormatter = NumberFormatter()
      decimalFormatter.numberStyle = .decimal
      if isDefaultBalance {
        decimalFormatter.maximumFractionDigits = 2
        decimalFormatter.minimumFractionDigits = 2
      } else {
        decimalFormatter.maximumFractionDigits = 0
        decimalFormatter.minimumFractionDigits = 0
      }
      return decimalFormatter.string(from: redemptionCurrencyAmount as NSDecimalNumber) ?? "0.00"
    }
    
    return "0.00"
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(balanceType, forKey: .balanceType)
    try container.encode(walletTitle, forKey: .walletTitle)
    try container.encode(walletDescription, forKey: .walletDescription)
    try container.encode(balanceMSR, forKey: .balanceMSR)
    try container.encode(redemptionCurrencyAmount, forKey: .redemptionCurrencyAmount)
    try container.encode(redemptionCurrency, forKey: .redemptionCurrency)
    try container.encode(showDefaultRedemptionCatalog, forKey: .showDefaultRedemptionCatalog)
    try container.encode(redeemDenominations, forKey: .redeemDenominations)
    try container.encode(redeemFullBalance, forKey: .redeemFullBalance)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.balanceType = try container.decode(String.self, forKey: .balanceType)
    self.walletTitle = try container.decode(String.self, forKey: .walletTitle)
    self.walletDescription = try container.decode(String.self, forKey: .walletDescription)
    self.balanceMSR = try container.decode(Int.self, forKey: .balanceMSR)
    self.redemptionCurrencyAmount = try container.decodeIfPresent(Decimal.self, forKey: .redemptionCurrencyAmount)
    self.redemptionCurrency = try container.decodeIfPresent(String.self, forKey: .redemptionCurrency)
    self.showDefaultRedemptionCatalog = try container.decodeIfPresent(Bool.self, forKey: .showDefaultRedemptionCatalog) ?? false
    self.redeemDenominations = try container.decodeIfPresent(Bool.self, forKey: .redeemDenominations) ?? false
    self.redeemFullBalance = try container.decodeIfPresent(Bool.self, forKey: .redeemFullBalance) ?? false
  }
}

class BalancesHolder: NSObject {
  var balances: [Balance] = []
  
  init(balances: [Balance]) {
    self.balances = balances
    super.init()
  }
}
