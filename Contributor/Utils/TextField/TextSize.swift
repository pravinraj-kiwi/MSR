//
//  TextSize.swift
//  Contributor
//
//  Created by John Martin on 4/2/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

public struct TextSize {
  static let singleLineExampleText = "M"  // doesn't really matter what this is
  
  fileprivate struct CacheEntry: Hashable {
    let text: String
    let font: UIFont
    let width: CGFloat
    let insets: UIEdgeInsets
    let lineSpacing: CGFloat
    
    fileprivate var hashValue: Int {
      return text.hashValue ^ Int(width) ^ Int(insets.top) ^ Int(insets.left) ^ Int(insets.bottom) ^ Int(insets.right) ^ Int(lineSpacing)
    }
  }
  
  fileprivate static var cache = [CacheEntry: CGFloat]() {
    didSet {
      assert(Thread.isMainThread)
    }
  }
  
  public static func calculateHeight(_ text: String, font: UIFont, width: CGFloat, insets: UIEdgeInsets = UIEdgeInsets.zero, lineSpacing: CGFloat = 1.0) -> CGFloat {

    let key = CacheEntry(text: text, font: font, width: width, insets: insets, lineSpacing: lineSpacing)
    if let hit = cache[key] {
      return hit
    }
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
    let constrainedSize = CGSize(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)
    let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]

    let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
    let height: CGFloat = ceil(bounds.height + insets.top + insets.bottom)
    cache[key] = height
    return height
  }
  
  public static func calculateSingleLineHeight(font: UIFont, width: CGFloat, insets: UIEdgeInsets = UIEdgeInsets.zero, lineSpacing: CGFloat = 1.0) -> CGFloat {
    return calculateHeight(singleLineExampleText, font: font, width: width, insets: insets, lineSpacing: lineSpacing)
  }
}

private func ==(lhs: TextSize.CacheEntry, rhs: TextSize.CacheEntry) -> Bool {
  return lhs.width == rhs.width && lhs.insets == rhs.insets && lhs.text == rhs.text && lhs.lineSpacing == rhs.lineSpacing && lhs.font == rhs.font
}
