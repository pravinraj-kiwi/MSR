//
//  Community.swift
//  Contributor
//
//  Created by arvindh on 31/05/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import UIColor_Hex_Swift

final class Community: NSObject, Codable, DefaultsSerializable  {
  enum CodingKeys: String, CodingKey {
    case communityID = "community_id"
    case name
    case slug
    case communityUserID = "community_user_id"
    case colors = "color_properties"
    case images = "image_properties"
    case text = "text_properties"
  }
  
  var communityID: Int!
  var name: String!
  var slug: String!
  var communityUserID: String?
  var colors: CommunityColor!
  var images: CommunityImage!
  var text: CommunityText!

  var imageURLs: [URL] {
    let allImageStrings: [String] = [images.logoDarkBackground, images.logo, images.onboardingImage1, images.onboardingImage2, images.onboardingImage3, images.onboardingImage4]
    let allImageURLStrings = allImageStrings.filter { $0.starts(with: "http") }
    return allImageURLStrings.map {
      (urlString) -> URL in
      return URL(string: urlString)!
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(communityID, forKey: .communityID)
    try container.encode(name, forKey: .name)
    try container.encode(slug, forKey: .slug)
    try container.encodeIfPresent(communityUserID, forKey: .communityUserID)
    try container.encode(colors, forKey: .colors)
    try container.encode(images, forKey: .images)
    try container.encode(text, forKey: .text)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.communityID = try container.decode(Int.self, forKey: .communityID)
    self.name = try container.decode(String.self, forKey: .name)
    self.slug = try container.decode(String.self, forKey: .slug)
    self.communityUserID = try container.decodeIfPresent(String.self, forKey: .name)
    self.colors = try container.decode(CommunityColor.self, forKey: .colors)
    self.images = try container.decode(CommunityImage.self, forKey: .images)
    self.text = try container.decode(CommunityText.self, forKey: .text)
  }
  
  final class CommunityColor: Codable, DefaultsSerializable {
    enum CodingKeys: String, CodingKey {
      case primary
      case background
      case text
      case lightBackground = "light_background"
      case accent
      case unselected
      case border
      case slightlyLightBorder = "slightly_light_border"
      case lightBorder = "light_border"
      case veryLightBorder = "very_light_border"
      case lightText = "light_text"
      case veryLightText = "very_light_text"
      case placeholderText = "placeholder_text"
      case whiteText = "white_text"
      case almostWhiteText = "almost_white_text"
      case navigationItemTint = "navigation_item_tint"
      case error
      case selectedItem = "selected_item"
      case pill
      case introScreenBackground = "intro_screen_background"
      case introScreenText = "intro_screen_text"
      case introScreenButton = "intro_screen_button"
      case introScreenButtonText  = "intro_screen_button_text"
    }
    
    var primary: UIColor!
    var background: UIColor!
    var text: UIColor!
    var lightBackground: UIColor!
    var accent: UIColor!
    var unselected: UIColor!
    var border: UIColor!
    var slightlyLightBorder: UIColor!
    var lightBorder: UIColor!
    var veryLightBorder: UIColor!
    var lightText: UIColor!
    var veryLightText: UIColor!
    var placeholderText: UIColor!
    var whiteText: UIColor!
    var almostWhiteText: UIColor!
    var navigationItemTint: UIColor!
    var error: UIColor!
    var selectedItem: UIColor!
    var pill: UIColor!
    var introScreenBackground: UIColor!
    var introScreenText: UIColor!
    var introScreenButton: UIColor!
    var introScreenButtonText: UIColor!

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      func encode(color: UIColor, forKey key: CodingKeys) throws {
        let colorString = color.hexString()
        try container.encode(colorString, forKey: key)
      }
      
      try encode(color: primary, forKey: .primary)
      try encode(color: background, forKey: .background)
      try encode(color: text, forKey: .text)
      try encode(color: lightBackground, forKey: .lightBackground)
      try encode(color: accent, forKey: .accent)
      try encode(color: unselected, forKey: .unselected)
      try encode(color: border, forKey: .border)
      try encode(color: slightlyLightBorder, forKey: .slightlyLightBorder)
      try encode(color: lightBorder, forKey: .lightBorder)
      try encode(color: veryLightBorder, forKey: .veryLightBorder)
      try encode(color: placeholderText, forKey: .placeholderText)
      try encode(color: whiteText, forKey: .whiteText)
      try encode(color: lightText, forKey: .lightText)
      try encode(color: veryLightText, forKey: .veryLightText)
      try encode(color: almostWhiteText, forKey: .almostWhiteText)
      try encode(color: navigationItemTint, forKey: .navigationItemTint)
      try encode(color: error, forKey: .error)
      try encode(color: selectedItem, forKey: .selectedItem)
      try encode(color: pill, forKey: .pill)
      try encode(color: introScreenBackground, forKey: .introScreenBackground)
      try encode(color: introScreenText, forKey: .introScreenText)
      try encode(color: introScreenButton, forKey: .introScreenButton)
      try encode(color: introScreenButtonText, forKey: .introScreenButtonText)
    }
    
    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      func decodeColorIfPresent(forKey key: CodingKeys) throws -> UIColor? {
        if let colorString = try container.decodeIfPresent(String.self, forKey: key) {
          return UIColor(colorString)
        }
        return nil
      }
      
      self.primary = try decodeColorIfPresent(forKey: .primary) ?? Color.primary.value
      self.background = try decodeColorIfPresent(forKey: .background) ?? Color.background.value
      self.text = try decodeColorIfPresent(forKey: .text) ?? Color.text.value
      self.lightBackground = try decodeColorIfPresent(forKey: .lightBackground) ?? Color.lightBackground.value
      self.accent = try decodeColorIfPresent(forKey: .accent) ?? Color.accent.value
      self.unselected = try decodeColorIfPresent(forKey: .unselected) ?? Color.unselected.value
      self.border = try decodeColorIfPresent(forKey: .border) ?? Color.border.value
      self.slightlyLightBorder = try decodeColorIfPresent(forKey: .slightlyLightBorder) ?? Color.slightlyLightBorder.value
      self.lightBorder = try decodeColorIfPresent(forKey: .lightBorder) ?? Color.lightBorder.value
      self.veryLightBorder = try decodeColorIfPresent(forKey: .veryLightBorder) ?? Color.veryLightBorder.value
      self.placeholderText = try decodeColorIfPresent(forKey: .placeholderText) ?? Color.placeholderText.value
      self.whiteText = try decodeColorIfPresent(forKey: .whiteText) ?? Color.whiteText.value
      self.lightText = try decodeColorIfPresent(forKey: .lightText) ?? Color.lightText.value
      self.veryLightText = try decodeColorIfPresent(forKey: .veryLightText) ?? Color.veryLightText.value
      self.almostWhiteText = try decodeColorIfPresent(forKey: .almostWhiteText) ?? Color.almostWhiteText.value
      self.navigationItemTint = try decodeColorIfPresent(forKey: .navigationItemTint) ?? Color.navigationItemTint.value
      self.error = try decodeColorIfPresent(forKey: .error) ?? Color.error.value
      self.selectedItem = try decodeColorIfPresent(forKey: .selectedItem) ?? Color.selectedItem.value
      self.pill = try decodeColorIfPresent(forKey: .pill) ?? Color.pill.value
      self.introScreenBackground = try decodeColorIfPresent(forKey: .introScreenBackground) ?? Color.introScreenBackground.value
      self.introScreenText = try decodeColorIfPresent(forKey: .introScreenText) ?? Color.introScreenText.value
      self.introScreenButton = try decodeColorIfPresent(forKey: .introScreenButton) ?? Color.introScreenButton.value
      self.introScreenButtonText = try decodeColorIfPresent(forKey: .introScreenButtonText) ?? Color.introScreenButtonText.value
    }
  }
  
  final class CommunityImage: Codable, DefaultsSerializable {
    enum CodingKeys: String, CodingKey {
      case logo
      case logoDarkBackground = "logo_dark_background"
      case logoIntroScreen = "logo_intro_screen"
      case onboardingImage1 = "onboarding_image_1"
      case onboardingImage2 = "onboarding_image_2"
      case onboardingImage3 = "onboarding_image_3"
      case onboardingImage4 = "onboarding_image_4"
      case welcomeCard = "welcome_card"
    }
    
    var logo: String!
    var logoDarkBackground: String!
    var logoIntroScreen: String!
    var onboardingImage1: String!
    var onboardingImage2: String!
    var onboardingImage3: String!
    var onboardingImage4: String!
    var welcomeCard: String!
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(logo, forKey: .logo)
      try container.encode(logoDarkBackground, forKey: .logoDarkBackground)
      try container.encode(logoIntroScreen, forKey: .logoIntroScreen)
      try container.encode(onboardingImage1, forKey: .onboardingImage1)
      try container.encode(onboardingImage2, forKey: .onboardingImage2)
      try container.encode(onboardingImage3, forKey: .onboardingImage3)
      try container.encode(onboardingImage4, forKey: .onboardingImage4)
      try container.encode(welcomeCard, forKey: .welcomeCard)
    }
    
    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      self.logo = try container.decodeIfPresent(String.self, forKey: .logo) ?? Image.logoPurple.rawValue
      self.logoDarkBackground = try container.decodeIfPresent(String.self, forKey: .logoDarkBackground) ?? Image.logo.rawValue
      self.logoIntroScreen = try container.decodeIfPresent(String.self, forKey: .logoIntroScreen) ?? Image.logo.rawValue
      self.onboardingImage1 = try container.decodeIfPresent(String.self, forKey: .onboardingImage1) ?? Image.onboarding1.rawValue
      self.onboardingImage2 = try container.decodeIfPresent(String.self, forKey: .onboardingImage2) ?? Image.onboarding2.rawValue
      self.onboardingImage3 = try container.decodeIfPresent(String.self, forKey: .onboardingImage3) ?? Image.onboarding3.rawValue
      self.onboardingImage4 = try container.decodeIfPresent(String.self, forKey: .onboardingImage4) ?? Image.onboarding4.rawValue
      self.welcomeCard = try container.decodeIfPresent(String.self, forKey: .welcomeCard) ?? Image.onboardingPattern.rawValue
    }
  }
  
  final class CommunityText: Codable, DefaultsSerializable {
    enum CodingKeys: String, CodingKey {
      case onboardingTitle1 = "onboarding_title_1"
      case onboardingTitle2 = "onboarding_title_2"
      case onboardingTitle3 = "onboarding_title_3"
      case onboardingTitle4 = "onboarding_title_4"
      case onboardingText1 = "onboarding_text_1"
      case onboardingText2 = "onboarding_text_2"
      case onboardingText3 = "onboarding_text_3"
      case onboardingText4 = "onboarding_text_4"
      case privacyPolicyURLString = "privacy_policy_url"
      case termsOfServiceURLString = "terms_of_service_url"
      case contactURLString = "contact_url"
      case accessibilityURLString = "accessibility_url"
      case introBlurb = "intro_blurb"
    }
    
    var onboardingTitle1: String!
    var onboardingTitle2: String!
    var onboardingTitle3: String!
    var onboardingTitle4: String!
    var onboardingText1: String!
    var onboardingText2: String!
    var onboardingText3: String!
    var onboardingText4: String!
    var privacyPolicyURLString: String?
    var termsOfServiceURLString: String?
    var contactURLString: String?
    var accessibilityURLString: String?
    var introBlurb: String?
    
    var privacyPolicyURL: URL? {
      if let urlString = privacyPolicyURLString {
        return URL(string: urlString)
      }
      return nil
    }

    var termsOfServiceURL: URL? {
      if let urlString = termsOfServiceURLString {
        return URL(string: urlString)
      }
      return nil
    }
    
    var contactURL: URL? {
      if let urlString = contactURLString {
        return URL(string: urlString)
      }
      return nil
    }
    
    var accessibilityURL: URL? {
      if let urlString = accessibilityURLString {
        return URL(string: urlString)
      }
      return nil
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(onboardingTitle1, forKey: .onboardingTitle1)
      try container.encode(onboardingTitle2, forKey: .onboardingTitle2)
      try container.encode(onboardingTitle3, forKey: .onboardingTitle3)
      try container.encode(onboardingTitle4, forKey: .onboardingTitle4)
      try container.encode(onboardingText1, forKey: .onboardingText1)
      try container.encode(onboardingText2, forKey: .onboardingText2)
      try container.encode(onboardingText3, forKey: .onboardingText3)
      try container.encode(onboardingText4, forKey: .onboardingText4)
      try container.encode(privacyPolicyURLString, forKey: .privacyPolicyURLString)
      try container.encode(termsOfServiceURLString, forKey: .termsOfServiceURLString)
      try container.encode(contactURLString, forKey: .contactURLString)
      try container.encode(accessibilityURLString, forKey: .accessibilityURLString)
      try container.encode(introBlurb, forKey: .introBlurb)
    }
    
    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      self.onboardingTitle1 = try container.decodeIfPresent(String.self, forKey: .onboardingTitle1) ?? Onboarding.onboardingTitle1
      self.onboardingTitle2 = try container.decodeIfPresent(String.self, forKey: .onboardingTitle2) ?? Onboarding.onboardingTitle2
      self.onboardingTitle3 = try container.decodeIfPresent(String.self, forKey: .onboardingTitle3) ?? Onboarding.onboardingTitle3
     self.onboardingTitle4 = try container.decodeIfPresent(String.self, forKey: .onboardingTitle4) ?? Onboarding.onboardingTitle4
      self.onboardingText1 = try container.decodeIfPresent(String.self, forKey: .onboardingText1) ?? Onboarding.onboardingText1
      self.onboardingText2 = try container.decodeIfPresent(String.self, forKey: .onboardingText2) ?? Onboarding.onboardingText2
      self.onboardingText3 = try container.decodeIfPresent(String.self, forKey: .onboardingText3) ?? Onboarding.onboardingText3
      self.onboardingText4 = try container.decodeIfPresent(String.self, forKey: .onboardingText4) ?? Onboarding.onboardingText4
      self.privacyPolicyURLString = try container.decodeIfPresent(String.self, forKey: .privacyPolicyURLString)
      self.termsOfServiceURLString = try container.decodeIfPresent(String.self, forKey: .termsOfServiceURLString)
      self.contactURLString = try container.decodeIfPresent(String.self, forKey: .contactURLString)
      self.accessibilityURLString = try container.decodeIfPresent(String.self, forKey: .accessibilityURLString)
      self.introBlurb = try container.decodeIfPresent(String.self, forKey: .introBlurb)
    }
  }
}
