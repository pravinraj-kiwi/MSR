//
//  JobOffer.swift
//  Contributor
//
//  Created by KiwiTech on 10/20/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import Foundation

struct JobOfferResponse: Decodable {
  let result: [JobOffer]?
}

struct JobOffer: Decodable {
  let id, estimated_earnings_msr, estimated_minutes_to_complete: Int
  let title, description, expiry_date: String?
  let isFromSnapShot: Bool?
  let noJob: Bool?
}

class WidgetData {
func getMinuteInInt(_ expiry_date: String?) -> Int? {
    let now = Date()
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US_POSIX")
    dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    if let expireDate = expiry_date,
       let expiryDate = dateFormat.date(from: expireDate), expiryDate > now {
      return Int(expiryDate.timeIntervalSinceNow / 60)
    }
    return nil
}

func getDateInMinutes(_ minutes: Int) -> String {
    switch minutes {
    case 0, 1:
      return "1 minute"
    case 2...59:
      return "\(minutes) minutes"
    default:
      let hours: Int = Int(minutes / 60)
     switch hours {
     case 1:
      return "1 hour"
     case 2...23:
      return "\(hours) hours"
     default:
      let days: Int = Int(hours / 24)
      switch days {
      case 1:
        return "1 day"
      default:
        return "\(days) days"
    }
   }
  }
  return ""
}
}
