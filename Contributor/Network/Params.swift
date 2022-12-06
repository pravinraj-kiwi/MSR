//
//  Params.swift
//  Contributor
//
//  Created by arvindh on 31/07/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
protocol Parameterizable {
  func asParams() -> [String: Any]
}

extension Parameterizable where Self: Encodable {
  func asParams() -> [String: Any] {
    do {
      let jsonEncoder = JSONEncoder()
      let data = try jsonEncoder.encode(self)
      let json = try JSONSerialization.jsonObject(with: data, options: [])
      return json as? [String: Any] ?? [:]
    } catch {
      return [:]
    }
  }
}

struct AuthParams: Parameterizable, Encodable, Equatable {
  private enum CodingKeys: String, CodingKey {
    case email, password
  }
  var email: String
  var password: String
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(email, forKey: .email)
    try container.encode(password, forKey: .password)
  }
}

func ==(_ lhs: AuthParams, _ rhs: AuthParams) -> Bool {
  return (lhs.email == rhs.email) && (lhs.password == rhs.password)
}

struct SignupParams: Parameterizable, Encodable {
  private enum CodingKeys: String, CodingKey {
    case email, password, timezone
    case firstName = "first_name"
    case lastName = "last_name"
    case communitySlug = "community_slug"
    case communityUserID = "community_user_id"
    case joinURLString = "join_url"
    case inviteCode = "invited_by_code"
    case hasAcceptedTerms = "has_accepted_terms"
  }
  var firstName: String
  var lastName: String
  var email: String
  var password: String
  var timezone: String
  var inviteCode: String?
  var communitySlug: String?
  var communityUserID: String?
  var joinURLString: String?
  var hasAcceptedTerms: Bool = false
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(firstName, forKey: .firstName)
    try container.encode(lastName, forKey: .lastName)
    try container.encode(email, forKey: .email)
    try container.encode(password, forKey: .password)
    try container.encode(timezone, forKey: .timezone)
    try container.encodeIfPresent(inviteCode, forKey: .inviteCode)
    try container.encodeIfPresent(communitySlug, forKey: .communitySlug)
    try container.encodeIfPresent(communityUserID, forKey: .communityUserID)
    try container.encodeIfPresent(joinURLString, forKey: .joinURLString)
    try container.encodeIfPresent(hasAcceptedTerms, forKey: .hasAcceptedTerms)
  }
}

struct VerifyOtpParams: Parameterizable, Encodable {
    private enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
        case otp = "validation_code"
    }
    var phoneNumber: String
    var otp: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(phoneNumber, forKey: CodingKeys.phoneNumber)
        try container.encodeIfPresent(otp, forKey: CodingKeys.otp)
    }
}
    
struct JoinCommunityParams: Parameterizable, Encodable {
  private enum CodingKeys: String, CodingKey {
    case communitySlug = "community_slug"
    case communityUserID = "community_user_id"
    case joinURLString = "join_url"
  }
  var communitySlug: String
  var communityUserID: String?
  var joinURLString: String?
    
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(communitySlug, forKey: CodingKeys.communitySlug)
    try container.encodeIfPresent(communityUserID, forKey: .communityUserID)
    try container.encodeIfPresent(joinURLString, forKey: .joinURLString)
  }
}

struct MediaParam: Parameterizable, Encodable {
 private enum CodingKeys: String, CodingKey {
   case videoFileName = "filename"
   case mediaType = "media_type"
   case uploadStatus = "upload_status"
 }
 var videoFileName: String
 var mediaType: String
 var uploadStatus: String

 func encode(to encoder: Encoder) throws {
   var container = encoder.container(keyedBy: CodingKeys.self)
   try container.encode(videoFileName, forKey: CodingKeys.videoFileName)
   try container.encodeIfPresent(mediaType, forKey: .mediaType)
   try container.encodeIfPresent(uploadStatus, forKey: .uploadStatus)
 }
}

struct GenericRewardRedemptionParams: Parameterizable, Encodable {
  private enum CodingKeys: String, CodingKey {
    case redemptionType = "redemption_type"
  }
  
  var redemptionType: String!
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(redemptionType, forKey: .redemptionType)
  }
}

struct PhoneNumberParams: Parameterizable, Encodable {
  private enum CodingKeys: String, CodingKey {
    case phoneNumber = "phone_number"
  }
  
  var phoneNumber: String
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(phoneNumber, forKey: CodingKeys.phoneNumber)
  }
}

struct LinkedinConnectParams: Parameterizable, Encodable {
  private enum CodingKeys: String, CodingKey {
    case linkedinId = "linkedin_id"
  }
  
  var linkedinId: String
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(linkedinId, forKey: CodingKeys.linkedinId)
  }
}

struct FacebookConnectParams: Parameterizable, Encodable {
  private enum CodingKeys: String, CodingKey {
    case facebookId = "facebook_id"
  }
  
  var facebookId: String
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(facebookId, forKey: CodingKeys.facebookId)
  }
}
