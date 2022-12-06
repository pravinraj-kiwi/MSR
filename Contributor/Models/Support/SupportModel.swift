//
//  SupportModel.swift
//  Contributor
//
//  Created by KiwiTech on 10/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import IGListKit
import ObjectMapper
struct ResponseData: Decodable {
    var support: [SupportModel]
}

struct SupportModel: Decodable {
    var supportName: String
    var supportImage: String
    var supportURL: String
}
// MARK: - Welcome
struct Stories: Codable {
  //  let stories: [Story]?
    let feed: [FeedList]?
}

// MARK: - Feed
struct FeedList: Codable {
    let id: Int?
    let guid, itemType: String?
    let priority: Int?
    let item: FeedItemInfo?
    let createdDate, updatedDate: String?
    let properties: Properties?

    enum CodingKeys: String, CodingKey {
        case id, guid
        case itemType = "item_type"
        case priority, item
        case createdDate = "created_date"
        case updatedDate = "updated_date"
        case properties
    }
}

// MARK: - FeedItem
struct FeedItemInfo: Codable {
    let id: Int?
    let guid: String?
    let user, offerType: Int?
    let offerTypeLabel: String?
    let sampleRequestID: Int?
    let sampleRequestType: String?
    let estimatedEarningsMsr, estimatedEarningsLcy, estimatedMinutesToComplete, disqualifyEarningsMsr: Double?
    let disqualifyEarningsLcy: Double?
    let dataPaymentTotalStr, dataPaymentIntervalStr, dataPeriodStr, dataPeriodDays: String?
    let paidEarningsMsr: Int?
    let title, itemDescription: String?
    let url: String?
    let urlParameters: String?
    let startedCallbackURL, completedCallbackURL, terminatedCallbackURL, terminatedByUserCallbackURL: String?
    let workshopSurveyDataURL: String?
    let imageURL: String?
    let style: Style?
    let appendIdentifiers, appendProfileItems, seen, opened: Bool?
    let declined: Bool?
    let responseStatus, requestStatus: Int?
    let offerDate: String?
    let expiryDate: String?
    let updatedDate: String?
    let properties: Properties?
    let startedOn: String?
    let disclaimer: String?
    let javascriptSurveyMonitorEnabled, javascriptSurveyMonitorJavascriptURL: Bool?
    let javascriptSurveyMonitorJavascriptFunction: String?
    let itemType: String?

    enum CodingKeys: String, CodingKey {
        case id, guid, user
        case offerType = "offer_type"
        case offerTypeLabel = "offer_type_label"
        case sampleRequestID = "sample_request_id"
        case sampleRequestType = "sample_request_type"
        case estimatedEarningsMsr = "estimated_earnings_msr"
        case estimatedEarningsLcy = "estimated_earnings_lcy"
        case estimatedMinutesToComplete = "estimated_minutes_to_complete"
        case disqualifyEarningsMsr = "disqualify_earnings_msr"
        case disqualifyEarningsLcy = "disqualify_earnings_lcy"
        case dataPaymentTotalStr = "data_payment_total_str"
        case dataPaymentIntervalStr = "data_payment_interval_str"
        case dataPeriodStr = "data_period_str"
        case dataPeriodDays = "data_period_days"
        case paidEarningsMsr = "paid_earnings_msr"
        case title
        case itemDescription = "description"
        case url
        case urlParameters = "url_parameters"
        case startedCallbackURL = "started_callback_url"
        case completedCallbackURL = "completed_callback_url"
        case terminatedCallbackURL = "terminated_callback_url"
        case terminatedByUserCallbackURL = "terminated_by_user_callback_url"
        case workshopSurveyDataURL = "workshop_survey_data_url"
        case imageURL = "image_url"
        case style
        case appendIdentifiers = "append_identifiers"
        case appendProfileItems = "append_profile_items"
        case seen, opened, declined
        case responseStatus = "response_status"
        case requestStatus = "request_status"
        case offerDate = "offer_date"
        case expiryDate = "expiry_date"
        case updatedDate = "updated_date"
        case properties
        case startedOn = "started_on"
        case disclaimer
        case javascriptSurveyMonitorEnabled = "javascript_survey_monitor_enabled"
        case javascriptSurveyMonitorJavascriptURL = "javascript_survey_monitor_javascript_url"
        case javascriptSurveyMonitorJavascriptFunction = "javascript_survey_monitor_javascript_function"
        case itemType = "item_type"
    }
}

// MARK: - Properties
//struct Properties: Codable {
//}

// MARK: - Style
struct Style: Codable {
    let layoutType: String?
    let useWhiteText: Bool?
    let backgroundColor: String?

    enum CodingKeys: String, CodingKey {
        case layoutType = "layout_type"
        case useWhiteText = "use_white_text"
        case backgroundColor = "background_color"
    }
}
class StoryWithContentItem: NSObject {
  var item : Story?
  
  init(item: Story) {
    self.item = item
    super.init()
  }
}

// MARK: - Story
/*class Story:  Codable {
    
    let id: Int?
    let guid, itemType: String?
    let priority: Int?
    var item: StoryItemInfo?
    let createdDate, updatedDate: String?
    let properties: Properties?
    enum CodingKeys: String, CodingKey {
        case id, guid
        case itemType = "item_type"
        case priority, item
        case createdDate = "created_date"
        case updatedDate = "updated_date"
        case properties
    }
}

// MARK: - StoryItem
struct StoryItemInfo: Codable {
    let id: Int?
    let guid, itemType, textTitle, textDescription: String?
    let html, htmlURL, icon: String?
    var seen, userSpecific: Bool?
    let links: [Link]?
    let createdDate, updatedDate: String?
    let properties: Properties?
    var isSelected: Bool?

    enum CodingKeys: String, CodingKey {
        case id, guid
        case itemType = "item_type"
        case textTitle = "text_title"
        case textDescription = "text_description"
        case html
        case htmlURL = "html_url"
        case icon, seen
        case userSpecific = "user_specific"
        case links
        case createdDate = "created_date"
        case updatedDate = "updated_date"
        case properties
        case isSelected
    }
}
// MARK: - Link
struct Link: Codable {
    let text, action, linkURL, descriptionStyle: String?

    enum CodingKeys: String, CodingKey {
        case text, action
        case linkURL = "link_url"
        case descriptionStyle = "description_style"
    }
}
*/
