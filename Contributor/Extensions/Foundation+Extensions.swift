//
//  Foundation+Extensions.swift
//  Contributor
//
//  Created by arvindh on 12/07/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import IGListKit
import CCTemplate
import SwiftyAttributes

extension NSObject: ListDiffable {
  public func diffIdentifier() -> NSObjectProtocol {
    return self
  }
  
  public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    return isEqual(object)
  }
}

extension String {
  func replaced(dict: [String: String]?) -> String? {
    let engine = CCTemplate()
    return engine.scan(self, dict: dict)
  }
  
  var length: Int {
    return self.lengthOfBytes(using: String.Encoding.utf8)
  }
  
  func lineSpaced(_ spacing: CGFloat, with font: UIFont? = nil) -> NSMutableAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = spacing
    var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
    if let font = font {
      attributes[.font] = font
    }
    return NSMutableAttributedString(string: self, attributes: attributes)
  }

  func lineSpacedAndCentered(_ spacing: CGFloat, with font: UIFont? = nil) -> NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = spacing
    paragraphStyle.alignment = .center
    var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
    if let font = font {
      attributes[.font] = font
    }
    return NSMutableAttributedString(string: self, attributes: attributes)
  }
  
  var isBackspace: Bool {
    if let char = self.cString(using: String.Encoding.utf8) {
      let comp = strcmp(char, "\\b")
      if comp == -92 {
        return true
      }
    }
    return false
  }
}

extension NSMutableAttributedString {
  func addAttributesToTerms(_ attributes: [Attribute], to terms: [String]) {
    for term in terms {
      addAttributes(attributes, range: (string as NSString).range(of: term))
    }
  }
}

extension Int {
  private static var withCommasFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter
  }()
  
  var stringWithCommas: String {
    return Int.withCommasFormatter.string(from: NSNumber(value: self)) ?? ""
  }
  
  var formattedMSRString: String {
    return "\(self.stringWithCommas) MSR"
  }
}

extension Decimal {
  private static var fiatFormatter: NumberFormatter = {
    let decimalFormatter = NumberFormatter()
    decimalFormatter.numberStyle = .decimal
    decimalFormatter.maximumFractionDigits = 2
    decimalFormatter.minimumFractionDigits = 2
    return decimalFormatter
  }()
  
  var formattedFiatString: String {
    let suffix = Decimal.fiatFormatter.string(from: self as NSDecimalNumber) ?? "0.00"
    let currency = UserManager.shared.user?.currency ?? .USD
    return "\(currency.symbol)\(suffix)"
  }
}

extension Set {
  mutating func toggle(item: Element) {
    if contains(item) {
      remove(item)
    } else {
      insert(item)
    }
  }
}

extension Bundle {
  var releaseVersionNumber: String? {
    return infoDictionary?["CFBundleShortVersionString"] as? String
  }
  var buildVersionNumber: String? {
    return infoDictionary?["CFBundleVersion"] as? String
  }
}
public extension CGPoint {

    enum CoordinateSide {
        case topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left
    }

    static func unitCoordinate(_ side: CoordinateSide) -> CGPoint {
        switch side {
        case .topLeft:      return CGPoint(x: 0.0, y: 0.0)
        case .top:          return CGPoint(x: 0.5, y: 0.0)
        case .topRight:     return CGPoint(x: 1.0, y: 0.0)
        case .right:        return CGPoint(x: 0.0, y: 0.5)
        case .bottomRight:  return CGPoint(x: 1.0, y: 1.0)
        case .bottom:       return CGPoint(x: 0.5, y: 1.0)
        case .bottomLeft:   return CGPoint(x: 0.0, y: 1.0)
        case .left:         return CGPoint(x: 1.0, y: 0.5)
        }
    }
}
