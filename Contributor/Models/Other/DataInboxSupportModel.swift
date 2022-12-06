//
//  DataInboxSupportModel.swift
//  Contributor
//
//  Created by KiwiTech on 5/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import DynamicCodable

struct DataInboxSupport: Codable {
  var dataInboxId: Int?
  var user: Int?
  var status: Int?
  var source: String?
  var package: [String: Any]?
  var added: String?
  enum CodingKeys: String, CodingKey {
    case dataInboxId = "id"
    case user
    case status
    case source
    case package = "data"
    case added
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    dataInboxId = try container.decode(Int.self, forKey: .dataInboxId)
    user = try container.decode(Int.self, forKey: .user)
    status = try container.decode(Int.self, forKey: .status)
    package = try container.decodeIfPresent([String: Any].self, forKey: .package)
    added = try container.decode(String.self, forKey: .added)
  }
    
  func encode(to encoder: Encoder) throws {
     var container = encoder.container(keyedBy: CodingKeys.self)
     try container.encode(dataInboxId, forKey: .dataInboxId)
     try container.encode(user, forKey: .user)
     try container.encode(status, forKey: .status)
     try container.encodeIfPresent(package, forKey: .package)
     try container.encode(added, forKey: .added)
   }
}

struct DeletePackageModel: Codable {
    var message: String?
    var processedOn: String?
    private enum CodingKeys: String, CodingKey {
        case message
        case processedOn = "processed_on"
    }
}
