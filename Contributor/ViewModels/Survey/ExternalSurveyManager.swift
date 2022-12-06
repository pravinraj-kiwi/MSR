//
//  ExternalSurveyManager.swift
//  Contributor
//
//  Created by arvindh on 08/12/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import SwiftSoup
import SwiftyUserDefaults

class ExternalSurveyManager: NSObject {
  var offerItem: OfferItem
  
  init(offerItem: OfferItem) {
    self.offerItem = offerItem
    super.init()
  }
    
fileprivate func getSurveyMessageFromHTML(_ html: String) -> ExternalSurveyCompletion {
    let surveyCompletion = ExternalSurveyCompletion()
    let tests: [String?] = [
      (offerItem.eventMsg),
      (offerItem.eventShowPayment)
    ]

    for selector in tests {
      if let selector = selector {
        do {
          let doc = try SwiftSoup.parse(html)
            if let data = try doc.select(selector).first() {
                let value = try data.text()
                if selector == offerItem.eventMsg {
                    surveyCompletion.eventMsg = value
                }
                if selector == offerItem.eventShowPayment {
                    if value == Constants.falseText {
                        surveyCompletion.eventShowPayment = false
                    }
                    if value == Constants.trueText {
                        surveyCompletion.eventShowPayment = true
                    }
                }
            }
        } catch {
          print(error)
        }
      } else {}
    }
    return surveyCompletion
}
    
fileprivate func checkHtmlIfPresent(_ html: String) -> [(String?, SurveyStatus)] {
    let tests: [(String?, SurveyStatus)] = [
      (offerItem.completionV2Selector, .completed),
      (offerItem.disqualificationV2Selector, .disqualified),
      (offerItem.overQuotaV2Selector, .overQuota),
      (offerItem.terminatedV2Selector, .cancelled),
      (offerItem.inReviewSelector, .inReview)
    ]
    return tests
}
  
fileprivate func checkSurveyHTML(_ html: String) -> SurveyStatus {
  let tests: [(String?, SurveyStatus)] = checkHtmlIfPresent(html)
  for (selector, status) in tests {
    if let selector = selector {
     do {
      let doc = try SwiftSoup.parse(html)
      if let _ = try doc.select(selector).first() {
        return status
      }
    }
    catch {
      print(error)
    }
  }
}
return .inProgress
}

fileprivate func checkSurveyURL(_ url: URL) -> SurveyStatus {
typealias Test = (urlString: String?, urlRegex: String?, status: SurveyStatus)
let tests: [(String?, String?, SurveyStatus)] = [
  (offerItem.completionURLString, offerItem.completionURLRegex, .completed),
  (offerItem.disqualificationURLString, offerItem.disqualificationURLRegex, .disqualified),
  (offerItem.overQuotaURLString, offerItem.overQuotaURLRegex, .overQuota),
  (offerItem.terminatedSelector, offerItem.terminatedURLRegex, .cancelled)
]

for (urlString, urlRegex, status) in tests {
  
  // test a complete string match
  if let urlString = urlString, let surveyURL = URL(string: urlString), surveyURL == url {
    return status
  }
  
  // test a regex match
  if let pattern = urlRegex {
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
      let matchesCount = regex.numberOfMatches(in: url.absoluteString,
                                               options: [], range: NSRange(location: 0,
                                                                           length: url.absoluteString.length))
      
      if matchesCount > 0 {
        return status
      }
    }
    catch {
      os_log("Error checking URL regex.", log: OSLog.surveys, type: .error)
    }
  }
}
 return .inProgress
}
  
func checkSurveyStatus(url: URL? = nil, html: String? = nil) -> (SurveyStatus, ExternalSurveyCompletion) {
    var urlStatus = SurveyStatus.inProgress
    var htmlStatus = SurveyStatus.inProgress
    var surveyCompletion = ExternalSurveyCompletion()
    
    if let url = url {
      urlStatus = checkSurveyURL(url)
    }
    
    if let html = html {
      htmlStatus = checkSurveyHTML(html)
      surveyCompletion = getSurveyMessageFromHTML(html)
    }
    
    for status: SurveyStatus in [.completed, .disqualified, .overQuota, .cancelled, .inReview] {
      if [urlStatus, htmlStatus].contains(status) {
        return (status, surveyCompletion)
      }
    }
    return (.inProgress, surveyCompletion)
  }
}
