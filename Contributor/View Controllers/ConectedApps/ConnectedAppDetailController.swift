//
//  LinkedinConnectionController.swift
//  Contributor
//
//  Created by KiwiTech on 3/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes
import SwiftyUserDefaults
import Alamofire

/*
 This class gets the detail for connecting apps
 i.e Facebook, Linkedin and Dynata.
*/
class ConnectedAppDetailController: UIViewController {

@IBOutlet weak var connectButton: UIButton!
@IBOutlet weak var notInterestButton: UIButton!
@IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
@IBOutlet weak var appDetailTableView: UITableView!
@IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
@IBOutlet weak var bottomView: UIView!

var appType: ConnectedApp = .linkedin
var connectedAppData: ConnectedAppData?
var offerItem: OfferItem?
var appDetailDatasource = AppDetailDataSource()
public let primaryColor = Constants.primaryColor
let appConnect = "/connected-apps/"

override func viewDidLoad() {
super.viewDidLoad()
// Do any additional setup after loading the view.
    self.loaderIndicator.updateIndicatorView(self, hidden: true)
    setupNavbar()
    resetValues()
    setUpDataSource()
    applyCommunityTheme()
}

override func viewDidAppear(_ animated: Bool) {
   super.viewDidAppear(animated)
   let appName = appType.rawValue
   if appType == .linkedin || appType == .facebook {
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.profileValidationConnectScreen(name: appName))
   } else {
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.surveyPartnerConnectScreen(name: appName))
   }
}
    
/*
  Configuration of tableview and datasource.
*/
func setUpDataSource() {
    appDetailTableView.dataSource = appDetailDatasource
    appDetailTableView.delegate = appDetailDatasource
    appDetailDatasource.type = appType
    appDetailDatasource.connectApps = connectedAppData
    appDetailDatasource.datasourceDelegate = self
    appDetailTableView.rowHeight = UITableView.automaticDimension
    appDetailTableView.estimatedRowHeight = Constants.estimatedRow
    appDetailTableView.reloadData()
}
    
func setupNavbar() {
    if let _ = self.presentingViewController {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: Text.close.localized(),
                                                           style: UIBarButtonItem.Style.plain,
                                                           target: self, action: #selector(close))
    navigationItem.leftBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 17),
                                                             for: .normal)
    }
    if appType == .linkedin {
        clearWebViewDataStore()
    }
    if appType == .dynata || appType == .pollfish
        || appType == .kantar || appType == .precision {
        bottomViewHeight.constant = Constants.dynataResetHeight
    } else {
        bottomViewHeight.constant = Constants.dynataBottomHeight
    }
}

func resetValues() {
    Defaults[.seeAllClicked] = false
    Defaults[.readMoreClicked] = false
}

@objc func close() {
    dismissSelf()
}

/*
  Webview opens to see Terms&Condition only for Dynata
*/
func showTermsOfService(_ appTpe: ConnectedApp?) {
    switch appTpe {
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

/*
  Webview opens to see Privacy&Policy only for Dynata
*/
func showPrivacyPolicy(_ appTpe: ConnectedApp?) {
    switch appTpe {
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

/*
  When user clicks to Connect From facebook and linkedin
*/
@IBAction func clickToAuthenticate(_ sender: Any) {
    switch appType {
    case .linkedin:
        clickToConnectLinkedin()
    case .facebook:
        connectThruFacebook()
    case .dynata, .pollfish, .kantar, .precision:
        break
    }
}
        
@IBAction func clickToGoBack(_ sender: Any) {
    dismissSelf()
 }

/*
  Call decline offer api if user decline to setup Dynata
  And update Feed to remove that setUp offer
*/
func callApiToDeclineDynataSetUpOffer(_ dynataSetUpOffer: OfferItem) {
  if ConnectivityUtils.isConnectedToNetwork() == false {
     Helper.showNoNetworkAlert(controller: self)
     return
  }
  loaderIndicator.updateIndicatorView(self, hidden: false)
  
  NetworkManager.shared.markOfferItemsAsDeclined(items: [dynataSetUpOffer]) { [weak self] _ in
    guard let this = self else { return }
    this.loaderIndicator.updateIndicatorView(this, hidden: true)
    this.dismissSelf()
    let offerInfo: [String: AnyHashable] = [
     "offerID": dynataSetUpOffer.offerID,
     "useSmallDelay": false
   ]
  NotificationCenter.default.post(name: NSNotification.Name.offerCompleted,
                                  object: nil, userInfo: offerInfo)
  }
 }
}

extension ConnectedAppDetailController: AppDetailDatasourceDelegate {
/*
  When user clicks to dismiss Dynata Setup
*/
func clickToDismiss() {
  if let dynataSetUpOffer = offerItem {
    callApiToDeclineDynataSetUpOffer(dynataSetUpOffer)
  } else {
    dismissSelf()
  }
}

/*
  When user clicks to connect Dynata Setup
*/
func clickToConnectDynata(_ appTpe: ConnectedApp?) {
    if let type = appTpe {
        clickToConnectDynataPartner(type)
    }
}

/*
 In See All/See cell if user
 clicks on Terms
*/
func clickToOpenTerms(_ appTpe: ConnectedApp?) {
    if let type = appTpe {
      showTermsOfService(type)
    }
}

/*
In See All/See cell if user
clicks on privacy
*/
func clickoOpenPrivacy(_ appTpe: ConnectedApp?) {
    if let type = appTpe {
      showPrivacyPolicy(type)
    }
}

/*
 When user clicked on See All/See Less to make table
 scroll so that user can see the whole content
*/
func clickToReloadTableView() {
  UIView.performWithoutAnimation {
    self.appDetailTableView.beginUpdates()
    if Defaults[.seeAllClicked] == true {
       scrollToLastRow()
    }
    self.appDetailTableView.endUpdates()
   }
}

/*
   Scrolling to last row in the given array
*/
func scrollToLastRow() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        let indexPath = IndexPath(row: AppDetailCellType.numberOfRows() - 1, section: 0)
        self.appDetailTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

/*
 Provide tap gesture callback for Privacy Policy &
 Terms Conditions
*/
func didTapLabel(_ label: UILabel, gesture: UITapGestureRecognizer, _ appTpe: ConnectedApp?) {
    if let range = label.text?.range(of: Text.privacy.localized())?.nsRange {
    if gesture.didTapAttributedTextInLabel(label: label,
                                       inRange: range) {
        showPrivacyPolicy(appTpe)
        }
    }
    if let range = label.text?.range(of: Text.termsCondition.localized())?.nsRange {
      if gesture.didTapAttributedTextInLabel(label: label,
                                     inRange: range) {
        showTermsOfService(appTpe)
      }
   }
}

/*
  When user clicked on Read More to make table
  scroll so that user can see the whole content
*/
func clickToReloadMoreTableView() {
    UIView.performWithoutAnimation {
      self.appDetailTableView.beginUpdates()
        if Defaults[.readMoreClicked] == true {
            self.scrollToLastRow()
        }
        self.appDetailTableView.endUpdates()
      }
    }
}

/*
This extension update the theme for button colors and text according the app
Example: Broccoili, Asking Canadians etc. That can be access through setting
For testing purpose
*/
extension ConnectedAppDetailController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
        return
    }
    connectButton.setBackgroundColor(color: colors.primary, forState: .normal)
    notInterestButton.setTitleColor(colors.primary, for: .normal)
    connectButton.setTitle(MyDataText.connectText.localized(), for: .normal)
    notInterestButton.setTitle(MyDataText.noThanksText.localized(), for: .normal)
  }
}
