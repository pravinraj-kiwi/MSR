//
//  ProfileBackupStatus.swift
//  Contributor
//
//  Created by arvindh on 18/04/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

final class ProfileBackupStatus: NSObject, Codable, DefaultsSerializable {
  enum CodingKeys: String, CodingKey {
    case fetchDate, changeTag, modifiedAt
  }
  
  var fetchDate: Date?
  var modifiedAt: Date?
  var changeTag: String?
  
  override init() {
    super.init()
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(fetchDate, forKey: .fetchDate)
    try container.encodeIfPresent(changeTag, forKey: .changeTag)
    try container.encodeIfPresent(modifiedAt, forKey: .modifiedAt)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.fetchDate = try container.decodeIfPresent(Date.self, forKey: .fetchDate)
    self.modifiedAt = try container.decodeIfPresent(Date.self, forKey: .modifiedAt)
    self.changeTag = try container.decodeIfPresent(String.self, forKey: .changeTag)
    
  }
}
