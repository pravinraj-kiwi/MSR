//
//  Constant+Messages.swift
//  Contributor
//
//  Created by KiwiTech on 9/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
// Below all localization done

struct CustomPopUpText {
    
 static let title = "Are you sure?"
 static let message = "If you delete your account you will permanently lose your profile and MSR points."
 static let detail = "You'll permanently lose your"
 static let bulletListArray = ["Profile", "MSR points"]
 static let deleteTitle = "Delete"
 static let cancelTitle = "Cancel"
}

struct JoinCommunity {
 static let joinCommunityConfirmTitle = "Join community"
 static let joinCommunityCancelTitle = "No, thanks"
 static let title = "Joining community..."
 static let error = "There was an error joining the community."
 static let alreadyMember = "You are already a member of the"
 static let community = "community."
 static let joinedSuccessfully = "You have successfully joined the"
}

struct DataTypeCell {
 static let readMore = "Read More"
 static let termsLinkText = "Terms & Conditions"
 static let privacyLinkText = "Privacy Policy"
}

struct SeeAllCell {
  static let lessText = "See Less"
  static let moreText = "See All"
}

struct ReadCell {
 static let sufixReadText = "Dynata and its clients will also use...Read More"
 static let initialReadText = "Dynata uses this data to match you to surveys. \(sufixReadText)"
 static let finalMidReadText = "Dynata and its clients will also use this profile data for market research analysis along with the survey data you provide"
 static let finalReadText = "Dynata uses this data to match you to surveys. \(finalMidReadText).\n\nDynata will independently control the data you share with them in the USA and is subject to their Privacy Policy and Terms & Conditions."
 static let initialPollfishReadText = "Pollfish uses this data to match you to surveys. Pollfish and its clients will also use...Read More"
 static let finalPollfishReadText = "Pollfish uses this data to match you to surveys. Pollfish and its clients will also use this profile data for market research analysis along with the survey data you provide.\n\nPollfish will independently control the data you share with them in the USA and is subject to their Privacy Policy and Terms & Conditions."
 static let initialKantarReadText = "Cint uses this data to match you to surveys. Cint and its clients will also use...Read More"
 static let finalKantarReadText = "Cint uses this data to match you to surveys. Cint and its clients will also use this profile data for market research analysis along with the survey data you provide.\n\nCint will independently control the data you share with them in the USA and is subject to their Privacy Policy and Terms & Conditions."
 static let initialPrecisionReadText = "Precision Sample uses this data to match you to surveys. Precision Sample and its clients will also use...Read More"
 static let finalPrecisionReadText = "Precision Sample uses this data to match you to surveys. Precision Sample and its clients will also use this profile data for market research analysis along with the survey data you provide.\n\nPrecision Sample will independently control the data you share with them in the USA and is subject to their Privacy Policy and Terms & Conditions."
}

struct DynataHeaderCell {
 static let dynataText =  "You’ll need to share this with Dynata so they can match you to more relevant surveys which means more chance to earn MSR. \n\nCheck out Dynata’s Privacy Policy and Terms & Conditions for more information about how your data is only used for market research."
 static let pollfishText =  "You’ll need to share this with Pollfish so they can match you to more relevant surveys which means more chance to earn MSR. \n\nCheck out Pollfish’s Privacy Policy and Terms & Conditions for more information about how your data is only used for market research."
 static let kantarText = "You’ll need to share this with Cint so they can match you to more relevant surveys which means more chance to earn MSR. \n\nCheck out Cint’s Privacy Policy and Terms & Conditions for more information about how your data is only used for market research."
 static let precisionText = "You’ll need to share this with Precision Sample so they can match you to more relevant surveys which means more chance to earn MSR. \n\nCheck out Precision’s Sample Privacy Policy and Terms & Conditions for more information about how your data is only used for market research."
}

struct MyDataAppsDetail {
 static let ProfileValidationsHeaderText = "Profile Validation"
 static let ProfileValidationsTitleText = "Strengthen your profile"
 static let ProfileValidationsDescriptionText = "Validating your profile makes your data more valuable. Buyers of data hate bots, and this verifies that you are real person."
 static let SurveyPartnersHeaderText = "Survey Partners"
 static let SurveyPartnersTitleText = "Want even more surveys?"
 static let SurveyPartnersDescriptionText = "Registration is very simple - just a few clicks. Once you're connected we'll start matching you to relevant surveys with our trusted partners."
}

struct AppTypeHeaderCell {
 static let linkedin = "Linkedin"
 static let facebook = "Facebook"
 static let dynata = "Share part of your Profile"
}

struct DynataJobHistoryCell {
 static let totalEarnedText = "Total Earned"
 static let titleText = "Job History"
 static let subTitleText = "Your earning history and job status with Dynata."
 static let subPollfishTitleText = "Your earning history and job status with Pollfish."
 static let subKantarTitleText = "Your earning history and job status with Cint."
 static let sharingTitleText = "Data Sharing"
 static let statusTitleText = "Status"
 static let dynataSubTitleText = "You’re currently connected and sharing profile data with Dynata."
 static let pollfishSubTitleText = "You’re currently connected and sharing profile data with Pollfish."
 static let kantarSubTitleText = "You’re currently connected and sharing profile data with Cint."
 static let precisionSubTitleText = "You’re currently connected and sharing profile data with Precision Sample."
}

struct DynataDetail {
 static let alertTitle = "Are you sure?"
 static let alertMessage = "If you disconnect you will no longer share data with this partner and will not receive any more offers from them."
 static let alertConfirmTitle = "Disconnect"
 static let alertCancelTitle = "Cancel"
 static let history = "History"
 static let noJobCompleted = "You have not completed any jobs."
}

struct ConnectingAppSuccess {
 static let linkedinTitle = "Linkedin Connected"
 static let linkedinSubTitle = "Your LinkedIn account is now connected to your Measure account."
 static let facebookTitle = "Facebook Connected"
 static let facebookSubTitle = "Your Facebook account is now connected to your Measure account."
 static let dynataTitle = "Good Job!"
 static let dynataSubTitle =  "You’re successfully registered with Dynata"
 static let dynataDescriptionText = "We will now regularly check with Dynata to find suvey jobs for you.\n\nAnd remember, you can opt-out of any job via the Dynata usage page found in My Data > Survey Partners > Dynata."
 static let pollfishTitle = "Good Job!"
 static let pollfishSubTitle =  "You’re successfully registered with Pollfish"
 static let pollfishDescriptionText = "We will now regularly check with Pollfish to find suvey jobs for you.\n\nAnd remember, you can opt-out of any job via the Pollfish usage page found in My Data > Survey Partners > Pollfish."
 static let kantarTitle = "Good Job!"
 static let kantarSubTitle = "You’re successfully registered with Cint"
 static let kantarDescriptionText = "We will now regularly check with Cint to find suvey jobs for you.\n\nAnd remember, you can opt-out of any job via the Cint usage page found in My Data > Survey Partners > Cint."
 static let precisionTitle = "Good Job!"
 static let precisionSubTitle =  "You’re successfully registered with Precision Sample"
 static let precisionDescriptionText = "We will now regularly check with Precision Sample to find suvey jobs for you.\n\nAnd remember, you can opt-out of any job via the Precision Sample usage page found in My Data > Survey Partners > Precision Sample."
 static let okTitle = "OK"
 static let doneTitle = "Done"
}

struct ConnectingAppFailure {
 static let linkedinTitle = "This LinkedIn account has already been used"
 static let linkedinSubTitle = "Each Linkedin account can only be connected to a single Measure account. This account is has already been claimed and cannot be used again."
 static let facebookTitle = "This Facebook account has already been used"
 static let facebookSubTitle = "Each Facebook account can only be connected to a single Measure account. This account is has already been claimed and cannot be used again."
}

struct ConnectAppType {
 static let dynataAlertTitle = "To connect, first complete the checklist in the Feed."
 static let okTitle = "OK"
}

struct NoNetworkToastMessage {
 static let alertMessage =  "Unable to complete your request at the moment"
}

struct Onboarding {
 static let onboardingTitle1 = "Video Tasks"
 static let onboardingText1 = "Video capture everyday apps for premium rewards."
 static let onboardingTitle2 = "Redeem Easily"
 static let onboardingText2 = "Earn points and redeem them for gift cards from 40+ top brands."
 static let onboardingTitle3 = "Data Control & Privacy"
 static let onboardingText3 = "You're in control. If you don't like the request, you can simply decline."
 static let onboardingTitle4 = "Earn while you chill"
 static let onboardingText4 = "Refer friends to the MSR app and you get a bonus 20% of everything they earn - It’s only fair!"
}

struct ToolTip {
  static let toolTipTitle1 = "👋 Welcome to My Data"
  static let toolTipDesc1 = "Before we begin, let’s see why this screen is important for earning."
  static let toolTipTitle2 = "💡 Build your profile"
  static let toolTipDesc2 = "Use the tools on My Data to build and manage your profile."
  static let toolTipTitle3 = "✨ Fill out profile surveys"
  static let toolTipDesc3 = "Your data is encrypted and used to match you to relevant jobs."
  static let toolTipTitle4 = "💰 Connect to other services"
  static let toolTipDesc4 = "Validate your profile and add different job types with these tools."
  static let actionButtonText = "Next"
  static let finishActionButtonText = "Got it!"
}

struct Cameraman {
  static let creationDate = "creationDate"
  static let mediaType = "public.movie"
  static let mediaImageType = "public.image"
  static let headerText = "Nearly done!"
  static let uploadHeaderText = "Oops!"
  static let uploadCompleted = "Uploaded"
  static let uploadFromPhoto = "Upload from photos"
  static let uploadTryAgain = "Try again"
  static let confirmUpload = "Confirm Upload"
  static let uploadFromFile = "Upload from file manager"
  static let testPassed = "Video Validation passed, click here to continue.\n\nSee Result"
}

struct CameramanError {
  static let the = "The"
  static let minumumSize =  "is under the minimum size of"
  static let kbTryAgain =  "KB. Please try again."
  static let underMinimumSize =  "The recording is under the minimum size of"
  static let mbTryAgain =  "MB. Please try again."
  static let overMaximumSize =  "The recording is over the maximum size of"
  static let maximumSize =  "is over the maximum size of"
}

struct CameramanValidation {
  static let mediaSize = "check_file_size"
  static let mediaRecency = "check_file_recency"
  static let mediaFileContent = "check_file_content"
  static let mediaFileContentv2 = "check_file_content_v2"
  static let mediaFileContentv3 = "check_file_content_v3"
  static let mediaFileContentv4 = "check_file_content_v4"
}

struct VideoUpload {
  static let noRecordingSaved = "Oops! Looks like no recordings are saved. Please try again."
  static let videoFileRecency = "The video was not recorded recently. Please try again with a new recording."
  static let subHeaderText = "While your video uploads please keep the MSR app open. This won’t take long."
  static let errorSubHeaderText = "Something’s not right. An unexpected error occurred when uploading the selected video."
  static let videoFileContentPrefix =  "The selected video does not include the required screens from"
  static let videoFileContentSufix =  "\n\nif you are sure the video contains the correct "
  static let videoFileContentEnd = "screens, click here to continue."
  static let videoFileTestUserContentEnd = "screens, click here to continue.\n\nSee Result"
}

struct ImageUpload {
  static let noImagesSaved = "Oops! Looks like no images are saved. Please try again."
  static let imageFileRecency = "The image was not created recently. Please try again with a newer image."
  static let subHeaderText = "While your image uploads please keep the MSR app open. This won’t take long."
  static let errorSubHeaderText = "Something’s not right. An unexpected error occurred when uploading the selected image."
}

struct FileUpload {
  static let noFileSaved = "Oops! Looks like no files are saved. Please try again."
  static let fileRecency = "The file was not created recently. Please try again with a newer file."
  static let subHeaderText = "While your file uploads please keep the MSR app open. This won’t take long."
  static let errorSubHeaderText = "Something’s not right. An unexpected error occurred when uploading the selected file."
}

struct UploadStatus {
  static let uploading = "uploading"
  static let uploaded = "uploaded"
}

struct ContentType {
  static let image = "image"
  static let video = "video"
  static let audio = "audio"
}
struct SurveyStatusText {
  static let jobComplete = "Job Complete!"
  static let disqualified = "Disqualified"
  static let overQuota = "Survey Full"
  static let inReview = "In Review"
  static let closedTxt = "Closed"
}

struct PhotoPermissionAlertText {
 static let title = ""
 static let message = "MSR requires access to your photo library. Please update settings and allow MSR to access All Photos."
 static let settings = "Update MSR Settings"
}

struct CompletedSurveyText {
  static let introTitle = "Your payment will arrive soon:"
  static let completedIntroTitle = "Thanks for completing the job!"
  static let welcomeInfoLabelText = "Nice work! You’ve added several new items to your profile."
  static let disqualifyInfoLabelText = "Your profile didn't match but you still qualify for a reward:"
  static let disqualifyLabelText = "Sorry, your profile didn't match the requirements."
  static let overQuotaLabelText = "Sorry, the request is already full."
  static let overQuotaInfoLabelText = "The request is already full, but you still qualify for a reward."
  static let inreviewIntroTitle = "We will review your answers and confirm your payment shortly."
  static let inreviewCompletedIntroTitle = "We will review your answers and confirm your payment shortly."
  static let jobCompletedHeaderText = "Job completed"
  static let inReviewHeaderText = "In Review"
  static let disqualifiedHeaderText = "Disqualified"
  static let overQuotaHeaderText = "Disqualified"
  static let profileAddedHeaderText = "Profile added"
  static let ratingLabelText = "How would you rate this job?"
  static let ratingItemLabelText = "Why?"
  static let surveyCompleteButonText = "Continue"
  static let surveyCancelInfoText = "Please rate and tell us why you exited the job."
  static let surveyCancelHeaderText = "Exited Job"
  static let closedHeaderText = "Closed"
    static let jobExitHeaderText = "Please select the main reason for exiting this Job:"


}

struct ConnectedAppCellText {
  static let connectedDataHeaderText = "Connected Data"
  static let connectedDataLabelText = "Connect to data sources and partners."
  static let connectedDataProfileText = "Profile Validation"
  static let connectedDataPartnerText = "Survey Partners"
  static let connectedLinkedinText = "Are you on LinkedIn?"
  static let connectedFacebookText = "Are you on facebook?"
  static let connectedYesButtonText =  "Yes"
  static let connectedNoButtonText =  "No"
}

struct Text {
    static let phoneValidated = "Phone validated"
    static let phoneValidatedMessage = "Your phone number is now connected to your Measure account."
    static let enterCode = "Enter the code"
    static let didntSendCode = "Didn’t receive a code"
    static let validate = "Validate"
    static let havingTrouble = "Having Trouble?"
    static let share = "SHARE"
    static let signIn = "Sign In".localized();
    static let jobType = "GET STARTED".localized();
    static let title = "Welcome to Measure".localized();
   static let detail = "Complete the checklist items below to earn your first MSR and start qualifying for surveys and other data jobs."
   static let here = "here"
   static let noncompressed = "non-compressed"
   static let compressed = "compressed"
   static let seeResult = "See Result"
   static let emailValidationText = "Validate your email"
    static let phoneNumberValidationText = "Validate your phone".localized()
    static let enterPhoneInfo = "Enter your phone number to receive a validation code via text message."
    static let countryText = "Country"
    static let phoneNumberText = "Phone Number"
   static let basicProfileSurveyValidationText = "Add basic profile data"
   static let locationValidationText = "Validate your location"
   static let locationValidationErrorText = "Your country of residence must match your current location."
   static let locationValidationSupportButtonText = "Contact support for help"
   static let phoneNumberValidationErrorText = "We were unable to validate your phone number."
   static let phoneNumberValidationSupportButtonText = "Contact support for help"
   static let startButtonTitleText = "START"
   static let firstTitleText = "1."
   static let secondTitleText = "2."
   static let thirdTitleText = "3."
   static let forthTitleText = "4."
    static let redeemButtonTitleText = "REDEEM"
   static let personalDetails = "Personal Details"
   static let changePassword = "Change Password"
   static let referFriend = "Refer a Friend"
   static let referFriendDesc = "& earn every time they do!"
    static let referInfo = "Every time your friends complete a task you will be rewarded 20% of what they earn as a bonus on us!"
    static let yourCode = "YOUR CODE"
   static let logout = "Logout"
   static let deleteAcount = "Delete Account"
   static let version = "App Version"
   static let terms = "Terms of Use"
   static let faq = "FAQ"
   static let privacy = "Privacy Policy"
   static let support = "Email Support"
   static let dumpProfile = "Dump Profile"
   static let deleteRandomProfileItems = "Delete Random Profile Items"
   static let runProfileMaintenance = "Run Profile Maintenance"
   static let runNetworkVote = "Run Network Vote"
   static let runDataInboxSupport = "Run Inbox Support"
   static let testACOnboard = "Test AC Onboard"
   static let testBroccoliOnboard = "Test Broccoli Onboard"
   static let testGamerOnboard = "Test Gamer Onboard"
   static let close = "Close"
   static let surveyPartnerText = " Survey Partners"
   static let editText = "Edit"
   static let didNotReceiveEmailButtonText = "I didn't receive an email"
   static let email = "Email"
   static let termsCondition = "Terms & Conditions"
    static let websiteDetail = "website for detail."
   static let resendEmail = "Resend email"
   static let send = "Sent!"
   static let setting = "Settings"
   static let skipNow = "Skip for now"
   static let cancel = "Cancel"
   static let ageNotMet = "Age Not Met"
   static let continueText = "Continue"
   static let redeeming = "Redeeming..."
   static let error = "Error"
   static let myDataText = " My Data"
   static let next = "Next"
   static let new = "NEW"
   static let basic = "basic"
   static let skipNext = "Skip to next"
   static let exitJob = "Exit Job?"
   static let ok = "OK"
   static let enterValue = "Enter Value"
   static let enterDate = "Enter Date"
   static let startJob = "Start job"
   static let supportText = "Support"
   static let navBack = " Back"
   static let or = "or"
   static let termOfService = "Terms of Service"
   static let accessibility = "Accessibility"
   static let contact = "Contact"
   static let privacyText = "Privacy"
   static let survey = "Survey"
   static let instructionLabelText = "Sign in to your account:"
   static let forgotPasswordButtonText = "Forgot your password?"
   static let signUpButtonStaticText = "New here? "
    static let signUpButtonLinkText = "Create an account".localized()
   static let signInFailed = "Sign-in failed"
   static let accountLabelText = "If you’re new to Measure, go ahead and create an account:"
   static let signUpButtonText = "Create a new account"
   static let orLabelText = "or"
   static let signInButtonText = "Sign in to existing account"
   static let termsText = "I am 16+ years of age and agree to the Terms & Conditions and Privacy Policy"
    static let redmeemPaypalText = "The provided email is registered with PayPal and I agree to the processing time set out above"
    static let websiteDetailPayPalText = "PayPal charges a fee for receiving payments, see their website for detail."
    static let paypalDesc = "After selecting an amount and completing the form below with your PayPal details, your redemption will be processed within 48 hours.\n\n Due to PayPal policies, once submitted this request cannot be undone or reimbursed. Please ensure your PayPal account email is correct."
   static let singnUpInstructionText = "First, enter some basic details:"
   static let sorry = "Sorry"
   static let sendLink = "Send link"
   static let yes = "Yes"
   static let generalError = "Sorry, something went wrong"
   static let of = "of"
   static let currentPaswordIncorect = "The current password you entered is incorrect"
   static let newPasswordMatch = "The new passwords you entered do not match"
   static let enterValueFor = "Please enter a value for"
   static let validationTimeOut = "validationTimeOut"
   static let createAccount = "Create an Account"
   static let logoutText = "Logout"
   static let appVersionText = "App Version "
   static let updateText = "Update"
   static let accountText = "Create Account"
   static let hintText = "If you have a referral code please enter it now."
   static let currentPasswordError = "Your current password is incorrect."
   static let moreText = "MORE"
    static let registeredEmail = "registered with PayPal"
    static let twitterAuthorized = "MSR successfully authorized"
    static let twitterInfo = "MSR will collect your tweets and tweets you liked."
    static let twitterFail = "MSR failed to authorize with Twitter"
    static let twitterInstruction = "Please review instructions and try again."
    static let finishText = "Finish"
    static let changeLanguage = "Select Preferred Language"
    static let redeemYourPoints = "Redeem your MSR points:"
    static let oopsText = "Oops! Something’s not right"
}

struct OfferItemCell {
  static let partnerSurveyText = "PARTNER SURVEY"
  static let profileSurveyText = "PROFILE SURVEY"
  static let completeTimeText = "1 minute to complete"
  static let communitySurveyText = "COMMUNITY SURVEY"
}
