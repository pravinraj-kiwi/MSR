//
//  API.swift
//  Contributor
//
//  Created by arvindh on 31/07/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import Foundation
import Moya
import DateToolsSwift
import SwiftyUserDefaults

enum ContributorAPI {
  case loginUser(AuthParams)
  case signup(SignupParams)
  case reloadCurrentUser
  case updateUser([User.CodingKeys: Any])
  case updatePassword(String, String)
  case getUserEmailValidationStatus
  case getUserStats
  case resendValidationEmail(String)
  case validateLocation
  case getExchangeRates(String)
  case updateDeviceToken(String)
  case deleteDeviceToken(String)
  case updateAppsFlyerIdentifier(String)
  case refreshAccessToken(String)
  case getOfferItems
  case getOffer(Int)
  case getContentItems
  case getWalletTransactions(page: Int)
  case getTransactionsDetail(transactionID: Int)
  case getPartnerDetail(connectApp: ConnectedApp, transactionID: Int)
  case getSurveyCategories
  case getProfileItemsForCategory(category: SurveyType)
  case getCategorySurvey(categoryRef: String, surveyRef: String)
  case getOtpSms(PhoneNumberParams)
  case verifyOtp(VerifyOtpParams)
  case addProfileEvent(source: String, itemRefs: [String])
  case markOfferItemsAsSeen(items: [OfferItem])
  case markOfferItemsAsOpened(items: [OfferItem])
  case markOfferItemsAsStarted(items: [OfferItem])
  case markOfferItemsAsCompleted(items: [OfferItem])
  case markOfferItemsAsDeclined(items: [OfferItem])
  case markContentItemsAsSeen(items: [ContentItem])
  case markContentItemsAsOpened(items: [ContentItem])
  case getGiftCards
  case getConnectedAppStatus
  case linkedinAdClicked(String)
  case linkedinConnect(LinkedinConnectParams)
  case facebookConnect(FacebookConnectParams)
  case getRedemptionAmounts(redeemType: String)
  case redeemGiftCard(redemptionType: PaymentType,
                        email:String? = nil,
                        GiftCardRedemptionOption)
  case redeemGenericReward(GenericRewardRedemptionParams)
  case rateSurvey(sampleRequestID: Int, rating: Int, ratingItems: [String])
  case getPendingQualifications(source: String)
  case ackQualification(sampleRequestID: Int, source: String)
  case resetPassword(email: String)
  case getCommunity(communitySlug: String)
  case joinCommunity(JoinCommunityParams)
  case resolvePostalCode(countryUID: String, postalCode: String)
  case createProfileMaintenanceJob(items: [ProfileItem])
  case updateProfileBackUp(String, String)
  case getProfileBackUpData
  case checkModifiedDate
  case deleteAccountRequest
  case partnerAppRequest(connectApp: ConnectedApp)
  case getDynataJobDetail(connectApp: ConnectedApp)
  case getDataInboxPackage
  case deletePackageProcessedData(packages: [DataInboxSupport])
  case uploadMedia(MediaParam)
  case logout(String)
  case supportEmail(String, String, Bool)
  case attrributedProfile(source: String)
  case attributeProfileList(source: String)
  case getTestUserStatus
  case getOnboardingTemplate(String)
  case markStoryItemsAsSeen(items: [StoryItem])
  case markStoryItemsAsOpened(items: [StoryItem])

}

extension ContributorAPI: TargetType, AccessTokenAuthorizable {
  var baseURL: URL {
    return Constants.baseContributorAPIURL
  }
  
  var path: String {
    switch self {
    case .loginUser(_): return "/v1/login"
    case .updateUser(_): return "/v1/settings"
    case .reloadCurrentUser: return "/v1/settings"
    case .updatePassword(_, _): return "/v1/password"
    case .getUserEmailValidationStatus: return "/v1/status/has-validated-email"
    case .getUserStats: return "/v1/stats"
    case .resendValidationEmail(_): return "/v1/resend-validation-email"
    case .validateLocation: return "/v1/validate/location"
    case .getExchangeRates(let currency): return "/v1/exchange-rates/\(currency)"
    case .signup(_): return "/v1/join"
    case .updateDeviceToken(_): return "/v1/device-tokens/update-token"
    case .deleteDeviceToken(_): return "/v1/device-tokens/delete-token"
    case .updateAppsFlyerIdentifier(_): return "/v1/appsflyer-identifiers/update-identifier"
    case .getOfferItems: return "/v1/feed"
    case .getOffer(let offerId): return "/v1/offers/\(offerId)"
    case .getContentItems: return "/v1/content"
    case .getWalletTransactions(_): return "/v2/transactions"
    case .getTransactionsDetail(let transactionId): return "/v2/transactions/\(transactionId)"
    case .getPartnerDetail(let appType, let transactionId): return "/v2/connected-apps/\(appType)/jobs/\(transactionId)"
    case .getSurveyCategories: return "/v1/profile/annotated-categories"
    case .getProfileItemsForCategory(let category): return "/v1/profile/categories/\(category.categoryRef)/items"
    case .getCategorySurvey(let categoryRef, let surveyRef): return "/v1/profile/categories/\(categoryRef)/surveys/\(surveyRef)"
    case .addProfileEvent(_, _): return "/v1/profile-events/track-new-items"
    case .markOfferItemsAsSeen(_): return "/v1/mark-offers-as-seen"
    case .markOfferItemsAsOpened(_): return "/v1/mark-offers-as-opened"
    case .markOfferItemsAsStarted(_): return "/v1/mark-offers-as-started"
    case .markOfferItemsAsCompleted(_): return "/v1/mark-offers-as-completed"
    case .markOfferItemsAsDeclined(_): return "/v1/mark-offers-as-declined"
    case .markContentItemsAsSeen(_): return "/v1/mark-content-as-seen"
    case .markContentItemsAsOpened(_): return "/v1/mark-content-as-opened"
    case .getGiftCards: return "/v1/gifts/catalog"
    case .redeemGiftCard(_,_, _): return "/v1/gift"
    case .redeemGenericReward(_): return "/v1/gift"
    case .getRedemptionAmounts(let redeemType): return "/v1/gifts/redeem-amounts"
    case .rateSurvey(_, _, _): return "/v1/rate-survey"
    case .getPendingQualifications(_): return "/v1/pending-qualifications"
    case .ackQualification(_, _): return "/v1/ack-qualification"
    case .resetPassword(_): return "/v1/request-password-reset"
    case .getCommunity(let communitySlug): return "/v1/communities/\(communitySlug)"
    case .joinCommunity(let params): return "/v1/communities/\(params.communitySlug)/join"
    case .resolvePostalCode(_, _): return "/v1/geo/resolve-postal-code"
    case .createProfileMaintenanceJob(_): return "/v1/offers/create-profile-maintenance-job"
    case .getOtpSms(_): return "/v1/validate/phone/send-code"
    case .verifyOtp(_): return "/v1/validate/phone/validate-code"
    case .getConnectedAppStatus: return "/v1/connected-apps"
    case .linkedinAdClicked(let adClickedType): return "/v1/connected-apps/\(adClickedType)/ad/clicked"
    case .linkedinConnect(_): return "/v1/connected-apps/linkedin/connect"
    case .facebookConnect(_): return "/v1/connected-apps/facebook/connect"
    case .updateProfileBackUp(_, _): return "/v1/profile-backup"
    case .getProfileBackUpData: return "/v1/profile-backup/all"
    case .checkModifiedDate: return "/v1/profile-backup/all/modified-on"
    case .deleteAccountRequest: return "/v1/delete-account-request"
    case .partnerAppRequest(let appType): return "/v1/connected-apps/\(appType)"
    case .getDynataJobDetail(let appType): return "/v2/connected-apps/\(appType)/jobs"
    case .getDataInboxPackage: return "/v1/data-packages"
    case .deletePackageProcessedData(_): return "/v1/mark-data-packages-as-processed"
    case .refreshAccessToken(_): return "/v1/refresh-token"
    case .uploadMedia(_): return "/v1/data-job/media-upload"
    case .logout(_): return "/v1/logout"
    case .supportEmail(_, _, _): return "/v1/support-email"
    case .attrributedProfile(_): return "/v1/profile/featured-items"
    case .attributeProfileList(_): return "/v1/profile/items-and-values"
    case .getTestUserStatus: return "/v1/status/is_test_user"
    case .getOnboardingTemplate(let template): return "/v1/onboard/\(template)"
    case .markStoryItemsAsSeen(_): return "/v1/mark-content-as-seen"
    case .markStoryItemsAsOpened(_): return "/v1/mark-content-as-opened"

    }
  }
  
  var method: Moya.Method {
    switch self {
    case .loginUser(_): return Method.post
    case .getExchangeRates(_): return Method.get
    case .updateUser(_): return Method.patch
    case .reloadCurrentUser: return Method.get
    case .updatePassword(_, _): return Method.put
    case .getUserEmailValidationStatus: return Method.get
    case .getUserStats: return Method.get
    case .resendValidationEmail: return Method.post
    case .validateLocation: return Method.post
    case .signup(_): return Method.post
    case .updateDeviceToken(_): return Method.post
    case .deleteDeviceToken(_): return Method.post
    case .updateAppsFlyerIdentifier(_): return Method.post
    case .getOfferItems: return Method.get
    case .getOffer(_): return Method.get
    case .getContentItems: return Method.get
    case .getWalletTransactions(_): return Method.get
    case .getTransactionsDetail(_): return Method.get
    case .getPartnerDetail(_, _): return Method.get
    case .getSurveyCategories: return Method.get
    case .getProfileItemsForCategory(_): return Method.get
    case .getCategorySurvey(_, _): return Method.get
    case .addProfileEvent(_, _): return Method.post
    case .markOfferItemsAsSeen(_): return Method.post
    case .markOfferItemsAsOpened(_): return Method.post
    case .markOfferItemsAsStarted(_): return Method.post
    case .markOfferItemsAsCompleted(_): return Method.post
    case .markOfferItemsAsDeclined(_): return Method.post
    case .markContentItemsAsSeen(_): return Method.post
    case .markContentItemsAsOpened(_): return Method.post
    case .getGiftCards: return Method.get
    case .redeemGiftCard(_, _,_): return Method.post
    case .redeemGenericReward(_): return Method.post
    case .getRedemptionAmounts: return Method.get
    case .rateSurvey(_, _, _): return Method.post
    case .getPendingQualifications(_): return Method.get
    case .ackQualification(_, _): return Method.post
    case .resetPassword(_): return Method.post
    case .getCommunity(_): return Method.get
    case .joinCommunity(_): return Method.post
    case .resolvePostalCode(_, _): return Method.post
    case .createProfileMaintenanceJob(_): return Method.post
    case .getOtpSms(_): return Method.post
    case .verifyOtp(_): return Method.post
    case .linkedinAdClicked(_): return Method.post
    case .getConnectedAppStatus: return Method.get
    case .linkedinConnect(_): return Method.post
    case .facebookConnect(_): return Method.post
    case .updateProfileBackUp(_, _): return Method.post
    case .getProfileBackUpData: return Method.get
    case .checkModifiedDate: return Method.get
    case .deleteAccountRequest: return Method.post
    case .partnerAppRequest(_): return Method.get
    case .getDynataJobDetail(_): return Method.get
    case .getDataInboxPackage: return Method.get
    case .deletePackageProcessedData(_): return Method.post
    case .refreshAccessToken(_): return Method.post
    case .uploadMedia(_): return Method.post
    case .logout(_): return Method.post
    case .supportEmail(_, _, _): return Method.post
    case .attrributedProfile: return Method.get
    case .attributeProfileList(_): return Method.get
    case .getTestUserStatus: return Method.get
    case .getOnboardingTemplate(_): return Method.get
    case .markStoryItemsAsSeen(_): return Method.post
    case .markStoryItemsAsOpened(_): return Method.post

    }
  }
  
  var validationType: ValidationType {
    return ValidationType.successAndRedirectCodes
  }
  
  var authorizationType: AuthorizationType {
    return .bearer
  }
  
  fileprivate var sampleDataKey: String {
    switch self {
    case .loginUser(_): return "getUser"
    case .getExchangeRates(_): return "getExchangeRates"
    case .updateUser(_): return "getUser"
    case .reloadCurrentUser: return "getUser"
    case .updatePassword(_, _): return ""
    case .getUserEmailValidationStatus: return "getEmailValidationStatus"
    case .getUserStats: return "getUserStats"
    case .resendValidationEmail: return ""
    case .validateLocation: return ""
    case .signup(_): return "getUser"
    case .updateDeviceToken(_): return ""
    case .deleteDeviceToken(_): return ""
    case .updateAppsFlyerIdentifier(_): return ""
    case .getOfferItems: return "getOffers"
    case .getOffer(_): return ""
    case .getContentItems: return "getContentItems"
    case .getWalletTransactions(_): return "getWalletTransactions"
    case .getTransactionsDetail(_): return ""
    case .getPartnerDetail(_, _): return ""
    case .getSurveyCategories: return "getSurveyCategories"
    case .getCategorySurvey(_): return "getSurvey"
    case .getProfileItemsForCategory(_): return "getProfileItemsForCategory"
    case .addProfileEvent(_, _): return ""
    case .markOfferItemsAsSeen(_): return ""
    case .markOfferItemsAsOpened(_): return ""
    case .markOfferItemsAsStarted(_): return ""
    case .markOfferItemsAsCompleted(_): return ""
    case .markOfferItemsAsDeclined(_): return ""
    case .markContentItemsAsSeen(_): return ""
    case .markContentItemsAsOpened(_): return ""
    case .getGiftCards: return "getGiftCatalog"
    case .redeemGiftCard(_,_, _): return ""
    case .getRedemptionAmounts: return "getRedeemAmounts"
    case .rateSurvey(_, _, _): return ""
    case .getPendingQualifications: return ""
    case .ackQualification(_, _): return ""
    case .resetPassword(_): return ""
    case .getCommunity(_): return "getCommunity"
    case .joinCommunity(_): return "getUser"
    case .redeemGenericReward(_): return ""
    case .resolvePostalCode(_, _): return ""
    case .createProfileMaintenanceJob(_): return ""
    case .getOtpSms(_): return ""
    case .verifyOtp(_): return ""
    case .getConnectedAppStatus: return ""
    case .linkedinAdClicked(_): return ""
    case .linkedinConnect(_): return ""
    case .facebookConnect(_): return ""
    case .updateProfileBackUp(_, _): return ""
    case .getProfileBackUpData: return ""
    case .checkModifiedDate: return ""
    case .deleteAccountRequest: return ""
    case .partnerAppRequest(_): return ""
    case .getDynataJobDetail(_): return ""
    case .getDataInboxPackage: return ""
    case .deletePackageProcessedData(_): return ""
    case .refreshAccessToken(_): return ""
    case .uploadMedia(_): return ""
    case .logout(_): return ""
    case .supportEmail(_, _, _): return ""
    case .attrributedProfile(_): return ""
    case .attributeProfileList(_): return ""
    case .getTestUserStatus: return ""
    case .getOnboardingTemplate(_): return ""
    case .markStoryItemsAsSeen(_): return ""
    case .markStoryItemsAsOpened(_): return ""

    }
  }
  
  var sampleData: Data {
    guard let asset = NSDataAsset(name: self.sampleDataKey) else {
      return "TODO".data(using: String.Encoding.utf8)!
    }
    
    switch self {
      
    case .updateUser(let userInfo):
      var json = try! JSONSerialization.jsonObject(with: asset.data, options: []) as? [String: AnyHashable] ?? [:]
      json["first_name"] = userInfo[User.CodingKeys.firstName] as? String
      json["last_name"] = userInfo[User.CodingKeys.lastName] as? String
      json["country"] = userInfo[User.CodingKeys.country] as? String
      json["currency"] = userInfo[User.CodingKeys.currency] as? String
      json["has_filled_basic_demos"] = userInfo[User.CodingKeys.hasFilledBasicDemos] as? Bool ?? false
      json["is_collecting_location"] = userInfo[User.CodingKeys.isCollectingLocation] as? Bool ?? false
      json["is_collecting_health"] = userInfo[User.CodingKeys.isCollectingHealth] as? Bool ?? false
      json["is_collecting_amazon"] = userInfo[User.CodingKeys.isCollectingAmazon] as? Bool ?? false
      json["is_collecting_spotify"] = userInfo[User.CodingKeys.isCollectingSpotify] as? Bool ?? false
      json["has_decided_notifications"] = userInfo[User.CodingKeys.hasDecidedNotifications] as? Bool ?? false
      json["is_receiving_notifications"] = userInfo[User.CodingKeys.isReceivingNotifications] as? Bool ?? false
      return try! JSONSerialization.data(withJSONObject: json, options: [])
    
    case .signup(let params):
      var json = try! JSONSerialization.jsonObject(with: asset.data, options: []) as? [String: AnyHashable] ?? [:]
      json["first_name"] = params.firstName
      json["last_name"] = params.lastName
      json["invite_code"] = params.inviteCode
      json["email"] = params.email
      json["timezone"] = params.timezone
      return try! JSONSerialization.data(withJSONObject: json, options: [])
    
    case .joinCommunity(let params):
      var user = try! JSONSerialization.jsonObject(with: asset.data, options: []) as? [String: Any] ?? [:]
      
      let communityData = NSDataAsset(name: "getCommunity")!.data
      var community = try! JSONSerialization.jsonObject(with: communityData, options: []) as? [String: Any?] ?? [:]
      community["slug"] = params.communitySlug
      community["community_user_id"] = params.communityUserID
      user["communities"] = [community]
      
      let json = ["user": user]
      return try! JSONSerialization.data(withJSONObject: json, options: [])
   
    default:
      return asset.data
    }
    
  }
  
  var task: Task {
    switch self {
      
    case .getUserEmailValidationStatus,.getUserStats,.getExchangeRates(_),.getSurveyCategories, .getProfileItemsForCategory(_),.getCategorySurvey(_, _),.getGiftCards, .getProfileBackUpData,.getCommunity(_),.getConnectedAppStatus,.checkModifiedDate,.linkedinAdClicked(_), .partnerAppRequest(_),.getDynataJobDetail(_),.reloadCurrentUser,.getOffer(_),.getTransactionsDetail(_), .getPartnerDetail(_,_),.getTestUserStatus,.getOnboardingTemplate(_):
      return Task.requestPlain
    case .getRedemptionAmounts(let source):
      let params: [String: Any] = [
        "redemption_type": source
      ]
      return Task.requestParameters(parameters: params, encoding: URLEncoding.default)
    case .loginUser(let param):
        let params: [String: Any] = [
            "username": param.email,
            "password": param.password
        ]
        return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
        
    case .updateUser(let newUserInfo):
      var params: [String: Any] = [:]
      for (k, v) in newUserInfo {
        params[k.rawValue] = v
      }      
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .updatePassword(let currentPassword, let password):
      let params: [String: Any] = [
        "current_password": currentPassword,
        "password": password
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .resendValidationEmail(let email):
      let params: [String: Any] = [
        "email": email
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .validateLocation:
      let params: [String: Any] = [:]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .getOfferItems:
      let params: [String: Any] = [
        "ordering": "-offer_date",
        "max_response_status": OfferItem.ResponseStatus.started.rawValue,
        "request_status": OfferItem.RequestStatus.open.rawValue,
        "declined": "false"
      ]
      return Task.requestParameters(parameters: params, encoding: URLEncoding.default)
    
    case .getContentItems:
      let params: [String: Any] = [
        "ordering": "-content_date"
      ]
      return Task.requestParameters(parameters: params, encoding: URLEncoding.default)
        
    case .getDataInboxPackage:
        let params: [String: Any] = [
              "status": "10"
        ]
    return Task.requestParameters(parameters: params, encoding: URLEncoding.default)
    
    case .markOfferItemsAsSeen(let items), .markOfferItemsAsOpened(let items), .markOfferItemsAsStarted(let items), .markOfferItemsAsCompleted(let items), .markOfferItemsAsDeclined(let items):
      let params: [String: Any] = [
        "offer_ids": items.compactMap { $0.offerID }
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .markContentItemsAsSeen(let items), .markContentItemsAsOpened(let items):
      let params: [String: Any] = [
        "content_ids": items.compactMap { $0.contentID }
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .signup(let params):
      return Task.requestParameters(parameters: params.asParams(), encoding: JSONEncoding.default)
    
    case .updateDeviceToken(let token):
      let params: [String: Any] = [
        "token": token,
        "platform": "ios",
        "version": "\(Bundle.main.releaseVersionNumber ?? "0.0.0").\(Bundle.main.buildVersionNumber ?? "0")"
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .deleteDeviceToken(let token):
      let params: [String: Any] = [
        "token": token
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)

    case .updateAppsFlyerIdentifier(let appsFlyerID):
      let params: [String: Any] = [
        "appsflyer_id": appsFlyerID,
        "platform": "ios",
        "version": Constants.versionString
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)

    case .getWalletTransactions(let page):
      let params: [String: Any] = [
        "ordering": "-transaction_date",
        "limit": Constants.walletTransactionsPageLimit,
        "offset": (page * Constants.walletTransactionsPageLimit)
      ]
      return Task.requestParameters(parameters: params, encoding: URLEncoding.default)
    
    case .redeemGiftCard(let redemptionType, let email, let redeemOption):
        let currency = UserManager.shared.wallet?.currency
        debugPrint("Currency is ", currency?.rawValue ?? "")
        var params: [String: Any] = [
            "msr_amount": redeemOption.msrValue,
            "lcy_amount": redeemOption.localFiatValue,
            "currency": currency?.rawValue ?? "",
        ]
        if redemptionType.rawValue == PaymentType.paypal.rawValue {
            params["paypal_email"] = email
            params["redemption_type"] = PaymentType.paypal.rawValue
            
        } else {
            params["redemption_type"] = PaymentType.giftCard.rawValue
            
        }
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .redeemGenericReward(let params):
      return Task.requestParameters(parameters: params.asParams(), encoding: JSONEncoding.default)
    
    case .addProfileEvent(let source, let itemRefs):
      let params: [String: Any] = [
        "source": source,
        "item_refs": itemRefs
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .rateSurvey(let sampleRequestID, let rating, let ratingItems):
      let params: [String: Any] = [
        "sample_request_id": sampleRequestID,
        "overall_rating": rating,
        "rating_items": ratingItems
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .ackQualification(let sampleRequestID, let source):
      let params: [String: Any] = [
        "sample_request_id": sampleRequestID,
        "source": source
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .attributeProfileList(let source):
      let params: [String: Any] = [
        "language": source
      ]
      return Task.requestParameters(parameters: params, encoding: URLEncoding.default)
    case .attrributedProfile(let source):
      let params: [String: Any] = [
        "language": source
      ]
      return Task.requestParameters(parameters: params, encoding: URLEncoding.default)
    case .getPendingQualifications(let source):
      let params: [String: Any] = [
        "pop_version": "2",
        "source": source
      ]
      return Task.requestParameters(parameters: params, encoding: URLEncoding.default)
    case .resetPassword(let email):
      let params: [String: Any] = [
        "email": email
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    
    case .joinCommunity(let params):
      return Task.requestParameters(parameters: params.asParams(), encoding: JSONEncoding.default)
    
    case .resolvePostalCode(let countryUID, let postalCode):
      let params: [String: Any] = [
        "country": countryUID,
        "postal_code": postalCode
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)

    case .createProfileMaintenanceJob(let items):
      let params: [String: Any] = [
        "item_refs": items.compactMap { $0.ref }
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
        
    case .getOtpSms(let params):
       return Task.requestParameters(parameters: params.asParams(), encoding: JSONEncoding.default)
    case .verifyOtp(let params):
        return Task.requestParameters(parameters: params.asParams(), encoding: JSONEncoding.default)
    case .linkedinConnect(let params):
        return Task.requestParameters(parameters: params.asParams(), encoding: JSONEncoding.default)
    case .facebookConnect(let params):
        return Task.requestParameters(parameters: params.asParams(), encoding: JSONEncoding.default)
    case .updateProfileBackUp(let encryptedDataString, let tag):
        let params: [String: Any] = [
            "tag": tag,
            "encrypted_profile": encryptedDataString
        ]
        return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    case .deleteAccountRequest:
         let params: [String: Any] = [:]
         return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    case .deletePackageProcessedData(let package):
        let params: [String: Any] = [
            "data_package_ids": package.compactMap { $0.dataInboxId }
        ]
        return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    case .uploadMedia(let params):
        return Task.requestParameters(parameters: params.asParams(), encoding: JSONEncoding.default)
    case .logout(let accessToken):
        let params: [String: Any] = [
            "token": accessToken
        ]
        return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    case .refreshAccessToken(let logInRefreshToken):
        let params: [String: Any] = [
            "refresh": logInRefreshToken
        ]
        return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    case .supportEmail(let concern, let message, let shouldSendEmailCopy):
        let params: [String: Any] = [
            "subject": concern,
            "body": message,
            "send_copy_to_user": shouldSendEmailCopy
        ]
        return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    case .markStoryItemsAsSeen(let items), .markStoryItemsAsOpened(let items):
      let params: [String: Any] = [
        "content_ids": items.compactMap { $0.id }
      ]
      return Task.requestParameters(parameters: params, encoding: JSONEncoding.default)
    }
    
  }
  
  var headers: [String: String]? {
    let modelName = UIDevice.modelName
    let iosVersion = UIDevice.current.systemVersion
    if UserManager.shared.isLoggedIn {
        let accessToken = "Bearer \(Defaults[.loggedInUserAccessToken] ?? "")"
        return ["Authorization": accessToken, "platform": "ios",
                "version": Constants.versionString,
                "edition": config.getAppCommunity(),
                "Accept-Language": AppLanguageManager.shared.getLanguage() ?? "en",
                "device_model": modelName,
                "device_os_version": iosVersion]
    } else {
        return ["platform": "ios",
                "version": Constants.versionString,
                "edition": config.getAppCommunity(),
                "Accept-Language": AppLanguageManager.shared.getLanguage() ?? "en",
                "device_model": modelName,
                "device_os_version": iosVersion]
    }
  }
}
