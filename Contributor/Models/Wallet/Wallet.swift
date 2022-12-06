//
//  Wallet.swift
//  Contributor
//
//  Created by arvindh on 17/09/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class Wallet: NSObject {
  var user: User
  
  init(user: User) {
    self.user = user
    super.init()
  }
  
  var currency: Currency {
    return user.currency ?? .USD
  }
  
  var balanceMSR: Int {
    return user.balanceMSR
  }
  
  var balanceFiat: Decimal? {
    let exchangeRates = Defaults[.exchangeRates]
    guard let exchangeRate = exchangeRates?[currency] else {
      return nil
    }
    
    return Decimal(balanceMSR) * exchangeRate / 100
  }
  
  var balanceMSRString: String {
    return "\(balanceMSR.stringWithCommas) MSR"
  }
  
  var balanceFiatString: String {
    if let balanceFiat = self.balanceFiat {      
      let decimalFormatter = NumberFormatter()
      decimalFormatter.numberStyle = .decimal
      decimalFormatter.maximumFractionDigits = 2
      decimalFormatter.minimumFractionDigits = 2
      
      let currency = UserManager.shared.user?.currency ?? .USD
      let suffix = decimalFormatter.string(from: balanceFiat as NSDecimalNumber) ?? "0.00"
      return "\(currency.symbol)\(suffix) \(currency.stringValue)"
    }
    
    return "0.00"
  }
  
  var hasMultipleBalances: Bool {
    return user.balances.count > 1
  }
}
