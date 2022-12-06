//
//  SettingView+DelegateHandling.swift
//  Contributor
//
//  Created by KiwiTech on 9/29/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import MessageUI
import SwiftyUserDefaults

extension SettingViewController: SettingDataSourceDelegate {

func clickToNavigate(_ section: Setting) {
  switch section {
  case .deleteAcount: handleDeleteAccount()
  case .faq : handleWebLinks(Constants.faqURL)
  case .terms: handleWebLinks(Constants.termsURL)
  case .privacy: handleWebLinks(Constants.privacyURL)
  case .support: Router.shared.route(to: .support(), from: self,
                                     presentationType: .modal(presentationStyle: .pageSheet,
                                                              transitionStyle: .coverVertical))
  case .personalDetails: Router.shared.route(to: .personalEdit, from: self)
  case .changePassword: Router.shared.route(to: .changePassword, from: self)
  case .referFriend: openReferAFriend()
  case .dumpProfile: dumpProfile()
  case .deleteRandomProfileItems: deleteRandom()
  case .runProfileMaintenance: runProfileMaintenance()
  case .runNetworkVote: runNetworkVote()
  case .runDataInboxSupport: runDataInboxSupport()
  case .testACOnboard: testACOnboard()
  case .testBroccoliOnboard: testBroccoliOnboard()
  case .testGamerOnboard: testGamerOnboard()
  case .changeLanguage: Router.shared.route(to: .changeLanguage, from: self)
  default: break
    }
}
    
func openReferAFriend() {
    if let code = UserManager.shared.user?.inviteCode {
        Router.shared.route(to: .referView(inviteCode: code),
                            from: self,
                            presentationType: .modal(presentationStyle: .pageSheet,
                                                     transitionStyle: .coverVertical))
    }
}
    
func clickToHandleLogoutAction() {
  handleLogout()
}
    
func handleLogout() {
  if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
  }
  activityIndicator.updateIndicatorView(self, hidden: false)
  guard let accessToken = Defaults[.loggedInUserAccessToken] else { return }
  NetworkManager.shared.logoutUser(accessToken: accessToken) { [weak self] (statusCode, _) in
    guard let this = self else { return }
    this.activityIndicator.updateIndicatorView(this, hidden: true)
    if statusCode == 200 {
        NotificationCenter.default.post(name: NSNotification.Name.shouldLogout,
                                            object: this, userInfo: nil)
        }
    }
}
    
func handleWebLinks(_ url: URL) {
 let webContentViewController = WebContentViewController()
 webContentViewController.startURL = url
 webContentViewController.isFromSetting = true
 show(webContentViewController, sender: self)
}

func handleDeleteAccount() {
 if let topMostController = UIViewController.topMost {
    let alerter = Alerter(viewController: topMostController)
    alerter.alert(title: CustomPopUpText.title.localized(), message: CustomPopUpText.message.localized(),
                  confirmButtonTitle: CustomPopUpText.cancelTitle.localized(),
                  cancelButtonTitle: CustomPopUpText.deleteTitle.localized(),
                  confirmButtonStyle: .default, cancelButtonStyle: .destructive,
                  onConfirm: nil) {
        self.confirmAction()
    }
  }
}
    
func confirmAction() {
 if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
 }
 activityIndicator.updateIndicatorView(self, hidden: false)
 NetworkManager.shared.uploadProfileData(profileData: "{}",
                                         tag: TagObject.TAG_ALL.rawValue) { (_, error) in
    if error == nil {
       NetworkManager.shared.deletAccount { [weak self] (_) in
         guard let this = self else { return }
         this.activityIndicator.updateIndicatorView(this, hidden: true)
         this.dismissSelf()
         NotificationCenter.default.post(name: NSNotification.Name.shouldLogout,
                                          object: self, userInfo: nil)
        }
    } else {
        self.activityIndicator.updateIndicatorView(self, hidden: true)
    }
   }
 }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
func sendEmail() {
  if MFMailComposeViewController.canSendMail() {
    let mail = MFMailComposeViewController()
    mail.mailComposeDelegate = self
    mail.setToRecipients([Constants.supportEmail])
    present(mail, animated: true)
  } else {}
}

func mailComposeController(_ controller: MFMailComposeViewController,
                           didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
}

extension SettingViewController: customPopDelegate {
func dismissSettingScreen() {
  NotificationCenter.default.post(name: NSNotification.Name.shouldLogout,
                                  object: self, userInfo: nil)
  }
}
