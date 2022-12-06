//
//  Colors.swift
//  Contributor
//
//  Created by arvindh on 21/06/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import UIKit

enum Color {
  case background, lightBackground, primary, darkPrimary, accent, unselected, border, slightlyLightBorder, lightBorder, veryLightBorder, text, lightText, veryLightText, placeholderText, whiteText, almostWhiteText, navigationItemTint, color1, color2, color3, color1Light, color2Light, color3Light, error, selectedItem, pill, introScreenBackground, introScreenText, introScreenButton, introScreenButtonText, mydataBackroundColor, dashColor, linkedinTextColor, cellBackgroundColor

  var value: UIColor {
    switch self {
    case .primary: return UIColor("#5D47FB")
    case .darkPrimary: return UIColor("#4634C8")
    case .background: return UIColor("#FFFFFF")
    case .text: return UIColor("#111111")
    case .lightBackground: return UIColor("#F3F3F3")
    case .accent: return UIColor("#DE5463")
    case .unselected: return UIColor("#A5A5A5")
    case .border: return UIColor("#D8D8D8")
    case .slightlyLightBorder: return UIColor("#E6E6E6")
    case .lightBorder: return UIColor("#F0F0F0")
    case .veryLightBorder: return UIColor("#F4F4F4")
    case .lightText: return UIColor("#808080")
    case .mydataBackroundColor: return UIColor("#E3EEF2")
    case .linkedinTextColor: return UIColor("#525252")
    case .dashColor: return UIColor("#3F9BD2")
    case .veryLightText: return UIColor("#D8D8D8")
    case .placeholderText: return UIColor("#989898")
    case .whiteText: return UIColor("#FFFFFF")
    case .almostWhiteText: return UIColor("#F7F7F7")
    case .navigationItemTint: return UIColor("#000000")
    case .error: return UIColor("#F24236")
    case .selectedItem: return UIColor("#FFD66B")
    case .pill: return UIColor("#4FA6DB")
    case .introScreenBackground: return UIColor("#5B3DFE")
    case .introScreenText: return UIColor("#111111")
    case .introScreenButton: return UIColor("#5D47FB")
    case .introScreenButtonText: return UIColor("#FFFFFF")
    case .color1: return UIColor(red: 1.00, green: 0.78, blue: 0.00, alpha: 1.0)
    case .color2: return UIColor(red: 0.00, green: 0.66, blue: 0.94, alpha: 1.0)
    case .color3: return UIColor(red: 1.00, green: 0.00, blue: 0.54, alpha: 1.0)
    case .color1Light: return UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.0)
    case .color2Light: return UIColor(red: 0.33, green: 0.76, blue: 0.99, alpha: 1.0)
    case .color3Light: return UIColor(red: 1.00, green: 0.31, blue: 0.70, alpha: 1.0)
    case .cellBackgroundColor: return UIColor(red: 242.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    }
  }
}

let colorList = [Color.color1, Color.color2, Color.color3]
let colorListLight = [Color.color1Light, Color.color2Light, Color.color3Light]
