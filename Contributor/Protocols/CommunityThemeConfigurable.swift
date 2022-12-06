//
//  CommunityThemeConfigurable.swift
//  Contributor
//
//  Created by arvindh on 21/05/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CommunityThemeConfigurable {
  @objc optional func registerForNewCommunityThemeNotification()
  @objc func applyCommunityTheme()
}

extension CommunityThemeConfigurable where Self: NSObject {
  func registerForNewCommunityThemeNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.applyCommunityTheme), name: NSNotification.Name.communityThemeApplied, object: nil)
  }  
}
