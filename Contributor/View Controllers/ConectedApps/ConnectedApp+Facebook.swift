//
//  ConnectedApp+Facebook.swift
//  Contributor
//
//  Created by KiwiTech on 4/30/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya
import SwiftyAttributes

extension ConnectedAppDetailController {
/*
  Api calling to get data from Facebook server and
  update Facebook Id to measure server
*/
func connectThruFacebook() {
   self.navigationController?.popViewController(animated: true)
   if ConnectivityUtils.isConnectedToNetwork() == false {
       Helper.showNoNetworkAlert(controller: self)
       return
   }
   self.loaderIndicator.updateIndicatorView(self, hidden: false)
   hitFacebookLoginApi(controller: self) { (facebookLoginData, isSuccess) in
       if isSuccess == false && facebookLoginData == nil { return }
       if let facebookAccountId = facebookLoginData?.facebookId {
         self.updateFacebookIdToServer(facebookAccountId)
       }
   }
}
    
/*
  Api calling to get update Facebook Id to measure server
*/
func updateFacebookIdToServer(_ facebookAccountId: String?) {
    guard let facebookId = facebookAccountId else { return }
    NetworkManager.shared.updateAuthenticatedFacebookUser(facebookId: facebookId) { [weak self] (error) in
        guard let this = self else { return }
        this.loaderIndicator.updateIndicatorView(this, hidden: true)
        if error == nil {
            Router.shared.route(to: .connectionSuccess(appType: .facebook),
                                from: this, presentationType: .push())
        } else {
            if let error = error as? MoyaError {
                let statusCode = error.response?.statusCode ?? 500
                if statusCode == 409 {
                    Router.shared.route(to: .connectionFailure(appType: .facebook),
                                        from: this, presentationType: .push())
                } else {
                    Helper.getErrorMessageFromMoya(error, this)
                }
            }
        }
    }
}
       
/* This method is used to hit facebook login api */
func hitFacebookLoginApi(controller: UIViewController, compeltionHandler: @escaping (FaceBookLoginData?, Bool) -> Void ) {
   FacebookLoginHelper().facebookLoginRequest(viewcontroller: controller) { (facebookLoginResult) in
     self.loaderIndicator.updateIndicatorView(self, hidden: true)
       switch facebookLoginResult {
       case .success(let loginResult):
           compeltionHandler(loginResult, true)
       case .error(_):
           compeltionHandler(nil, false)
       case .cancelled:
           compeltionHandler(nil, false)
       }
     }
  }
}
