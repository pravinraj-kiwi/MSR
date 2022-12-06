//
//  UIControl+Extension.swift
//  Contributor
//
//  Created by KiwiTech on 9/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension UIStackView {
func removeAllArrangedSubviews() {
    arrangedSubviews.forEach {$0.removeFromSuperview()}
  }
}

extension UIColor {
public convenience init?(hexString: String) {
  let r, g, b, a: CGFloat
  if hexString.hasPrefix("#") {
    let start = hexString.index(hexString.startIndex, offsetBy: 1)
    let hexColor = String(hexString[start...])
      
    if hexColor.count == 8 {
      let scanner = Scanner(string: hexColor)
      var hexNumber: UInt64 = 0
        
      if scanner.scanHexInt64(&hexNumber) {
        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
        a = CGFloat(hexNumber & 0x000000ff) / 255
          
        self.init(red: r, green: g, blue: b, alpha: a)
          return
        }
      }
    }
    return nil
}
  
func lighter(by percentage: CGFloat = 30.0) -> UIColor {
  return self.adjustBrightness(by: abs(percentage))
}
  
func darker(by percentage: CGFloat = 30.0) -> UIColor {
  return self.adjustBrightness(by: -abs(percentage))
}
  
func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
      if b < 1.0 {
        let newB: CGFloat
        if b == 0.0 {
          newB = max(min(b + percentage/100, 1.0), 0.0)
        } else {
          newB = max(min(b + (percentage/100.0)*b, 1.0), 0,0)
        }
        return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
      } else {
        let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
        return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
      }
    }
    return self
  }
}

extension UIImage {
  func calculateHeight(for width: CGFloat) -> CGFloat {
    return width * size.height / size.width
  }
}

extension UIButton {
func setBackgroundColor(color: UIColor, forState: UIControl.State) {
 self.clipsToBounds = true
 UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
 if let context = UIGraphicsGetCurrentContext() {
   context.setFillColor(color.cgColor)
   context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
   let colorImage = UIGraphicsGetImageFromCurrentImageContext()
   UIGraphicsEndImageContext()
   self.setBackgroundImage(colorImage, for: forState)
  }
}
  
func setDarkeningBackgroundColor(color: UIColor) {
  backgroundColor = color
  setBackgroundColor(color: color.darker(by: 20), forState: .highlighted)
}
    
func setEnabled(_ value: Bool) {
  isEnabled = value
  alpha = value ? 1.0 : 0.4
  }
}

extension UIImageView {
func setImageWithAssetOrURL(with assetNameOrURL: String) {
  if assetNameOrURL.starts(with: "http") {
    kf.setImage(with: URL(string: assetNameOrURL))
  } else {
    if let imageFromAsset = UIImage(named: assetNameOrURL) {
      image = imageFromAsset
    }
  }
}

func setImageColor(color: UIColor) {
  let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
  self.image = templateImage
  self.tintColor = color
  }
}

extension UILabel {
func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
  assert(self.attributedText != nil, "This method is developed for attributed string")
  let textStorage = NSTextStorage(attributedString: self.attributedText!)
  let layoutManager = NSLayoutManager()
  textStorage.addLayoutManager(layoutManager)
  let textContainer = NSTextContainer(size: self.frame.size)
  textContainer.lineFragmentPadding = 0
  textContainer.maximumNumberOfLines = self.numberOfLines
  textContainer.lineBreakMode = self.lineBreakMode
  layoutManager.addTextContainer(textContainer)
  let index = layoutManager.characterIndex(for: point, in: textContainer,
                                             fractionOfDistanceBetweenInsertionPoints: nil)
    return index
  }
}

extension UITextField {
func validateForPhoneNumber(CharactersIn range: NSRange,
                                string: String) -> Bool {
  if Utilities.isValidPhone(str: string) {
    return true
  }
  guard let text = self.text?.replacingOccurrences(of: "\\p{Cf}",
                                                         with: "",
                                                         options: .regularExpression)
  else { return true }
  switch string {
  case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "":
    let newLength = text.utf16.count + string.utf16.count - range.length
    if newLength <= Constants.PhoneNoCharLimit {
        let str = (self.text! as NSString).replacingCharacters(in: range, with: string)
        return Utilities.checkEnglishPhoneNumberFormat(string: string, str: str, txtPhoneNo: self)
    } else {
        return false
    }
    default: return false
      }
   }
}

extension UIActivityIndicatorView {
func updateIndicatorView(_ controller: UIViewController, hidden: Bool) {
  controller.view.isUserInteractionEnabled = hidden
  self.isHidden = hidden
  if hidden {
    self.stopAnimating()
  } else {
    self.startAnimating()
  }
 self.style = .medium
}
    
func showIndicatorView(hidden: Bool) {
  self.isHidden = hidden
  if hidden {
    self.stopAnimating()
  } else {
    self.startAnimating()
  }
  self.style = .medium
  }
}

extension UIProgressView {
  @IBInspectable var barHeight: CGFloat {
    get {
      return transform.d * 2.0
    }
    set {
      let heightScale = newValue / 2.0
      let c = center
      transform = CGAffineTransform(scaleX: 1.0, y: heightScale)
      center = c
     }
   }
}

extension UIStackView {
func addBackground(color: UIColor) {
  let subView = UIView(frame: bounds)
  subView.backgroundColor = color
  subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  insertSubview(subView, at: 0)
  }
}
