//
//  WidgetFont.swift
//  Contributor
//
//  Created by KiwiTech on 10/20/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import Foundation
import SwiftUI

enum WidgetFont {
  case light, regular, medium, bold

  private var weight: UIFont.Weight {
   switch self {
   case .light: return UIFont.Weight.light
   case .regular: return UIFont.Weight.regular
   case .medium: return UIFont.Weight.medium
   case .bold: return UIFont.Weight.bold
  }
}

func of(size: CGFloat) -> Font {
  var name: String
  switch self {
  case .light: name = "SFProDisplay-Light"
  case .regular: name = "SFProDisplay-Regular"
  case .medium: name = "SFProDisplay-Medium"
  case .bold: name = "SFProDisplay-Bold"
  }
  return Font.custom(name, size: size)
 }
}

class WidgetUtil {
    class func getRgbColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> Color {
        let color = UIColor.init(displayP3Red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
        return Color.init(color)
    }
}
