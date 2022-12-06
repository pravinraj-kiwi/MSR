//
//  FeedItem.swift
//  Contributor
//
//  Created by arvindh on 16/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyUserDefaults
import IGListKit
class Feed: NSObject, Mappable {
    required init?(map: Map) {
      super.init()
    }
    var stories: [Story]?
    var feedItem: [FeedItem]?
   
    func mapping(map: Map) {
        stories <- map["stories"]
        feedItem <- map["feed"]
    }
}
class Story: NSObject, Mappable {
    required init?(map: Map) {
      super.init()
    }
    var id: Int!
    var guid: String!
    var itemType: String?
    var priority: Int!
    var createdDate: Date?
    var updatedDate: Date?
    var item: StoryItem!
   // var properties:
    func mapping(map: Map) {
        id <- map["id"]
        guid <- map["guid"]
        itemType <- map["item_type"]
        priority <- map["priority"]
        item <- map["item"]
        createdDate <- (map["created_date"], ISO8601DateTransform())
        updatedDate <- (map["updated_date"], ISO8601DateTransform())
        
    }
//    public override func diffIdentifier() -> NSObjectProtocol {
//      return feedID as NSObjectProtocol
//    }
}
// MARK: - Properties
struct Properties: Codable {
}

// MARK: - StoryItem
class StoryItem: NSObject, Mappable {
    enum LayoutType: String {
        case webImage4x1 = "4:1"
        case webImage4x2 = "4:2"
        case webImage4x3 = "4:3"
        case webImage4x4 = "4:4"
        case unowned
    }
    required init?(map: Map) {
      super.init()
    }
    var id: Int?
    var guid, textTitle, textDescription, itemName, contentType: String?
    var html, htmlURL, icon: String?
    var seen: Bool = false
    var userSpecific: Bool = false
    var opened: Bool = false
    var links: [Link]?
    var createdDate, updatedDate, expiryDate: Date?
    var properties: Properties?
    var isSelected: Bool?
    var openedByDefault: Bool?
    var storySeened: Bool?
    var layoutType: LayoutType = .webImage4x1

    func mapping(map: Map) {
        id <- map["id"]
        guid <- map["guid"]
        contentType <- map["content_type"]
        itemName <- map["item_name"]
       // itemType <- map["item_type"]
        textTitle <- map["title"]
        textDescription <- map["description"]
        html <- map["html"]
        htmlURL <- map["html_url"]
        icon <- map["icon_url"]
        seen <- map["seen"]
        storySeened <- map["seen"]
        opened <- map["opened"]
        openedByDefault <- map["open_by_default"]
        userSpecific <- map["user_specific"]
        links <- map["links"]
        createdDate <- (map["created_date"], ISO8601DateTransform())
        updatedDate  <- (map["updated_date"], ISO8601DateTransform())
        expiryDate  <- (map["expiry_date"], ISO8601DateTransform())
        properties <- map["properties"]
        isSelected <- map["isSelected"]
        layoutType <- map["preferred_aspect_ratio"]

    }
}
// MARK: - Link
class Link: NSObject, Mappable {
    required init?(map: Map) {
      super.init()
    }
    var text, action, linkURL, descriptionStyle: String?
    
    func mapping(map: Map) {
        text <- map["text"]
        action <- map["action"]
        linkURL <- map["url"]
        descriptionStyle <- map["description_style"]
    }
}
class FeedItem: NSObject, Mappable {
    required init?(map: Map) {
      super.init()
    }
    var feedID: Int!
    var feedGUID: String!
    var feedType: String?
    var feedPriority: Int!
    var createdDate: Date?
    var updatedDate: Date?
    var item: OfferItem!
    func mapping(map: Map) {
        feedID <- map["id"]
        feedGUID <- map["guid"]
        feedType <- map["item_type"]
        feedPriority <- map["priority"]
        item <- map["item"]
        createdDate <- (map["created_date"], ISO8601DateTransform())
        updatedDate <- (map["updated_date"], ISO8601DateTransform())
        
    }
//    public override func diffIdentifier() -> NSObjectProtocol {
//      return feedID as NSObjectProtocol
//    }
}

class OfferItem: NSObject, Mappable {
  enum LayoutType: String {
    case textOnly, topImage1x1, topImage2x1, topImage3x1
  }

  enum ResponseStatus: Int {
    case offered = 10
    case started = 20
    case qualified = 30
    case disqualified = 40
    case abandoned = 50
    case completed = 60
  }

  enum RequestStatus: Int {
    case open = 10
    case closed = 20
  }
  
  enum OfferType: Int {
    case `internal` = 10
    case external = 20
  }
  
  var offerID: Int!
  var offerGUID: String!
  var offerType: OfferType = .internal
  var offerTypeLabel: String?
  var communitySlug: String?
  var sampleRequestID: Int?
  var title: String?
  var itemDescription: String?
  var estimatedMinutes: Int!
  var imageURLString: String?
  var urlString: String!
  var startedCallbackURLString: String?
  var completedCallbackURLString: String?
  var terminatedCallbackURLString: String?
  var userTerminatedCallbackURLString: String?
  var workShopSurveyCallbackURLString: String?
  var estimatedEarnings: Int = 0
  var disqualifyEarnings: Int = 0
  var urlParameters: String?
  var completionSelector: String?
  var completionV2Selector: String?
  var completionURLString: String?
  var completionURLRegex: String?
  var eventMsg: String?
  var eventShowPayment: String?
  var disqualificationSelector: String?
  var disqualificationV2Selector: String?
  var disqualificationURLString: String?
  var disqualificationURLRegex: String?
  var overQuotaSelector: String?
  var overQuotaV2Selector: String?
  var overQuotaURLString: String?
  var overQuotaURLRegex: String?
  var terminatedSelector: String?
  var terminatedV2Selector: String?
  var terminatedURLString: String?
  var terminatedURLRegex: String?
  var inReviewSelector: String?
  var responseStatus: ResponseStatus = .offered
  var requestStatus: RequestStatus = .open
  var layoutType: LayoutType = .topImage1x1
  var backgroundColorHexString: String?
  var useWhiteText: Bool = false
  var foregroundColorHexString: String?
  var foregroundLightColorHexString: String?
  var seen: Bool = false
  var opened: Bool = false
  var declined: Bool = false
  var expiryDate: Date?
  var appendIdentifiers: Bool = true
  var appendProfileItems: Bool = false
  var embeddedSurvey: Survey?
  var isProfileMaintenanceSurvey: Bool = false
  var sampleRequestType: String?
  var disclaimer: String?
    var javaScriptSurveyMonitorEnabled: Bool = false
    var javaScriptSurveyMonitorJavaScriptURLString: String?
    var javaScriptSurveyMonitorJavaScriptFunction: String?
      var storyTitle: String?
    var storyDesc: String?
      var offerHtml: String?
      var action: String?
      var linkURL: String?
      var htmlURL: String?
      var icon: String?
      var createdDate: Date?
      var updatedDate: Date?

  var estimatedMinutesString: String {
    if let estimatedMinutes = estimatedMinutes {
      return "\(estimatedMinutes) minutes"
    }
    return "-"
  }
  
  var estimatedEarningsFiat: Decimal {
    let currency = UserManager.shared.user?.currency ?? .USD
    return MSRConverter.convertTo(estimatedEarnings, currency: currency)
  }

  var disqualifyEarningsFiat: Decimal {
    let currency = UserManager.shared.user?.currency ?? .USD
    return MSRConverter.convertTo(disqualifyEarnings, currency: currency)
  }

  var url: URL? {
    return URL(string: urlString)
  }

  var imageURL: URL? {
    if let urlString = imageURLString {
      return URL(string: urlString)
    }
    return nil
  }

  var startedCallbackURL: URL? {
    if let urlString = startedCallbackURLString {
      return URL(string: urlString)
    }
    return nil
  }

  var completedCallbackURL: URL? {
    if let urlString = completedCallbackURLString {
      return URL(string: urlString)
    }
    return nil
  }

  var terminatedCallbackURL: URL? {
    if let urlString = terminatedCallbackURLString {
      return URL(string: urlString)
    }
    return nil
  }
    
  var userTerminatedCallbackURL: URL? {
    if let urlString = userTerminatedCallbackURLString {
      return URL(string: urlString)
    }
    return nil
  }
    
  var workShopSurveyCallbackURL: URL? {
    if let urlString = workShopSurveyCallbackURLString {
      return URL(string: urlString)
    }
    return nil
  }

  var backgroundColor: UIColor? {
    if let hexString = backgroundColorHexString {
      return UIColor(hexString: hexString)
    }
    return nil
  }
  
  var minutesUntilExpiry: Int? {
    let now = Date()
    if let expiryDate = expiryDate, expiryDate > now {
      return Int(expiryDate.timeIntervalSinceNow / 60)
    }
    return nil
  }
  
  var expiryString: String? {
    if let minutes = minutesUntilExpiry {
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
    }
    return nil
  }
  
  var offerIDForAnalytics: String {
    if let offerID = offerID {
      return "\(offerID)"
    } else {
      return ""
    }
  }
    var externalHTMLURL: URL? {
      if let urlString = htmlURL {
        return URL(string: urlString)
      }
      return nil
    }

  var isExternallySampled: Bool {
    return sampleRequestID != nil
  }
    var javaScriptMonitorURL: URL? {
      if let urlString = javaScriptSurveyMonitorJavaScriptURLString {
        return URL(string: urlString)
      }
      return nil
    }
  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    offerID <- map["id"]
    offerGUID <- map["guid"]
    title <- map["title"]
    itemDescription <- map["description"]
    offerType <- map["offer_type"]
    offerTypeLabel <- map["offer_type_label"]
    communitySlug <- map["community"]
    sampleRequestID <- map["sample_request_id"]
    estimatedMinutes <- map["estimated_minutes_to_complete"]
    sampleRequestType <- map["sample_request_type"]
    urlString <- map["url"]
    urlParameters <- map["url_parameters"]
    estimatedEarnings <- map["estimated_earnings_msr"]
    disqualifyEarnings <- map["disqualify_earnings_msr"]
    imageURLString <- map["image_url"]
    disclaimer <- map["disclaimer"]
    startedCallbackURLString <- map["started_callback_url"]
    completedCallbackURLString <- map["completed_callback_url"]
    terminatedCallbackURLString <- map["terminated_callback_url"]
    userTerminatedCallbackURLString <- map["terminated_by_user_callback_url"]
    workShopSurveyCallbackURLString <- map["workshop_survey_data_url"]
    responseStatus <- map["response_status"]
    requestStatus <- map["request_status"]
    layoutType <- map["style.layout_type"]
    backgroundColorHexString <- map["style.background_color"]
    useWhiteText <- map["style.use_white_text"]
    seen <- map["seen"]
    opened <- map["opened"]
    declined <- map["declined"]
    completionSelector = "div#measure-survey-event-completed"
    completionV2Selector = "div#measure-survey-event-v2-completed"
    disqualificationV2Selector = "div#measure-survey-event-v2-disqualified"
    disqualificationSelector = "div#measure-survey-event-disqualified"
    inReviewSelector = "div#measure-survey-event-v2-review"
    eventMsg = "div#measure-survey-event-v2-msg"
    eventShowPayment = "div#measure-survey-event-v2-show-payment"
    terminatedSelector = "div#measure-survey-event-user-terminated"
    terminatedV2Selector = "div#measure-survey-event-v2-user-terminated"
    overQuotaSelector = "div#measure-survey-event-fullquota"
    overQuotaV2Selector = "div#measure-survey-event-v2-fullquota"
    expiryDate <- (map["expiry_date"], ISO8601DateTransform())
    appendIdentifiers <- map["append_identifiers"]
    appendProfileItems <- map["append_profile_items"]
    embeddedSurvey <- map["properties.survey"]
    isProfileMaintenanceSurvey <- map["properties.is_profile_maintenance_survey"]
    javaScriptSurveyMonitorEnabled <- map["javascript_survey_monitor_enabled"]
    javaScriptSurveyMonitorJavaScriptURLString <- map["javascript_survey_monitor_javascript_url"]
    javaScriptSurveyMonitorJavaScriptFunction <- map["javascript_survey_monitor_javascript_function"]
    storyTitle <- map["text_title"]
    storyDesc <- map["text_description"]
    offerHtml <- map["html"]
    action <- map["action"]
    linkURL <- map["link_url"]
    htmlURL <- map["html_url"]
    icon <- map["icon"]
    createdDate <- map["created_date"]
    updatedDate <- map["updated_date"]

  }
  
  public override func diffIdentifier() -> NSObjectProtocol {
    return offerID as NSObjectProtocol
  }
  
  public override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let rhs = object as? OfferItem else {
      return false
    }
    
    if title != rhs.title || itemDescription != rhs.itemDescription || offerType != rhs.offerType || offerTypeLabel != rhs.offerTypeLabel || communitySlug != rhs.communitySlug || sampleRequestID != rhs.sampleRequestID || estimatedMinutes != rhs.estimatedMinutes || urlString != rhs.urlString || urlParameters != rhs.urlParameters || estimatedEarnings != rhs.estimatedEarnings || disqualifyEarnings != rhs.disqualifyEarnings || imageURLString != rhs.imageURLString || startedCallbackURLString != rhs.startedCallbackURLString || completedCallbackURLString != rhs.completedCallbackURLString || terminatedCallbackURLString != rhs.terminatedCallbackURLString || userTerminatedCallbackURLString != rhs.userTerminatedCallbackURLString || workShopSurveyCallbackURLString != rhs.workShopSurveyCallbackURLString || responseStatus != rhs.responseStatus || requestStatus != rhs.requestStatus || layoutType != rhs.layoutType || backgroundColorHexString != rhs.backgroundColorHexString || useWhiteText != rhs.useWhiteText || seen != rhs.seen || opened != rhs.opened || declined != rhs.declined || completionV2Selector != rhs.completionV2Selector || completionSelector != rhs.completionSelector || disqualificationV2Selector != rhs.disqualificationV2Selector || disqualificationSelector != rhs.disqualificationSelector || overQuotaV2Selector != rhs.overQuotaV2Selector || overQuotaSelector != rhs.overQuotaSelector || eventMsg != rhs.eventMsg || eventShowPayment != rhs.eventShowPayment || inReviewSelector != rhs.inReviewSelector || terminatedV2Selector != rhs.terminatedV2Selector || terminatedSelector != rhs.terminatedSelector || expiryDate != rhs.expiryDate || appendIdentifiers != rhs.appendIdentifiers || appendProfileItems != rhs.appendProfileItems || embeddedSurvey != rhs.embeddedSurvey  || isProfileMaintenanceSurvey != rhs.isProfileMaintenanceSurvey || disclaimer != rhs.disclaimer {
      return false
    }
    
    return true
  }
}
