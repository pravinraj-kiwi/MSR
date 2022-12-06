//
//  ConnectedApp+Linkedin.swift
//  Contributor
//
//  Created by KiwiTech on 4/30/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya
import SwiftyAttributes
import WebKit

extension ConnectedAppDetailController {

func clickToConnectLinkedin() {
   if ConnectivityUtils.isConnectedToNetwork() == false {
       Helper.showNoNetworkAlert(controller: self)
       return
   }
   self.navigationController?.navigationBar.isHidden = false
   let linkedinURL = NetworkManager.shared.getAuthoriztionURL()
   let webContentViewController = WebContentViewController()
   webContentViewController.webContentDelegate = self
   webContentViewController.shouldHideBackButton = false
   webContentViewController.startURL = URL(string: linkedinURL)
   self.show(webContentViewController, sender: self)
}
    
func clearWebViewDataStore() {
   WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
       records.forEach { record in
           WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes,
                                                   for: [record], completionHandler: {})
           print("[WebCacheCleaner] Record \(record) deleted")
       }
   }
}

/*
  Api calling to get data from linkedin server and
  update linkedin Id to measure server
*/
func updateLinkedinStatus(token: String) {
    self.navigationController?.popViewController(animated: true)
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    self.loaderIndicator.updateIndicatorView(self, hidden: false)
    NetworkManager.shared.getLinkedinUserData(authorizationCode: token) { (account, error) in
        if error != nil { return }
        if let linkedinAccountId = account?.linkedinId {
        NetworkManager.shared.updateAuthenticatedLinkedinUser(linkedinId: linkedinAccountId) { [weak self] (error) in
            guard let this = self else { return }
            this.loaderIndicator.updateIndicatorView(this, hidden: true)
            if error == nil {
                Router.shared.route(to: .connectionSuccess(appType: .linkedin),
                                    from: this, presentationType: .push())
            } else {
                if let error = error as? MoyaError {
                    let statusCode = error.response?.statusCode ?? 500
                    if statusCode == 409 {
                        Router.shared.route(to: .connectionFailure(appType: .linkedin),
                                            from: this, presentationType: .push())
                    } else {
                        Helper.getErrorMessageFromMoya(error, this)
                    }
                }
             }
          }
       }
    }
  }
}

extension ConnectedAppDetailController: WebContentDelegate {
func didFinishNavigation(navigationAction: WKNavigationAction) {
    let request = navigationAction.request
    if let url = request.url {
        if request.url?.host == "www.google.com" {
            if url.absoluteString.range(of: "code") != nil {
                let urlParts = url.absoluteString.components(separatedBy: "?")
                let code = urlParts[1].components(separatedBy: "=")[1]
                updateLinkedinStatus(token: code)
            }
            if url.absoluteString.range(of: "error") != nil {
                let urlParts = url.absoluteString.components(separatedBy: "?")
                let userCancelled = urlParts[1].components(separatedBy: "=")[1]
                if userCancelled == "user_cancelled_login&error_description" {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
  }
}
