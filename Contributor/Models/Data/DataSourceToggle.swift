//
//  DataSourceToggle.swift
//  Contributor
//
//  Created by arvindh on 11/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

enum DataSource {
  case spotify
  case amazon
  case location
  case health
  
  var image: Image? {
    switch self {
    case .spotify: return Image.spotify
    case .amazon: return Image.amazon
    case .location: return Image.location
    case .health: return Image.health
    }
  }
  
  var title: String {
    switch self {
    case .spotify: return "Spotify"
    case .amazon: return "Amazon"
    case .location: return "Location"
    case .health: return "Health"
    }
  }
  
  var displayString: String {
    return "Connect \(title)"
  }
  
  var itemDescription: String {
    switch self {
    case .spotify:
      return "Your listening habits can say a lot about your mood, personality, and many other traits. Connect Spotify to share your music and listening choices for rewards. No data will leave your device until you’ve agreed to specific offers."
    case .amazon:
      return "What you buy, how often, and from which brands is enormously helpful to understand purchasing patterns and trends. Connect your Amazon account and get rewarded for sharing your data. No data will leave your device until you’ve agreed to specific offers."
    case .location:
      return "Location data is often useful to provide context for certain types of research. Connect your Location data and get rewarded. No data will leave your device until you’ve agreed to specific offers."
    case .health:
      return "Your health data can provide valuable insight into the way you live and can contribute to the development of health products and services. Connect your Health data and get rewarded. No data will leave your device until you’ve agreed to specific offers."
    }
  }
  
  var keyPath: ReferenceWritableKeyPath<User, Bool> {
    switch self {
    case .spotify: return \User.isCollectingSpotify
    case .amazon: return \User.isCollectingAmazon
    case .location: return \User.isCollectingLocation
    case .health: return \User.isCollectingHealth
    }
  }
  
  var key: User.CodingKeys {
    switch self {
    case .spotify: return User.CodingKeys.isCollectingSpotify
    case .amazon: return User.CodingKeys.isCollectingAmazon
    case .location: return User.CodingKeys.isCollectingLocation
    case .health: return User.CodingKeys.isCollectingHealth
    }
  }
}

class DataSourceHolder: NSObject {
  var items: [DataSource] = []
  
  init(items: [DataSource]) {
    self.items = items
    super.init()
  }
}
