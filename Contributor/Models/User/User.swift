//
//  User.swift
//  Contributor
//
//  Created by arvindh on 25/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import KeychainSwift
import SwiftyUserDefaults

final class User: NSObject, Codable, DefaultsSerializable {
  enum CodingKeys: String, CodingKey {
    case firstName = "first_name"
    case lastName = "last_name"
    case email
    case userID = "id"
    case balanceMSR = "balance_msr"
    case inviteCode = "invite_code"
    case currency
    case country
    case timezone
    case accessToken = "access"
    case refreshToken = "refresh"
    case isCollectingLocation = "is_collecting_location"
    case isCollectingHealth = "is_collecting_health"
    case isCollectingAmazon = "is_collecting_amazon"
    case isCollectingSpotify = "is_collecting_spotify"
    case hasFilledBasicDemos = "has_filled_basic_demos"
    case referFriendEnabled = "refer_a_friend_enabled"
    case hasDecidedNotifications = "has_decided_notifications"
    case hasValidatedEmail = "has_validated_email"
    case hasValidatedPhoneNumber = "has_validated_phone_number"
    case hasValidatedLocation = "has_validated_location"
    case filledBasicDemosError = "filled_basic_demos_error"
    case emailValidationError = "email_validation_error"
    case locationValidationError = "location_validation_error"
    case phoneValidationError = "phone_number_validation_error"
    case isReceivingNotifications = "is_receiving_notifications"
    case isAcceptingOffers = "is_accepting_offers"
    case isFraudSuspect = "is_fraud_suspect"
    case isTestUser = "is_test_user"
    case selectedCommunitySlug = "selected_community_slug"
    case communities
    case balances
    case successfulInvitations = "successful_invites"
    case invitationLimit = "invite_user_limit"
    case invitationRewardMSR = "invite_reward_msr"
    case validationRewardMSR = "validation_reward_msr"
    case onboardTemplate = "onboard_template"
  }
  
  var email: String = ""
  var firstName: String?
  var lastName: String?
  var userID: Int!
  var balanceMSR: Int!
  var currency: Currency?
  var accessToken: String?
  var refreshToken: String?
  var inviteCode: String?
  var country: String?
  var timezone: String?
  var isCollectingLocation: Bool = false
  var isCollectingHealth: Bool = false
  var isCollectingAmazon: Bool = false
  var isCollectingSpotify: Bool = false
  var hasFilledBasicDemos: Bool = false
  var hasDecidedNotifications: Bool = false
  var hasValidatedEmail: Bool = false
  var hasValidatedPhoneNumber: Bool = false
  var hasValidatedLocation: Bool = false
  var referFriendEnabled: Bool = false
  var filledBasicDemosError: String?
  var emailValidationError: String?
  var locationValidationError: String?
  var phoneValidationError: String?
  var isReceivingNotifications: Bool = false
  var isAcceptingOffers: Bool = false
  var isFraudSuspect: Bool = false
  var isTestUser: Bool = false
  var selectedCommunitySlug: String!
  var communities: [Community] = []
  var balances: [Balance] = []
  var successfulInvitations: Int = 0
  var invitationLimit: Int = 0
  var invitationRewardMSR: Int = 0
  var validationRewardMSR: Int = 0
    var onboardTemplate: String?

  var fullName: String {
    var name: String = ""
    
    if let firstName = self.firstName {
      name.append(firstName + " ")
    }
    
    if let lastName = self.lastName {
      name.append(lastName)
    }
    
    return name
  }
  
  var hasFilledBasicDemosError: Bool {
    if let _ = filledBasicDemosError {
      return true
    } else {
      return false
    }
  }

  var hasLocationValidationError: Bool {
    if let _ = locationValidationError {
      return true
    } else {
      return false
    }
  }

  var hasPhoneValidationError: Bool {
    if let _ = phoneValidationError {
      return true
    } else {
      return false
    }
  }

  var hasEmailValidationError: Bool {
    if let _ = emailValidationError {
      return true
    } else {
      return false
    }
  }
  
  func getCommunityForSlug(slug: String) -> Community? {
    return communities.first { $0.slug == slug }
  }
  
  var selectedCommunity: Community? {
    if selectedCommunitySlug == nil {
        return nil
    }
    return getCommunityForSlug(slug: selectedCommunitySlug)
  }
  
  func getBalance(forType balanceType: String) -> Balance? {
    return balances.first { $0.balanceType == balanceType }
  }
  
  var remainingInvitations: Int {
    return invitationLimit - successfulInvitations
  }
  
  var userIDForAnalytics: String {
    if let userID = userID {
      return "\(userID)"
    }
    return ""
  }

  override init() {
    super.init()
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
    self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
    self.email = try container.decode(String.self, forKey: .email)
    self.userID = try container.decodeIfPresent(Int.self, forKey: .userID)
    self.balanceMSR = try container.decode(Int.self, forKey: .balanceMSR)
    self.inviteCode = try container.decodeIfPresent(String.self, forKey: .inviteCode)
    if let currencyString = try container.decodeIfPresent(String.self, forKey: .currency) {
      self.currency = Currency(rawValue: currencyString)
    }
    self.accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
    self.refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
    self.country = try container.decodeIfPresent(String.self, forKey: .country)
    self.timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
    self.isCollectingLocation = try container.decodeIfPresent(Bool.self, forKey: .isCollectingLocation) ?? false
    self.isCollectingHealth = try container.decodeIfPresent(Bool.self, forKey: .isCollectingHealth) ?? false
    self.isCollectingAmazon = try container.decodeIfPresent(Bool.self, forKey: .isCollectingAmazon) ?? false
    self.isCollectingSpotify = try container.decodeIfPresent(Bool.self, forKey: .isCollectingSpotify) ?? false
    self.hasFilledBasicDemos = try container.decodeIfPresent(Bool.self, forKey: .hasFilledBasicDemos) ?? false
    self.hasDecidedNotifications = try container.decodeIfPresent(Bool.self, forKey: .hasDecidedNotifications) ?? false
    self.hasValidatedEmail = try container.decodeIfPresent(Bool.self, forKey: .hasValidatedEmail) ?? false
    self.hasValidatedPhoneNumber = try container.decodeIfPresent(Bool.self, forKey: .hasValidatedPhoneNumber) ?? false
    self.referFriendEnabled = try container.decodeIfPresent(Bool.self, forKey: .referFriendEnabled) ?? false
    self.hasValidatedLocation = try container.decodeIfPresent(Bool.self, forKey: .hasValidatedLocation) ?? false
    self.filledBasicDemosError = try container.decodeIfPresent(String.self, forKey: .filledBasicDemosError)
    self.locationValidationError = try container.decodeIfPresent(String.self, forKey: .locationValidationError)
    self.phoneValidationError = try container.decodeIfPresent(String.self, forKey: .phoneValidationError)
    self.emailValidationError = try container.decodeIfPresent(String.self, forKey: .emailValidationError)
    self.isReceivingNotifications = try container.decodeIfPresent(Bool.self, forKey: .isReceivingNotifications) ?? false
    self.isAcceptingOffers = try container.decodeIfPresent(Bool.self, forKey: .isAcceptingOffers) ?? false
    self.isFraudSuspect = try container.decodeIfPresent(Bool.self, forKey: .isFraudSuspect) ?? false
    self.isTestUser = try container.decodeIfPresent(Bool.self, forKey: .isTestUser) ?? true
    self.selectedCommunitySlug = try container.decodeIfPresent(String.self, forKey: .selectedCommunitySlug)
    self.communities = try container.decodeIfPresent([Community].self, forKey: .communities) ?? []
    self.balances = try container.decodeIfPresent([Balance].self, forKey: .balances) ?? []
    self.successfulInvitations = try container.decodeIfPresent(Int.self, forKey: .successfulInvitations) ?? 0
    self.invitationLimit = try container.decodeIfPresent(Int.self, forKey: .invitationLimit) ?? 0
    self.invitationRewardMSR = try container.decodeIfPresent(Int.self, forKey: .invitationRewardMSR) ?? 0
    self.validationRewardMSR = try container.decodeIfPresent(Int.self, forKey: .validationRewardMSR) ?? Constants.defaultValidationRewardMSR
      self.onboardTemplate = try container.decodeIfPresent(String.self, forKey: .onboardTemplate) ?? ""

  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(userID, forKey: .userID)
    try container.encodeIfPresent(firstName, forKey: .firstName)
    try container.encodeIfPresent(lastName, forKey: .lastName)
    try container.encode(email, forKey: .email)
    try container.encode(balanceMSR, forKey: .balanceMSR)
    try container.encode(currency?.rawValue, forKey: .currency)
    try container.encode(accessToken, forKey: .accessToken)
    try container.encode(refreshToken, forKey: .refreshToken)
    try container.encode(country, forKey: .country)
    try container.encode(inviteCode, forKey: .inviteCode)
    try container.encode(timezone, forKey: .timezone)
    try container.encode(isCollectingLocation, forKey: .isCollectingLocation)
    try container.encode(isCollectingHealth, forKey: .isCollectingHealth)
    try container.encode(isCollectingAmazon, forKey: .isCollectingAmazon)
    try container.encode(isCollectingSpotify, forKey: .isCollectingSpotify)
    try container.encode(hasFilledBasicDemos, forKey: .hasFilledBasicDemos)
    try container.encode(hasDecidedNotifications, forKey: .hasDecidedNotifications)
    try container.encode(referFriendEnabled, forKey: .referFriendEnabled)
    try container.encode(hasValidatedEmail, forKey: .hasValidatedEmail)
    try container.encode(hasValidatedPhoneNumber, forKey: .hasValidatedPhoneNumber)
    try container.encode(hasValidatedLocation, forKey: .hasValidatedLocation)
    try container.encode(filledBasicDemosError, forKey: .filledBasicDemosError)
    try container.encode(locationValidationError, forKey: .locationValidationError)
    try container.encode(phoneValidationError, forKey: .phoneValidationError)
    try container.encode(emailValidationError, forKey: .emailValidationError)
    try container.encode(isReceivingNotifications, forKey: .isReceivingNotifications)
    try container.encode(isAcceptingOffers, forKey: .isAcceptingOffers)
    try container.encode(isFraudSuspect, forKey: .isFraudSuspect)
    try container.encode(isTestUser, forKey: .isTestUser)
    try container.encode(selectedCommunitySlug, forKey: .selectedCommunitySlug)
    try container.encode(communities, forKey: .communities)
    try container.encode(balances, forKey: .balances)
    try container.encode(successfulInvitations, forKey: .successfulInvitations)
    try container.encode(invitationLimit, forKey: .invitationLimit)
    try container.encode(invitationRewardMSR, forKey: .invitationRewardMSR)
    try container.encode(validationRewardMSR, forKey: .invitationRewardMSR)
      try container.encode(onboardTemplate, forKey: .onboardTemplate)

  }
  
  override func copy() -> Any {
    let data = try! JSONEncoder().encode(self)
    let newUser = try! JSONDecoder().decode(User.self, from: data)
    return newUser
  }
}

extension User: Parameterizable {}
