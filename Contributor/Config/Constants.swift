//
//  Constants.swift
//  Contributor
//
//  Created by arvindh on 21/06/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    static let cornerRadius: CGFloat = 8
    static let cardCornerRadius: CGFloat = 3
    static let buttonCornerRadius: CGFloat = 2
    static let msrSymbol: String = "msr"
    static let jsonFileExtension = "json"
    static let buttonDisabledAlpha: CGFloat = 0.4
    static let walletTransactionsPageLimit: Int = 10
    static let profileStore: String = "profileStore"
    static let defaultLineSpacing: CGFloat = 1.2
    static let supportEmail: String = "support@measureprotocol.com"
    static let supportSubjectEmail: String = "Regarding "
    static let jobId: String = "Job ID"
    static let defaultValidationRewardMSR: Int = 50
    static let backgroundRefreshInterval: TimeInterval = 60 * 60 * 6
    static let PhoneNoCharLimit = 12
    static let jobHistoryCellHeight = 64
    static let primaryColor = Helper.getCommunityPrimaryColor()
    static let backgroundColor = Helper.getCommunityBackgroundColor()
    static let textFieldDefaultColor = UIColor.black.withAlphaComponent(0.08)
    static let inactiveColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    static let resendCode = "Resend code"
    static let sendCode = "Send code"
    static let contactSupport = "Contact support"
    static let okText = "OK"
    static let withText = "With "
    static let onboarding = "onboarding"
    static let loadingImage = "loadingImage"
    static let defaultCommunity = "measure"
    static let errorMessageValue = "message"
    static let errorMessageKey = "error"
    static let appStatusAvailable = "available"
    static let appStatusKey = "status"
    static let ratingType = "rating"
    static let stringType = "string"
    static let collapseNumberOfLines = 2
    static let precisionCollapseNumberOfLines = 3
    static let expandLabelNumberOfLines = 0
    static let estimatedRow: CGFloat = 150
    static let dynataBottomHeight: CGFloat = 120
    static let dynataResetHeight: CGFloat = 0
    static let dobPickerMaximumDate = -150
    static let dobPickerAgeLimit = -16
    static let appStatusURL = "https://storage.googleapis.com/maint.measureprotocol.com/status.json"
    static let maintananceRefreshButtonUrl = "app://refresh"
    static let finishRecordingButtonUrl = "app://job-engine/next"
    static let twitterButtonUrl = "app://job-engine/start-twitter-capture"
    static let nonProfileTempKey = "profileStore-nonProfileTemporaryValue"
    static let profileTempKey = "profileStore-temporaryValue"
    static let linkedin = "LinkedIn"
    static let facebook = "Facebook"
    static let dynata = "Dynata"
    static let pollfish = "Pollfish"
    static let kantar = "Cint"
    static let precisionSample = "Precision Sample"
    static let basic =  "basic"
    static let percentageDefault = "percentage"
    static let orientation = "orientation"
    static let trueText = "true"
    static let falseText = "false"
    static let headerViewNib = "HeaderView"
    static let sectionViewNib = "SectionView"
    static let framePath = "/extractedImages/"
    static let compressedPath = "/compressed/"
    static let appsFlyerDevKey: String = "XxBU2vXkQykKGND6dNVtMd"
    static let notifName = NSNotification.Name.updateButton
    static let notifErrorName = NSNotification.Name.errorUpdateButton
    static let appGroup = config.getAppGroup()
    static let supportJsonFile = "SupportFeatures"
    static let updateProfileValueJson = "updatedProfile"
    static let profileNewValues = "ProfileNewValues"
    static let exitJobReason = "ExitJobReason"
    static let kScreenKey = "VIEW_SCREEN"
    static let kOpenScreenKey = "SCREEN_NAME"
    static let onboardingDefaultTempate = "default"
    static let dummyFeedJsonFile = "DummyFeed"

    static var appleAppID: String {
        switch config.currentApp {
        case .staging2: return "1448161978"
        case .production: return "1450536498"
        case .broccoliStaging: return "1502658315"
        default: return ""
        }
    }
    static let payPalheaderViewNib = "PayPalFormHeader"
    static let transferUtilityAcceleratedKey = "USEast1S3TransferUtility"
    static let defaultCommunitySlug = "msr-community"
    static let previousVersion = "1.20.0.1"
    static let networkError = "Your phone is currenly offline. Please try again once network is available"
    static let jobSurveyAlert = "Your answers will not be saved."
    static let paidJobSurveyAlert = "This offer will no longer be available."
    static let profileStoreSurvey = "profileStoreSurvey"
    static var baseContributorURLString: String {
        switch config.currentApp {
        case .staging: return "http://contributor-dev-1.measureprotocol.com"
        case .staging2, .broccoliStaging: return "http://contributor-dev-2.measureprotocol.com"
        //    case .local: return "http://192.168.0.11:8001"  // John's laptop
        case .local, .broccoliLocal: return "http://10.0.0.40:8001"  // 26 Greenhaven
        //    case .local: return "http://192.168.0.10:8001"  // John's iMac
        //    case .local: return "http://10.4.4.169:8001"  // John's laptop in Tartu
        //    case .local: return "http://100.65.23.103:8001"  // John's laptop at Rotman
        //    case .local: return "http://10.0.1.60:8001"  // JBW's house
        //    case .local: return "http://172.27.5.86:8001"  // JBW's house
        //    case .local: return "http://192.168.1.103:8001" // PR's house
        //    case .local: return "http://10.0.0.171:8001" // San Carlos Airbnb
        default: return "https://contributor.measureprotocol.com"
        }
    }
    
    // env-specific API URLs used in various network code
    static var baseContributorAPIURL: URL {
        let baseURLString = Constants.baseContributorURLString
        let urlString = "\(baseURLString)/api"
        return URL(string: urlString)!
    }
    
    static var baseWorkshopURLString: String {
        switch config.currentApp {
        case .staging: return "http://workshop-dev-1.measureprotocol.com"
        case .staging2, .broccoliStaging: return "http://workshop-dev-2.measureprotocol.com"
        //    case .local: return "http://192.168.0.11:6004"  // John's laptop
        //    case .local: return "http://192.168.0.10:6004"  // John's iMac
        //    case .local: return "http://10.4.4.169:6004"  // John's laptop in Tartu
        //    case .local: return "http://100.65.23.103:6004"  // John's laptop at Rotman
        //    case .local: return "http://10.0.1.60:6004"  // JBW's house
        //    case .local: return "http://172.27.5.86:6004"  // JBW's house
        //    case .local: return "http://192.168.1.103:6004" // PR's house
        //    case .local: return "http://10.0.0.171:6004" // San Carlos Airbnb
        case .local, .broccoliLocal: return "http://10.0.0.40:6004" // 26 Greenhaven
        default: return "https://workshop.measureprotocol.com"
        }
    }
    
    // env-specific API URLs used in various network code
    static var baseWorkshopAPIURL: URL {
        let baseURLString = Constants.baseWorkshopURLString
        let urlString = "\(baseURLString)/api/v1"
        return URL(string: urlString)!
    }
    
    static var termsURL: URL {
        return URL(string: "\(baseContributorURLString)/app/terms")!
    }
    static var payPalTermsURL: URL {
        return URL(string: "https://www.paypal.com/")!
    }
    static var payPalWebSiteURL: URL {
        return URL(string: "https://www.paypal.com/uk/smarthelp/article/what-are-the-fees-to-use-paypal-faq690")!
    }
    static var privacyURL: URL {
        return URL(string: "\(baseContributorURLString)/app/privacy")!
    }
    
    static var faqURL: URL {
        return URL(string: "\(baseContributorURLString)/app/faq")!
    }
    
    static var dynataTermURL: URL {
        return URL(string: "http://web.peanutlabs.com/terms-of-service/")!
    }
    
    static var dynataPrivacyURL: URL {
        return URL(string: "http://web.peanutlabs.com/terms-of-service/privacy-policy/")!
    }
    
    static var pollfishTermURL: URL {
        return URL(string: "https://www.pollfish.com/terms/respondent")!
    }
    
    static var pollfishPrivacyURL: URL {
        return URL(string: "https://www.pollfish.com/terms/respondent")!
    }
    
    static var kantarTermURL: URL {
        return URL(string: "https://www.cint.com/panelist-terms")!
    }
    
    static var kantarPrivacyURL: URL {
        return URL(string: "https://www.cint.com/panelist-privacy-policy")!
    }
    
    static var precisionTermURL: URL {
        return URL(string: "https://precisionsample.com/t.htm")!
    }
    
    static var precisionPrivacyURL: URL {
        return URL(string: "https://precisionsample.com/p.htm")!
    }
    
    static var statusDownBaseURL: URL {
        return URL(string: "https://storage.googleapis.com/maint.measureprotocol.com/index.html")!
    }
    
    static var versionString: String {
        return "\(Bundle.main.releaseVersionNumber ?? "0.0").\(Bundle.main.buildVersionNumber ?? "0")"
    }
    
    static var appStoreURL: String {
        return "itms-apps://itunes.apple.com/us/app/msr/id1450536498"
    }
    static let twitterConsumerApiKeys: String =  "OAsayS17IZLfEa51bCf8obP5Z"
    static let twitterConsumerSecretApiKeys: String = "kZwnEoDTa1eW8bRD8Kpy7ESLNpYsadJhRUoZwbIpfoe0sVYb2h"
    
}

struct SuitDefaultName {
  static let userCommunity = "loggedInUserCommunityColor"
  static let userBalance = "loggedInUserBalanceMsr"
  static let userFirstName = "loggedInUserFirstName"
  static let accessToken = "accessTokenWidget"
}

enum Storyboard: String {
    case phoneNumberStoryboard = "PhoneNumberValidation"
    case otpValidationStoryboard = "OtpValidationViewController"
    case confirmationStoryboard = "ConfirmationViewController"
    case connectedAppStoryboard = "ConnectedApp"
    case cameramanSurveyStoryboard = "CameramanSurvey"
    case walletViewStoryboard = "WalletView"
    case settingViewStoryboard = "Settings"
    case referFriendStoryboard = "ReferFriend"
    case signUpViewStoryboard = "SignUp"
    case myAttributeStoryboard = "MyDataAttribute"
    case jobStoryboard = "Job"
    
}

enum StoryBoardIdentifier: String {
    case connectedAppDetailConnection = "ConnectedAppDetailController"
    case connectedAppSuccess = "ConnectedAppSuccessController"
    case connectedAppFailure = "ConnectedAppFailureController"
    case connectionDataType = "ConnectionDataTypeController"
    case dynataDetailController = "ConnectedDynataDetailController"
    case cameramanViewController = "CameramanViewController"
    case uploadCompletionViewController = "UploadCompletionViewController"
    case walletListViewController = "WalletListViewController"
    case walletDetailViewController = "WalletDetailViewController"
    case settingViewController = "SettingViewController"
    case personalEditViewController = "PersonalEditViewController"
    case changePasswordViewController = "ChangePasswordViewController"
    case referFriendViewController = "ReferViewController"
    case createAccountViewController = "CreateAccountViewController"
    case supportViewController = "SupportViewController"
    case referFriendSuccessController = "ReferFriendSuccessController"
    case giftWalletDetailController = "GiftWalletDetailController"
    case referWalletDetailController = "ReferWalletDetailController"
    case myAttributeController = "MyAttributeController"
    case exitJobViewController = "ExitJobViewController"
    case cameramanTestController = "CameramanTestController"
    case cameramanDetailTestController = "CameramanDetailTestController"
    case changeLanguageViewController = "ChangeLanguageViewController"
}

enum TagObject: String {
   case TAG_ALL = "all"
   case TAG_NETWORK_VOTE_GUID = "network_vote_guid"
}

enum ConnectedApp: String {
 case linkedin
 case facebook
 case dynata
 case pollfish
 case kantar
 case precision
}

enum ConnectedDataType: String {
 case profileValidation = "profile-validation"
 case surveyPartners = "survey-partners"
}

enum MeasureAppStatus: String {
  case available
  case unavailable
  case none
}

enum PopUpType {
  case communityType
  case deleteAccount
}

enum AppStatus: String {
  case connected = "connected"
  case notConnected = "not connected"
}

struct SampleRequestType {
  static let dataJob = "data"
  static let ExternalSurveyJob = "survey"
  static let profileJob = "profile"
  static let profileMaintenanceJob = "maint"
  static let connectedSetUpDynata = "setup-dynata"
  static let connectedSetUpPollfish = "setup-pollfish"
  static let kantarSetUp = "setup-kantar"
  static let precisionSetUp = "setup-precision"
  static let workShopSurvey = "workshop-survey"
}

enum DataInboxSupportType: String {
  case replace = "insert_or_replace"
  case merge = "insert_or_merge"
  case dataNotExist = "insert_if_does_not_exist"
  case extend = "insert_or_extend"
}

enum BlockPageType: String {
  case screenCapture = "screen_capture"
  case question = "question"
  case oAuthCapture = "oauth_capture"

}

enum ScreenCaptureType: String {
  case image
  case video
  case file
}

enum DateFormatType: String {
  case serverDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
  case shortDateFormat = "yyyy-MM-dd"
  case shortStyleFormat = "dd/MM/yyy"
  case normalDateWithTimeZoneFormat = "yyyy-MM-dd HH:mm:ss Z"
  case yearFormat = "yyyy"
  case normalDateFormat = "yyyy-MM-dd HH:mm:ss"
  case normalVideoDateFormat = "yyyyMMdd_HHmmss"
  case isoDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZZZZZ"
  case shortFormat = "MMM dd, yyyy"
}

enum TextFieldType {
  case email
  case firstName
  case lastName
  case dateOfBirth
  case password
  case referalCode
  case signUpNewPassword
  case signUpConfirmPassword
  case currentPassword
  case newPassword
  case confirmNewPassword
  case firstLastName
  case currentNewPassword
  case newConfirmPassword
  case currentConfirmPassword
  case currentNewConfirmPassword
  case confirmEmail
 case misMatchEmails
}

enum TextFieldTag: Int {
 case one = 1
 case two
 case three
}

enum ScreenType {
 case personalDetail
 case changePassword
 case createAccount
 case redeemScreen
}

enum VideoValidationType: String {
 case mediaFileContentv4 = "check_file_content_v4"
 case mediaFileContentv3 = "check_file_content_v3"
 case mediaFileContentv2 = "check_file_content_v2"
 case mediaFileContent = "check_file_content"
 case none
}
