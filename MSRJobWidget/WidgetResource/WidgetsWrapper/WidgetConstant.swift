//
//  WidgetConstant.swift
//  Contributor
//
//  Created by KiwiTech on 10/22/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import Foundation
import SwiftUI

class WidgetConstant {
  static let todayJob = "Today’s Jobs"
  static let noJobText = "We’re searching the galaxy for more jobs"
  static let defaultName = "Hannah"
  static let completeTimeText = "1 minute to complete"
}

struct SuitDefaultName {
  static let userCommunity = "loggedInUserCommunityColor"
  static let userBalance = "loggedInUserBalanceMsr"
  static let userFirstName = "loggedInUserFirstName"
  static let accessToken = "accessTokenWidget"
}

struct DarkModeImageName {
  static let darkMode = "darkMode"
  static let darkMode1 = "darkMode1"
  static let darkMode2 = "darkMode2"
  static let darkMode3 = "darkMode3"
  static let darkMode4 = "darkMode4"
  static let msrPill = "msrPill"
}

struct LightModeImageName {
  static let lightMode = "lightMode"
  static let lightMode1 = "lightMode1"
  static let lightMode2 = "lightMode2"
  static let lightMode3 = "lightMode3"
  static let lightMode4 = "lightMode4"
  static let msrPillPlaceholder = "msrPillPlaceholder"
}

struct NoJobImageName {
  static let smallNoJob = "smallNoJob"
  static let medLargeJob = "MedLargeNoJob"
}

extension Color {
init(hex string: String) {
    var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    if string.hasPrefix("#") {
        _ = string.removeFirst()
    }
    if !string.count.isMultiple(of: 2), let last = string.last {
        string.append(last)
    }
    if string.count > 8 {
        string = String(string.prefix(8))
    }
    let scanner = Scanner(string: string)
    var color: UInt64 = 0
    scanner.scanHexInt64(&color)

    if string.count == 2 {
        let mask = 0xFF
        let g = Int(color) & mask
        let gray = Double(g) / 255.0
        self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

    } else if string.count == 4 {
        let mask = 0x00FF
        let g = Int(color >> 8) & mask
        let a = Int(color) & mask
        let gray = Double(g) / 255.0
        let alpha = Double(a) / 255.0
        self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)

    } else if string.count == 6 {
        let mask = 0x0000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = Double(r) / 255.0
        let green = Double(g) / 255.0
        let blue = Double(b) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

    } else if string.count == 8 {
        let mask = 0x000000FF
        let r = Int(color >> 24) & mask
        let g = Int(color >> 16) & mask
        let b = Int(color >> 8) & mask
        let a = Int(color) & mask
        let red = Double(r) / 255.0
        let green = Double(g) / 255.0
        let blue = Double(b) / 255.0
        let alpha = Double(a) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)

    } else {
        self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
    }
  }
}
