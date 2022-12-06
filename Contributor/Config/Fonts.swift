//
//  Fonts.swift
//  Contributor
//
//  Created by arvindh on 21/06/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import UIKit

enum Font {
  case light, regular, medium, semiBold, bold, italic

  private var weight: UIFont.Weight {
   switch self {
   case .light: return UIFont.Weight.light
   case .regular: return UIFont.Weight.regular
   case .medium: return UIFont.Weight.medium
   case .semiBold: return UIFont.Weight.semibold
   case .bold: return UIFont.Weight.bold
   case .italic: return UIFont.Weight.regular
  }
}

func of(size: CGFloat) -> UIFont {
  let attributes: [UIFontDescriptor.AttributeName: Any] = [:]
  var name: String

  switch self {
  case .light: name = "ProximaNova-Light"
  case .regular: name = "ProximaNova-Regular"
  case .medium: name = "ProximaNova-Medium"
  case .semiBold: name = "ProximaNova-Semibold"
  case .bold: name = "ProximaNova-Bold"
  case .italic: name = "ProximaNova-RegularIt"
}

if let font = UIFont(name: name, size: size) {
   let descriptor = font.fontDescriptor.addingAttributes(attributes)
   return UIFont(descriptor: descriptor, size: size)
  }
  return UIFont(name: name, size: size) ?? UIFont()
}

func asTextAttributes(size: CGFloat) -> [NSAttributedString.Key: Any] {
  return [NSAttributedString.Key.font: self.of(size: size)]
  }
}
