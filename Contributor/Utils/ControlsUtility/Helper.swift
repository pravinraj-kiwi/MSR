//
//  Helper.swift
//  Contributor
//
//  Created by arvindh on 16/04/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import PhoneNumberKit
import Alamofire
import Moya
import SwiftyUserDefaults
import Toast_Swift

class Helper: NSObject {
 static let phoneNumberKit = PhoneNumberKit()

 static func profileFileURL(user: User) -> URL {
    var url = URL(fileURLWithPath: NSTemporaryDirectory())
    url.appendPathComponent("profile-\(user.userID!).measure")
    return url
 }

 static func profileFilePath(user: User) -> String {
    return profileFileURL(user: user).path
 }
    
 static func getCommunityPrimaryColor() -> UIColor {
    guard let community = UserManager.shared.currentCommunity,
          let colors = community.colors else {
        return UIColor()
    }
    return colors.primary
 }
    
 static func getCommunityBackgroundColor() -> UIColor {
    guard let community = UserManager.shared.currentCommunity,
          let colors = community.colors else {
           return UIColor()
    }
    return colors.background
 }
    
 static func validatePhoneNumberWithCountryCode(_ phoneNumber: String) -> String {
    do {
        let number = try phoneNumberKit.parse(phoneNumber)
        let region = phoneNumberKit.getRegionCode(of: number)
        _ = try phoneNumberKit.parse(phoneNumber, withRegion: region ?? "US",
                                     ignoreType: true)
        let formattedNumber = phoneNumberKit.format(number, toType: .e164)
        return formattedNumber
    }
    catch {
        print("Generic parser error")
    }
    return ""
 }
    
 static func isNumberValidWithSelectedCountryCode(_ phoneNumber: String) -> Bool {
    let phoneNumberWithCountryCode = validatePhoneNumberWithCountryCode(phoneNumber)
    return phoneNumberKit.isValidPhoneNumber(phoneNumberWithCountryCode)
 }
    
 static func contactSupportTeam() {
    let email = Constants.supportEmail
    let url = URL(string: "mailto:\(email)")
    UIApplication.shared.open(url!)
 }
    
 static func updateAttributtedText(_ text: String) -> NSMutableAttributedString {
    let formattedString = text.withAttributes([
        .textColor(Constants.primaryColor),
        .font(Font.regular.of(size: 13)),
        .underlineStyle(NSUnderlineStyle.single),
        .underlineColor(Constants.primaryColor)
    ])
    return formattedString
 }
    
 static func showNoNetworkAlert(controller: UIViewController,
                                position: ToastPosition = ToastPosition.bottom) {
    let toaster = Toaster(view: controller.view)
    toaster.toast(message: Constants.networkError, position: position)
 }
    
  static func clickToOpenUrl(_ url: URL, controller: UIViewController,
                             presentationStyle: UIModalPresentationStyle = .pageSheet,
                             shouldPresent: Bool = false, isFromSupport: Bool = false,
                             title: String = "", isFromSurveyStartPage: Bool = false) {
    let webContentViewController = WebContentViewController()
    webContentViewController.startURL = url
    webContentViewController.webContentDelegate = controller as? WebContentDelegate
    webContentViewController.isFromSupport = isFromSupport
    webContentViewController.setTitle(title)
    webContentViewController.isFromSurveyStartPage = isFromSurveyStartPage
    webContentViewController.modalPresentationStyle = presentationStyle
    if shouldPresent {
        controller.present(webContentViewController, animated: true, completion: nil)
    } else {
        controller.show(webContentViewController, sender: controller)
    }
 }
    
 static func clickToOpenHtmlPage(baseUrl: URL, htmlString: String,
                                 controller: UIViewController,
                                 presentationStyle: UIModalPresentationStyle = .pageSheet,
                                 shouldPresent: Bool = false) {
    let webContentViewController = WebContentViewController()
    webContentViewController.startHTMLString = htmlString
    webContentViewController.startBaseURL = baseUrl
    webContentViewController.modalPresentationStyle = presentationStyle
    webContentViewController.webContentDelegate = controller as? WebContentDelegate
    if shouldPresent {
        controller.present(webContentViewController, animated: true, completion: nil)
    } else {
        controller.show(webContentViewController, sender: controller)
    }
}
 
/*
  check App availabiliy status if not available then show maintanence page
*/
static func checkAppAvailabilityStatus(_ controller: UIViewController,
                                       completion: @escaping (Bool, MeasureAppStatus) -> Void) {
  if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: controller)
    return
  }
    NetworkManager.shared.getAppsAvailabilityStatus { (isSuccess, isAppAvailable) in
        completion(isSuccess ?? false, isAppAvailable)
    }
}

static func getErrorMessage(_ error: MoyaError) -> String {
  do {
     if let errorElement = try error.response?.mapJSON() as? [String: Any],
      let errorDict = errorElement[Constants.errorMessageKey] as? [String: Any],
         let message = errorDict[Constants.errorMessageValue] as? String {
         return message
     }
  } catch {}
  return ""
}
    
static func getErrorMessageFromMoya(_ error: MoyaError, _ controller: UIViewController) {
  do {
     if let errorElement = try error.response?.mapJSON() as? [String: Any],
      let errorDict = errorElement[Constants.errorMessageKey] as? [String: Any],
         let message = errorDict[Constants.errorMessageValue] as? String {
         let toaster = Toaster(view: controller.view)
         toaster.toast(message: message)
     } else {
         let toaster = Toaster(view: controller.view)
        toaster.toast(message: NoNetworkToastMessage.alertMessage.localized())
     }
  } catch {}
}
/*
  Get requested Header to send to Alamofire
*/
 static func getRequestHeader() -> HTTPHeaders {
    let modelName = UIDevice.modelName
    let iosVersion = UIDevice.current.systemVersion
   let headers: HTTPHeaders = [
     "Authorization": "Bearer \(Defaults[.loggedInUserAccessToken] ?? "")",
     "platform": "ios",
     "version": Constants.versionString,
     "edition": config.getAppCommunity(),
    "Accept-Language": AppLanguageManager.shared.getLanguage() ?? "en",
    "device_model": modelName,
    "device_os_version": iosVersion
   ]
   return headers
  }
}
