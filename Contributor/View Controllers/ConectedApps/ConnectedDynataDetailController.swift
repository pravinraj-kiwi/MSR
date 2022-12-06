//
//  ConnectedDynataDetailController.swift
//  Contributor
//
//  Created by KiwiTech on 5/7/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Alamofire

/*
 This class gets the Dynata detail when user gets connected
 to dynata.
 */
class ConnectedDynataDetailController: UIViewController {

var dynataDetailDatasource = DynataDetailDataSource()
@IBOutlet weak var dynataDetailTableView: UITableView!
@IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
var dynataData: ConnectedAppData?
let dynataDisconnect = "/connected-apps/"

override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.loaderIndicator.updateIndicatorView(self, hidden: true)
    setUpNavBar(Text.surveyPartnerText.localized())
    resetValues()
    /*
     This api gets the job history and update
     the data source /connected-apps/dynata/jobs
     */
    if let selectedApp = dynataData, let app = selectedApp.type,
        let type = ConnectedApp(rawValue: app) {
        getDynataJobHistory(type) { [weak self] (dynataEarnings) in
            guard let this = self else { return }
            if let earnings = dynataEarnings {
                this.setUpDataSource(earnings)
            }
        }
    }
}
    
override func viewDidAppear(_ animated: Bool) {
   super.viewDidAppear(animated)
    if let selectedApp = dynataData, let app = selectedApp.type,
       let appName = ConnectedApp(rawValue: app)?.rawValue {
        FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.surveyPartnerDetailScreen(name: appName))
    }
}

/*
  Configuration of tableview and datasource.
*/
func setUpDataSource(_ earning: DynataJobDetail) {
    dynataDetailTableView.dataSource = dynataDetailDatasource
    dynataDetailTableView.delegate = dynataDetailDatasource
    dynataDetailDatasource.dynataSourceDelegate = self
    dynataDetailDatasource.connectDynata = dynataData
    dynataDetailDatasource.jobEarnings = earning
    dynataDetailTableView.rowHeight = UITableView.automaticDimension
    dynataDetailTableView.estimatedRowHeight = Constants.estimatedRow
    dynataDetailTableView.reloadData()
}

/*
   Reset the value for seeAll/Read More click as
   saving in userdefault when user navigate to this screen.
*/
func resetValues() {
    Defaults[.seeAllClicked] = false
    Defaults[.readMoreClicked] = false
}

@objc func close() {
    dismissSelf()
}

/*
  Webview opens to see Terms&Condition for Dynata
*/
func showTermsOfService() {
    if let selectedApp = dynataData, let app = selectedApp.type,
        let type = ConnectedApp(rawValue: app) {
        switch type {
        case .dynata:
            Helper.clickToOpenUrl(Constants.dynataTermURL, controller: self)
        case .pollfish:
            Helper.clickToOpenUrl(Constants.pollfishTermURL, controller: self)
        case .kantar:
            Helper.clickToOpenUrl(Constants.kantarTermURL, controller: self)
        case .precision:
            Helper.clickToOpenUrl(Constants.precisionTermURL, controller: self)
        default:
            break
        }
    }
}
    
/*
  Webview opens to see Privacy Policy for Dynata
*/
func showPrivacyPolicy() {
    if let selectedApp = dynataData, let app = selectedApp.type,
        let type = ConnectedApp(rawValue: app) {
        switch type {
        case .dynata:
            Helper.clickToOpenUrl(Constants.dynataPrivacyURL, controller: self)
        case .pollfish:
            Helper.clickToOpenUrl(Constants.pollfishPrivacyURL, controller: self)
        case .kantar:
            Helper.clickToOpenUrl(Constants.kantarPrivacyURL, controller: self)
        case .precision:
            Helper.clickToOpenUrl(Constants.precisionPrivacyURL, controller: self)
        default:
            break
        }
    }
 }
}

extension ConnectedDynataDetailController: DynataDetailDatasourceDelegate {
/*
  When user clicks to disconnect Dynata Setup
*/
func clickToDisconnectDynata() {
    let alerter = Alerter(viewController: self)
    alerter.alert(title: DynataDetail.alertTitle.localized(), message: DynataDetail.alertMessage.localized(),
                  confirmButtonTitle: DynataDetail.alertConfirmTitle.localized(),
                  cancelButtonTitle: DynataDetail.alertCancelTitle.localized(),
                  confirmButtonStyle: .destructive, onConfirm: {
        if let selectedApp = self.dynataData, let app = selectedApp.type,
            let type = ConnectedApp(rawValue: app) {
            self.clickToDisconnectDynataPartner(type)
        }
    }, onCancel: nil)
 }
   
/*
 In See All/See Less if user
 clicks on Terms
*/
func clickToOpenTerms() {
  showTermsOfService()
}

/*
In See All/See cell if user
clicks on privacy
*/
func clickoOpenPrivacy() {
  showPrivacyPolicy()
}

/*
When user clicked on See All/See Less to make table
scroll so that user can see the whole content
*/
func clickToReloadTableView() {
  UIView.performWithoutAnimation {
    self.dynataDetailTableView.beginUpdates()
    if Defaults[.seeAllClicked] == true {
        scrollToLastRow()
    }
    self.dynataDetailTableView.endUpdates()
  }
}

 /*
    Scrolling to last row in the given array
 */
 func scrollToLastRow() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        let indexPath = IndexPath(row: DynataDetailCellType.numberOfRows() - 1, section: 0)
        self.dynataDetailTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
 }

 /*
   When user clicked on Read More to make table
   scroll so that user can see the whole content
 */
 func clickToReloadMoreTableView() {
   UIView.performWithoutAnimation {
     self.dynataDetailTableView.beginUpdates()
     if Defaults[.readMoreClicked] == true {
        scrollToLastRow()
     }
     self.dynataDetailTableView.endUpdates()
   }
}
    
func clickToGetJobDetail(_ appType: ConnectedApp, _ transaction: WalletTransaction) {
    Router.shared.route(
      to: Route.walletDetail(appType, transaction),
        from: self,
        presentationType: .push(surveyToolBarNeeded: false, fromTabBar: true)
    )
  }
}

extension ConnectedDynataDetailController {
/*
  Api calling to disconnect Dynata /connected-apps/dynata/disconnect
*/
func clickToDisconnectDynataPartner(_ appType: ConnectedApp) {
    self.loaderIndicator.updateIndicatorView(self, hidden: false)
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    let path = "/v1\(dynataDisconnect)\(appType)/disconnect"
    let url = Constants.baseContributorAPIURL.appendingPathComponent(path)
    Alamofire.request(url, method: .post, parameters: [:],
                      headers: Helper.getRequestHeader()).responseString { [weak self] response in
        guard let this = self else { return }
        this.loaderIndicator.updateIndicatorView(this, hidden: true)
        if response.result.error == nil {
            this.dismissSelf()
            NotificationCenter.default.post(name: NSNotification.Name.connectingAppSuccess,
                                            object: nil, userInfo: nil)
        } else {
            let toaster = Toaster(view: this.view)
            toaster.toast(message: NoNetworkToastMessage.alertMessage.localized())
        }
     }
  }
}

extension ConnectedDynataDetailController {
/*
  Api calling to get Dynata Job History /connected-apps/dynata/jobs
*/
func getDynataJobHistory(_ app: ConnectedApp, _ completion: @escaping (DynataJobDetail?) -> Void) {
  self.loaderIndicator.updateIndicatorView(self, hidden: false)
  if ConnectivityUtils.isConnectedToNetwork() == false {
      Helper.showNoNetworkAlert(controller: self)
        return
    }
    NetworkManager.shared.getDynataJobDetail(app) { [weak self] (jobEarnings, error) in
        guard let this = self else { return }
        this.loaderIndicator.updateIndicatorView(this, hidden: true)
        if error == nil {
            completion(jobEarnings)
        } else {
            let toaster = Toaster(view: this.view)
            toaster.toast(message: NoNetworkToastMessage.alertMessage.localized())
            completion(nil)
        }
    }
  }
}
