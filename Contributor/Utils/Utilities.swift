//
//  Utilities.swift
//  Contributor
//
//  Created by KiwiTech on 2/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class Utilities {
    
class func getRgbColor(_ red: CGFloat, _ green: CGFloat,
                       _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
   return UIColor.init(displayP3Red: red/255.0,
                       green: green/255.0,
                       blue: blue/255.0, alpha: alpha)
}

class func checkEnglishPhoneNumberFormat(string: String,
                                         str: String,
                                         txtPhoneNo: UITextField) -> Bool {
    if string == "" {
        return true
    } else if str.count == 4 ||
              str.count == 8 {
        txtPhoneNo.text = txtPhoneNo.text!
    } else if str.count > 12 {
        return false
    }
    return true
}

class func calculateAgeInYearsFromDateOfBirth (birthday: Date) -> Int {
  let now = Date()
  let calendar = Calendar.current
  let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
  if let age = ageComponents.year {
    return age
  }
  return 0
}

class func isValidPhone(str: String) -> Bool {
    let charcterSet  = NSCharacterSet(charactersIn: "0123456789").inverted
    let inputString = str.components(separatedBy: charcterSet)
    let filtered = inputString.joined(separator: "")
    let str = str.removeSpecialCharFromPhoneNo()
    return  str == filtered && str.count == 10
}

class func updateToDate(dateString: String) -> Date? {
    let dateformattor = DateFormatter()
    dateformattor.dateFormat = DateFormatType.serverDateFormat.rawValue
    dateformattor.timeZone = .current
    let dateStr = dateString
    let date = dateformattor.date(from: dateStr as String)
    return date
 }
 
class func convertDateToString(date: Date,
                               format: String = DateFormatType.normalDateWithTimeZoneFormat.rawValue,
                               outpuFormat: String = DateFormatType.shortDateFormat.rawValue) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    let myString = formatter.string(from: date)
    if let updatedDate = formatter.date(from: myString) {
        formatter.dateFormat = outpuFormat
        let formattedString = formatter.string(from: updatedDate)
        print(formattedString)
        return formattedString
     }
    return ""
   }
    
class func convertDateFormat(inputDate: String,
                             inputDateFormat: String,
                             outPutFormat: String) -> String {
    let olDateFormatter = DateFormatter()
    olDateFormatter.dateFormat = inputDateFormat
     let convertDateFormatter = DateFormatter()
     convertDateFormatter.dateFormat = outPutFormat
    if let newDate = olDateFormatter.date(from: inputDate) {
        return convertDateFormatter.string(from: newDate)
    }
    return ""
}

  class func makeBulletList(from strings: [String], bulletCharacter: String = "\u{2022}",
                            bulletAttributes: [NSAttributedString.Key: Any] = [:],
                            textAttributes: [NSAttributedString.Key: Any] = [:],
                            indentation: CGFloat = 20, lineSpacing: CGFloat = 1,
                            paragraphSpacing: CGFloat = 10) -> NSAttributedString {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.defaultTabInterval = indentation
      paragraphStyle.tabStops = [
          NSTextTab(textAlignment: .left, location: indentation)
      ]
      paragraphStyle.lineSpacing = lineSpacing
      paragraphStyle.paragraphSpacing = paragraphSpacing
      paragraphStyle.headIndent = indentation
      let bulletList = NSMutableAttributedString()
      for string in strings {
          let bulletItem = "\(bulletCharacter)\t\(string)\n"
          var attributes = textAttributes
          attributes[.paragraphStyle] = paragraphStyle
          let attributedString = NSMutableAttributedString(
              string: bulletItem, attributes: attributes
          )
          if !bulletAttributes.isEmpty {
              let bulletRange = (bulletItem as NSString).range(of: bulletCharacter)
              attributedString.addAttributes(bulletAttributes, range: bulletRange)
          }
          bulletList.append(attributedString)
      }
      if bulletList.string.hasSuffix("\n") {
          bulletList.deleteCharacters(
              in: NSRange(location: bulletList.length - 1, length: 1)
          )
      }
      return bulletList
  }
    
  class func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((1...length).map { _ in letters.randomElement()!})
  }
    
 class func isNotNil(_ someObject: Any?) -> Bool {
    switch someObject {
    case is String:
    if (someObject as? String) != "" {
        return true
    } else {
        return false
    }
    case is Int:
    if (someObject as? Int) != nil {
        return true
    } else {
        return false
    }
    default:
        return false
    }
}
    
class func serverDateInUTC(isoDate: String) -> Date {
  let dateFormatter = DateFormatter()
  dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
  dateFormatter.dateFormat = DateFormatType.serverDateFormat.rawValue
  if let date = dateFormatter.date(from: isoDate) {
    return date
  }
  return Date()
}
    
class func clearAllDataFrom(folderName: String) {
   let fm = FileManager.default
   do {
      let folderPath = NSTemporaryDirectory() + folderName
      let paths = try fm.contentsOfDirectory(atPath: folderPath)
      for path in paths {
       try fm.removeItem(atPath: "\(folderPath)/\(path)")
      }
   } catch { }
  }
  class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension String {
    
    func removeSpecialCharFromPhoneNo() -> String {
        var phone = self.replacingOccurrences(of: "(", with: "")
        phone = phone.replacingOccurrences(of: ")", with: "")
        phone = phone.replacingOccurrences(of: "-", with: "")
        phone = phone.replacingOccurrences(of: " ", with: "")
        phone = phone.replacingOccurrences(of: "+", with: "")
        return phone
    }
    func localized(bundle: Bundle = AppLanguageManager.shared.bundle, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self,
                                 tableName: tableName,
                                 bundle: bundle,
                                 comment: "")
    }
}
