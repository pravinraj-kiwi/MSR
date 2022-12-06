//
//  StringConstant.swift
//  Contributor
//
//  Created by Kiwitech on 14/05/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

struct FeedViewText {
static let job = "Feed"
static let news = "News"
    static let urlError = "Sorry, this item has an invalid URL and can't be opened.".localized()
static let urlTitleError = "Bad URL".localized()
}

struct TabName {
static let feed = "Feed"
static let myData = "My Data"
static let wallet = "Wallet"
}

struct WalletCell {
    static let currentBalanceText = "Your current balance:".localized()
static let redeemButtonText = "Redeem"
}

struct TextFieldText {
static let invalidEmail = "Please enter a valid email address".localized()
static let invalidDate = "Please enter a valid date".localized()
static let invalidValue = "Please enter a valid value".localized()
}

struct OtpValidationText {
    static let otpNotSendMessage = "Sorry, failed to resend code. Try again.".localized()
    static let validationCodeInCorrect = "Validation code is incorrect.".localized()
    static let validationCodeSend = "Validation code resent.".localized()
    static let invalidErrorMessage = "Sorry, something went wrong.".localized()
    static let phoneLabelText = "We sent a six-digit code to you via text message on ".localized()
}

struct PhoneValidationText {
    static let phoneNumberValidation = "Sorry, PhoneNumber cannot be blank.".localized()
    static let invalidNumber = "Invalid phone number for selected country.".localized()
    static let usedNumber = "Phone number is being used by another user".localized()
}

struct EmailValidationText {
    static let resentTitleText = "Resent, check your inbox".localized()
    static let resentSubTitleText = "I still didn't receive anything".localized()
}

struct NotificationPermissionAlertText {
    static let title = "Allow Measure".localized()
    static let message = "Please grant Measure permission to send you notifications.".localized()
    static let settings = "Open Settings".localized()
}

struct RedeemText {
    static let title = "Redeeming for AC Points...".localized()
    static let error = "There was an error redeeming for".localized()
    static let redeemTryAgain = "Please try again later.".localized()
}

struct MyDataText {
static let connectApps = "Connect Apps"
static let conectedData = "Connected Data"
    static let connectText = "Connect"
    static let disconnectText = "Disconnect"
    static let noThanksText = "No Thanks"

}

struct SurveyText {
static let profileSurvey = "Profile Surveys"
static let profileSurveyMessge = "Add demographic data to your profile."
static let externalSurveyTitleText = "Partner survey"
static let internalSurveyTitleText = "Profile survey"
static let externalSurveyTypeText = "Partner surveys involve completing a survey for a third-party survey partner in exchange for a MSR reward."
static let internalSurveyTypeText = "Profile survey jobs involve completing a profile survey for a MSR reward."
static let dataCategorySurveyTypeText = "Profile surveys are short surveys that build your profile and help you qualify for paid jobs."
static let externalJobPrivacyText = "For this job, the third-party survey partner will receive all survey data that you enter as well as six points of profile data: age, gender, education level, income, country and employment.\n\nPlease be advised that each survey partner requires you to agree to their terms and conditions and privacy notice."
static let internalJobPrivacyText = "For this job no data will leave your device or be shared with third-parties."
static let profileTitleText = "Basic Demographics"
static let profileDetailText = "Enter basic information about yourself in this survey to start building your profile. Your profile stays on your device and allows you to qualify for paid surveys and other data jobs."
static let communityJobTitleText = "Community survey"
static let communityJobTypeText = "Community survey jobs involve completing a survey provided for a community in exchange for a MSR reward."
static let communityJobPrivacyText = "For this job, in addition to the survey data you provide, the survey partner will receive six points of profile data: age, gender, education level, income, country and employment."
static let declineOffer = "Decline offer"
static let dataPrivacy = "Data sharing and privacy"
static let profileSurveyText = "PROFILE SURVEY"
static let partnerSurvey = "PARTNER SURVEY"
static let expiresIn = "Expires in "
static let minuteComplete = "1 minute to complete"
static let complete = "minutes to complete"
static let communitySurvey = "COMMUNITY SURVEY"
static let expires = "Expires in"
}

struct PositiveRatingText {
    static let understand = "Easy to understand".localized()
static let simple = "Simple".localized()
static let fairPayment = "Fair payment".localized()
static let efficient = "Short and efficient".localized()
static let content = "Interesting content".localized()
static let fun = "Fun".localized()
static let fastLoading = "Fast-loading".localized()
static let design = "Great design".localized()
}

struct NegativeRatingText {
static let tooLong = "Too long".localized()
static let tooSmall = "Payment too small".localized()
static let slowLoading = "Slow loading".localized()
static let boring = "Boring".localized()
static let complicated = "Complicated".localized()
static let mobileFriendly = "Not mobile-friendly".localized()
static let questions = "Repetitive questions".localized()
static let errors = "Errors".localized()
}

struct PlaceholderText {
static let firstName = "First name".localized()
static let lastName = "Last name".localized()
static let email = "Email".localized()
static let dob = "Date of birth".localized()
static let password = "Password".localized()
static let passwordAgain = "Password, again".localized()
static let currentPassword = "Current Password".localized()
static let newPassword = "New Password".localized()
static let confirmPassword = "Confirm Password".localized()
static let referalCode = "Referral Code".localized()
    static let paypalEmail = "PayPal Email".localized()
    static let confirmPayPalEmail = "Confirm PayPal Email".localized()
}

struct PlaceholderTextValue {
    static let firstName = "John".localized()
    static let lastName = "Doe".localized()
    static let email = "Email".localized()
    static let dob = "DD / MM / YYYY".localized()
    static let password = "••••••••••••".localized()
    static let currentPassword = "••••••••••••".localized()
    static let newPassword = "••••••••••••".localized()
    static let confirmPassword = "••••••••••••".localized()
    static let referalCode = "Optional".localized()
    static let paypalEmail = "example@email.com".localized()
}

struct SignUpViewText {
static let accountError = "It looks like you already have an account. Why don't you try logging in?".localized()
static let requestError = "Unable to complete your request at the moment".localized()
static let validEmail = "Please enter a valid email address".localized()
static let passwordMatch = "The passwords must match".localized()
static let validDate = "Please enter a valid date".localized()
}

struct AppIntroText {
static let waterMark = "Powered by Measure".localized()
static let getStarted = "GET STARTED".localized()
}

struct WalletViewText {
static let history = "History".localized()
static let noAccountAlertTitle = "Not Available Yet".localized()
static let noAccountAlertMessage = "Redemption of MSR is not available until you've finished setting up your account.".localized()
static let fraudAlertTitle = "Account on Hold".localized()
static let fraudAlertMessage = "Redemption of MSR is not available while your account is on hold.".localized()
    static let reportAnIssue = "Report an issue"
}

struct GiftCardViewText {
static let redeemBalance = "Redeem Balance".localized()
static let currentBalance = "Current balance:".localized()
static let redeemAmount = "Choose an amount to redeem:".localized()
static let minBalance = "Minimum balance of".localized()
static let requireRedeem = "required to redeem. \n \n".localized()
static let clickedAmount = "After clicking an amount, you'll receive an email that allows you to select from the gift cards below.".localized()
static let title = "Gift Card".localized()
static let successRedeem = "Congratulations! You redeemed".localized()
static let referHeaderText = "Thank you! Enjoy a 20% bonus".localized()
    static let referFriendHeadingText = "Want more MSR points?".localized()
    static let referFriendSubHeadingText = "Earn 20% of what your friends earn".localized()
}

struct SettingViewText {
    static let account = "Settings".localized()
static let app = "App".localized()
static let testing = "Testing".localized()
static let title = "Settings".localized()
static let personalDetail = "Personal Details".localized()
static let changePassword = "Change Password".localized()
static let editDetail = "Edit Details".localized()
}

struct ReferFriendViewText {
    static let titleText = "Refer a friend".localized()
    static let downloadText = "Download the MSR app and get paid to do data jobs on your phone.".localized()
    static let actionButtonText = "INVITE".localized()
    static let referMessage =  "MSR for every friend that installs the MSR app and completes the setup of their account.".localized()
    static let earn = "Earn".localized()
    static let remainingInvite = "invitations remaining".localized()
    static let shareText = "I earn with the MSR app by sharing data and completing surveys.".localized()
    static let sharePreixText = " Use my code".localized()
    static let shareSuffixText = "or my link to DOUBLE your welcome bonus! ".localized()
    static let terms = "Subject to MSR’s Terms and Conditions"
    static let linkText = "Terms and Conditions"
    static let copiedAlert = "Your invite code has been copied to clipboard.".localized()
    static let shareSubjectText = "Download MSR App".localized()
}

struct WalletTransactionText {
    static let todayText = "Today".localized()
    static let yesterdayText = "Yesterday".localized()
    static let thisMonthText = "This Month".localized()
}

struct PartnerText {
static let dynataText = "Today"
static let pollfishText = "Yesterday"
static let cintText = "This Month"
}

enum TransactionListDisplay {
case normal
case danger
case primary
case zero

var display: String {
switch self {
case .normal: return "normal"
case .danger: return "danger"
case .primary: return "primary"
case .zero: return "0 MSR"
}
}
}

enum CameramanValidationType {
case mediaSize
case mediaRecency
case mediaContent
}

struct MediaType {
static let videoExtension = "MOV"
static let imageExtension = "PNG"
}

struct FeedEmptyOffer {
    static let jobCompletedText = "All jobs completed".localized()
    static let searchingText = "We're searching the galaxy for more.".localized()
    static let findMoreText = "Nice work, we'll find some more.".localized()
    static let trackMoreText = "We're tracking down some more.".localized()
    static let lookingMoreText = "Take five, we're looking for more.".localized()
    static let niceWorkText = "Nice work!".localized()
    static let searchingJobText = "Your account is ready — we'll start searching for jobs that match your profile.".localized()
}

struct MyAttributes {
  static let attributesText = "Attributes"
  static let categoriesText = "Categories"
  static let extraProfileItems = [
    "country_of_residence",
    "us_state_of_residence",
    "us_city_of_residence",
    "us_county_of_residence",
    "us_zip_code_of_residence",
    "us_zip_code_of_residence_string",
    "us_zip_code_of_residence_as_value",
    "us_zip_code_full_of_residence_as_value",
    "au_state_of_residence",
    "au_city_of_residence",
    "au_county_of_residence",
    "au_postal_code_of_residence",
    "au_postal_code_of_residence_string",
    "au_zip_code_of_residence_as_value",
    "au_zip_code_full_of_residence_as_value",
    "uk_region_of_residence",
    "uk_town_of_residence",
    "uk_postal_code_of_residence_string",
    "uk_zip_code_of_residence_as_value",
    "uk_zip_code_full_of_residence_as_value",
    "ca_province_of_residence",
    "ca_city_of_residence",
    "ca_postal_code_of_residence",
    "ca_postal_code_of_residence_string",
    "ca_zip_code_of_residence_as_value",
    "ca_zip_code_full_of_residence_as_value",
    "dob"]
}

class StaticHtml {
 func surveyStartPageHtml() -> String {
  return """
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      <style type="text/css">
      @font-face { font-family: 'Bold'; src: url('font/proximanova_bold.ttf');}
      @font-face { font-family: 'Regular'; src: url('font/proximanova_regular.ttf');}
    </style>
    </head>
    <body style="background-color:#F3F3F3;
    margin-top: 20px;
    margin-right: 20px;
    margin-bottom: 40px;
    margin-left: 20px;">
    <h4 style="margin-bottom: 5pt;font-family='Bold';font-size: 14px;">Sharing and privacy</h4>
    <p style="color: grey;font-family='Regular';font-size: 14px;margin-top: 20px;">
    All the data you share by completing this job is subject to Measure’s <a href="/app/privacy">privacy policy</a> and <a href="/app/terms">terms of use</a>.
    </p>
    </body></html>
    """
  }
}
