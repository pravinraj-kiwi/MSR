//
//  Transformers.swift
//  Contributor
//
//  Created by arvindh on 17/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import ObjectMapper

class StringDecimalTransform: TransformType {
    
  func transformFromJSON(_ value: Any?) -> Decimal? {
    guard let value = value as? String else {
      return nil
    }
    return Decimal(string: value)
  }
  
  func transformToJSON(_ value: Decimal?) -> Double? {
    guard let value = value else {
      return nil
    }
    return NSDecimalNumber(decimal: value).doubleValue
  }
}

class DoubleDecimalTransform: TransformType {
  func transformFromJSON(_ value: Any?) -> Decimal? {
    guard let value = value as? Double else {
      return nil
    }
    return Decimal(floatLiteral: value)
  }
  
  func transformToJSON(_ value: Decimal?) -> Double? {
    guard let value = value else {
      return nil
    }
    return NSDecimalNumber(decimal: value).doubleValue
  }
}

open class ISO8601WithMillisecondsDateTransform: DateFormatterTransform {
    static let isoDateFormat = DateFormatType.isoDateFormat.rawValue
    static let reusableISODateFormatter = DateFormatter(withFormat: isoDateFormat,
                                                        locale: "en_US_POSIX")

  public init() {    
    super.init(dateFormatter: ISO8601WithMillisecondsDateTransform.reusableISODateFormatter)
  }
}
