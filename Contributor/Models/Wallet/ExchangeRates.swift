//
//  ExchangeRates.swift
//  Contributor
//
//  Created by arvindh on 04/09/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

enum Currency: String, CodingKey {
  case GBP, USD, INR, AUD, EUR, CAD, BRL
  
    static var array: [Currency] = [.GBP, .USD, .INR, .AUD, .EUR, .CAD, .BRL]
  
  var symbol: String {
    switch self {
    case .GBP: return "£"
    case .USD, .CAD, .AUD: return "$"
    case .INR: return "₹"
    case .EUR: return "€"
    case .BRL: return "R$"
    }
  }
}

struct CountryInfo {
  var code: String
  var currency: String
}

let CountryCodeLookup: [String: String] = [
  "0c43ea783b1b50bd7e2fe2f279ba4fc6": "US",
  "530b106ba55dcde688507d37059c3d90": "GB",
  "e7932c585ea48d396e42d692de780b06": "AU",
  "c65ddc97a21d4018dbef569f1366aa5f": "CA",
  "057f95e2b7a946db9c9556588effa61c": "BR"
]

let CurrencyLookup: [String: Currency] = [
  "0c43ea783b1b50bd7e2fe2f279ba4fc6": .USD,
  "530b106ba55dcde688507d37059c3d90": .GBP,
  "e7932c585ea48d396e42d692de780b06": .AUD,
  "c65ddc97a21d4018dbef569f1366aa5f": .CAD,
   "057f95e2b7a946db9c9556588effa61c": .BRL

]

struct ExchangeRates: Codable, DefaultsSerializable {
  fileprivate var values: [Currency: Double] = [:]
  subscript(currency: Currency) -> Decimal? {
    if let value = values[currency] {
      return Decimal(value)
    }
    
    return nil
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Currency.self)
    for currency in Currency.array {
      let value = try container.decodeIfPresent(Double.self, forKey: currency)
      values[currency] = value
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Currency.self)
    for (currency, value) in self.values {
      try container.encode(value, forKey: currency)
    }
  }
}
