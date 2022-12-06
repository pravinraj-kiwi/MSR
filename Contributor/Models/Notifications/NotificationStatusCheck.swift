//
//  NotificationStatusCheck.swift
//  Contributor
//
//  Created by arvindh on 14/03/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

final class NotificationStatusCheck: NSObject, Codable, DefaultsSerializable, Parameterizable {
  enum CodingKeys: String, CodingKey {
    case date, type, status
  }
  
  var date: Date
  var status: Int
  
  init(date: Date, status: Int) {
    self.date = date
    self.status = status
    super.init()
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(date, forKey: .date)
    try container.encode(status, forKey: .status)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.date = try container.decode(Date.self, forKey: .date)
    self.status = try container.decode(Int.self, forKey: .status)
  }
}
