//
//  os+Extensions.swift
//  Contributor
//
//  Created by John Martin on 1/23/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import os.log

public extension OSLog {
  static var subsystem = Bundle.main.bundleIdentifier!
  static let qualification = OSLog(subsystem: subsystem, category: "qualification")
  static let notifications = OSLog(subsystem: subsystem, category: "notifications")
  static let networkCharacterization = OSLog(subsystem: subsystem, category: "networkCharacterization")
  static let views = OSLog(subsystem: subsystem, category: "views")
  static let surveys = OSLog(subsystem: subsystem, category: "surveys")
  static let profileStore = OSLog(subsystem: subsystem, category: "profileStore")
  static let cloudKit = OSLog(subsystem: subsystem, category: "cloudKit")
  static let themes = OSLog(subsystem: subsystem, category: "themes")
  static let logicEngine = OSLog(subsystem: subsystem, category: "logicEngine")
  static let signUp = OSLog(subsystem: subsystem, category: "signUp")
  static let signIn = OSLog(subsystem: subsystem, category: "signIn")
  static let settings = OSLog(subsystem: subsystem, category: "settings")
  static let feed = OSLog(subsystem: subsystem, category: "feed")
  static let myData = OSLog(subsystem: subsystem, category: "myData")
  static let wallet = OSLog(subsystem: subsystem, category: "wallet")
  static let network = OSLog(subsystem: subsystem, category: "network")
  static let appDelegate = OSLog(subsystem: subsystem, category: "appDelegate")
  static let pushNotificationManager = OSLog(subsystem: subsystem, category: "pushNotificationManager")
  static let community = OSLog(subsystem: subsystem, category: "community")
  static let analytics = OSLog(subsystem: subsystem, category: "analytics")
  static let profileMaintenance = OSLog(subsystem: subsystem, category: "profileMaintenance")
}
