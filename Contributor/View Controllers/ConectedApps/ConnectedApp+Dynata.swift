//
//  ConnectedApp+Dynata.swift
//  Contributor
//
//  Created by Kiwitech on 05/05/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension ConnectedAppDetailController {

/*
  Get parameters/key from the /api/v1/connected-apps/dynata api and
  pass its value from the profile Store or basic profile that user
  has filled on welcome card
*/
func createParameter() -> [String: Any] {
  var param: [String: Any] = [:]
  if let selectedAppData = connectedAppData {
  if let items = selectedAppData.details?.profileItems.map({$0}) {
      _ = items.enumerated().map { (_, profileItem) in
          if let key = profileItem.ref,
             let value = UserManager.shared.profileStore?.values[key] {
              param.updateValue(value, forKey: key)
          }
      }
    }
  }
  return param
}
    
 func createRequest(_ url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = Helper.getRequestHeader()
    request.httpBody = try? JSONSerialization.data(withJSONObject: ["profile_items": createParameter()],
                                                   options: [])
    return request
 }

/*
  Api calling to connect Dynata /connected-apps/dynata/connect
*/
func clickToConnectDynataPartner(_ appTpe: ConnectedApp?) {
    self.loaderIndicator.updateIndicatorView(self, hidden: false)
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    let path = "/v1\(appConnect)\(appType)/connect"
    let url = Constants.baseContributorAPIURL.appendingPathComponent(path)
    Alamofire.request(createRequest(url)).responseJSON { [weak self] response in
        guard let this = self else { return }
        this.loaderIndicator.updateIndicatorView(this, hidden: true)
        if response.response?.statusCode == 400 {
            if let error = response.result.value as? [String: Any] {
                if let errorDict = error[Constants.errorMessageKey] as? [String: Any],
                    let message = errorDict[Constants.errorMessageValue] as? String {
                    let toaster = Toaster(view: this.view)
                    toaster.toast(message: message)
               }
            }
            return
        }
        this.handleConnectDynataResponse(response.result.error, appTpe)
    }
}
/*
 Handle connect dynata response if came from feed then post the offer notification
*/
func handleConnectDynataResponse(_ responseError: Error?, _ appType: ConnectedApp?) {
    if responseError == nil {
        if let dynataSetUpOffer = self.offerItem {
          let offerInfo: [String: AnyHashable] = [
            "offerID": dynataSetUpOffer.offerID,
            "useSmallDelay": false
          ]
          NotificationCenter.default.post(name: NSNotification.Name.offerCompleted,
                                          object: nil, userInfo: offerInfo)
        }
        if let type = appType {
            Router.shared.route(to: .connectionSuccess(appType: type),
                                from: self, presentationType: .push())
        }
    } else {
        let toaster = Toaster(view: self.view)
        toaster.toast(message: NoNetworkToastMessage.alertMessage.localized())
     }
  }
}
