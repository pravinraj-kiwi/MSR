//
//  MSRConverter.swift
//  Contributor
//
//  Created by John Martin on 2/19/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class MSRConverter: NSObject {
  static func convertTo(_ msr: Int, currency: Currency) -> Decimal {
    let exchangeRates = Defaults[.exchangeRates]
    guard let exchangeRate = exchangeRates?[currency] else {
      return 0.00
    }
    return Decimal(msr) * exchangeRate / 100
  }
}
