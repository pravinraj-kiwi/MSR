//
//  ConnectionDataTypeController.swift
//  Contributor
//
//  Created by Kiwitech on 04/05/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

/*
 This class is a section of Connected/Not Connected apps depending on type
 of group i.e Profile Validation and Survey Partner
 */
class ConnectionDataTypeController: UIViewController, SpinnerDisplayable, StaticViewDisplayable {
    
var spinnerViewController: SpinnerViewController = SpinnerViewController()
var staticMessageViewController: FullScreenMessageViewController?
@IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
@IBOutlet weak var partnersTableView: UITableView!
var dataType: ConnectedDataType = .profileValidation
var appDatasource = AppDataDatasource()
var connectedAppData: [ConnectedAppData]?
var dynataConnectedData: ConnectedAppData?
let rowHeight: CGFloat = 67
let footerViewNib = "TableFooterView"

override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.loaderIndicator.updateIndicatorView(self, hidden: true)
    setUpNavBar(Text.myDataText.localized())
    NotificationCenter.default.addObserver(self, selector: #selector(updateConnectedData(_:)),
                                           name: NSNotification.Name.connectingAppSuccess, object: nil)
    setUpDataSource()
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  let appType = dataType.rawValue
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.connectAppType(connectType: appType))
}

/*
  Configuration of tableview and datasource.
*/
func setUpDataSource() {
  appDatasource.type = dataType
  appDatasource.datasourceDelegate = self
  partnersTableView.estimatedRowHeight = rowHeight
  let nib = UINib(nibName: footerViewNib, bundle: nil)
  partnersTableView.register(nib, forHeaderFooterViewReuseIdentifier: footerViewNib)
  fetchAppStatus(true)
  partnersTableView.dataSource = appDatasource
  partnersTableView.delegate = appDatasource
}

@objc func updateConnectedData(_ notification: Notification) {
   fetchAppStatus(false)
}

/*
  Call API /connected-apps to check whether app is connected or not and update UI accordingly
  If connected then green tick and if not then a connect button .
*/
func fetchAppStatus(_ isScreenLoadedInitially: Bool, completion: (() -> Void)? = nil) {
  updateTableViewUI(isScreenLoadedInitially)
  self.loaderIndicator.updateIndicatorView(self, hidden: false)
  if ConnectivityUtils.isConnectedToNetwork() == false {
      showNoNetworkUI()
      return
  }
  NetworkManager.shared.checkIfAppConnected { [weak self] (connectedAppData, error) in
      guard let this = self else {return}
      if error == nil {
          if let data = connectedAppData {
            this.appDatasource.connectApps = data.filter({$0.group == this.dataType.rawValue})
            this.reloadTable()
          }
      }
      completion?()
  }
}

func reloadTable() {
    DispatchQueue.main.async {
       self.updateTableViewUI(false)
       self.loaderIndicator.updateIndicatorView(self, hidden: true)
       self.partnersTableView.reloadData()
    }
}

/*
  Update UI when no network.
*/
func showNoNetworkUI() {
    updateTableViewUI(false)
    loaderIndicator.updateIndicatorView(self, hidden: true)
    let message = MessageHolder(message: Message.genericFetchError)
    show(staticMessage: message)
}

func updateTableViewUI(_ isLoaded: Bool) {
    partnersTableView.isHidden = isLoaded
}
 
/*
  Call API /api/v1/connected-apps/dynata to get the profile items keys from "label" key
 and update See all section for Dynata detail.
*/
func callApiToGetDynata(_ type: ConnectedApp, completion: ((Bool) -> Void)? = nil) {
    if ConnectivityUtils.isConnectedToNetwork() == false {
        showNoNetworkUI()
        return
    }
    NetworkManager.shared.getDynataProfileItems(appType: type) { [weak self] (connectedData, error) in
        guard let this = self else { return }
        if error == nil {
            this.dynataConnectedData = connectedData
            completion?(true)
        } else {
            completion?(false)
        }
    }
  }
}
extension ConnectionDataTypeController: DatasourceDelegate {
/*
  If dynata or pollfish connects successfully then user can go to dynata detail to see their job history
  But there is no detail page for facebook and linkedin.
*/
func clickToOpenConnectedDetail(index: Int) {
    if let data = appDatasource.connectApps?[index - 1], let appType = data.type,
        let type = ConnectedApp(rawValue: appType) {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: self)
            return
        }
        callApiToGetDynata(type) {[weak self] (isSuccess) in
           guard let this = self else { return }
           if isSuccess {
             Router.shared.route(to: Route.dynataDetail(this.dynataConnectedData),
                         from: this,
                         presentationType: .modal(presentationStyle: .fullScreen,
                                                  transitionStyle: .coverVertical))
            } else {
                let toaster = Toaster(view: this.view)
                toaster.toast(message: NoNetworkToastMessage.alertMessage.localized())
            }
        }
    }
}

/*
  Open connection class for pollfish, dynata, facebook and linkedin.
*/
func clickToOpenConnectionDetail(index: Int) {
    if let data = appDatasource.connectApps?[index - 1], let appType = data.type,
        let type = ConnectedApp(rawValue: appType) {
        if type == .dynata || type == .pollfish || type == .kantar || type == .precision {
            callPartnerSurvey(type)
        } else {
            Router.shared.route(
                    to: Route.connect(appType: type, connectAppData: dynataConnectedData),
                    from: self,
                    presentationType: .modal(presentationStyle: .pageSheet,
                                               transitionStyle: .coverVertical))
        }
    }
}
    
/*
  Calling reload current user API to check if user has filled basic demo survey or not.As we
  need to pass basic profile items value to connect dynata api.Hence it's important to check
  the login user has filled the basic profile survey
*/
func callPartnerSurvey(_ type: ConnectedApp) {
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    loaderIndicator.updateIndicatorView(self, hidden: false)
    NetworkManager.shared.reloadCurrentUser { [weak self] (error) in
        guard let this = self else { return }
        if error == nil {
            this.loaderIndicator.updateIndicatorView(this, hidden: true)
            this.checkForTheBasicDemoFilled(type)
         }
     }
}
 
func checkForTheBasicDemoFilled(_ type: ConnectedApp) {
 if UserManager.shared.user?.hasFilledBasicDemos == false {
        let alerter = Alerter(viewController: self)
    alerter.alert(title: "", message: ConnectAppType.dynataAlertTitle.localized(),
                      confirmButtonTitle: nil, cancelButtonTitle: ConnectAppType.okTitle.localized(),
                      onConfirm: nil, onCancel: nil)
 } else {
    callApiToGetDynata(type) { (isSuccess) in
        if isSuccess {
            Router.shared.route(to: Route.connect(appType: type, connectAppData: self.dynataConnectedData),
                                from: self,
                                presentationType: .modal(presentationStyle: .pageSheet,
                                                              transitionStyle: .coverVertical))
            } else {
                let toaster = Toaster(view: self.view)
                toaster.toast(message: NoNetworkToastMessage.alertMessage.localized())
            }
        }
     }
  }
}

/*
  Reload page if network error comes
*/
extension ConnectionDataTypeController: MessageViewControllerDelegate {
  func didTapActionButton() {
    hideStaticMessage()
    fetchAppStatus(true)
  }
}
