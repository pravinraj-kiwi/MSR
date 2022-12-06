//
//  SettingViewController.swift
//  Contributor
//
//  Created by KiwiTech on 9/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import WebKit
import SwiftyUserDefaults

class SettingViewController: UIViewController {
    
@IBOutlet weak var tableView: UITableView!
@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
var isMaintenancePageDisplayed = false
var settingDatasource = SettingDatasource()
    
override func viewDidLoad() {
  super.viewDidLoad()
  activityIndicator.updateIndicatorView(self, hidden: true)
  setupNavbar()
  addObserver()
}

override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  checkMaintenanceStatus()
  setUpDataSource()
}
    
override func viewWillDisappear(_ animated: Bool) {
  super.viewWillDisappear(animated)
  Defaults[.shouldRefreshWallet] = false
}
  
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.settingScreen)
}
    
func addObserver() {
  NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationEnterForeground),
                                           name: UIApplication.willEnterForegroundNotification, object: nil)
}
    
func setupNavbar() {
  if let _ = self.presentingViewController {
    view.backgroundColor = Utilities.getRgbColor(247, 247, 247)
    setTitle(Text.setting.localized())

    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Utilities.getRgbColor(247, 247, 247)]
    navigationController?.navigationBar.barTintColor = Utilities.getRgbColor(247, 247, 247)
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: Text.close.localized(),
                                                   style: UIBarButtonItem.Style.plain,
                                                   target: self, action: #selector(self.dismissSelf))
    navigationItem.leftBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 17),
                                                                 for: .normal)
    
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.configureWithOpaqueBackground()
    navigationBarAppearance.backgroundColor = Utilities.getRgbColor(247, 247, 247)
    navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Utilities.getRgbColor(247, 247, 247)]
    navigationBarAppearance.shadowImage = nil
    navigationBarAppearance.shadowColor = .none
    navigationController!.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController!.navigationBar.compactAppearance = navigationBarAppearance
    navigationController!.navigationBar.standardAppearance = navigationBarAppearance
    if #available(iOS 15.0, *) {
        navigationController!.navigationBar.compactScrollEdgeAppearance = navigationBarAppearance
    }
    
  }
}
    
func updateSettingWithReferFriend() -> [SettingsSection] {
    var settingData: [SettingsSection] = [SettingsSection(
      title: SettingViewText.account.localized(),
      items: [.personalDetails, .changePassword, .deleteAcount, .referFriend]
    ),
    SettingsSection(
        title: SettingViewText.app.localized(),
      items: [.faq, .terms, .privacy, .support]
    )]
    if let user = UserManager.shared.user, user.isTestUser {
      settingData.append(testUserSetting())
    }
   return settingData
}
    
func updateSettingData() -> [SettingsSection] {
  var settingData: [SettingsSection] = [SettingsSection(
    title: SettingViewText.account.localized(),
    items: [.personalDetails, .changePassword, .deleteAcount]
  ),
  SettingsSection(
    title: SettingViewText.app.localized(),
    items: [.faq, .terms, .privacy, .support]
  )]
  if let user = UserManager.shared.user, user.isTestUser {
    settingData.append(testUserSetting())
  }
 return settingData
}
    
func testUserSetting() -> SettingsSection {
  let userSettingData: SettingsSection = SettingsSection(
    title: SettingViewText.testing.localized(),
    items: [.dumpProfile, .deleteRandomProfileItems,
            .runProfileMaintenance, .runNetworkVote,
            .runDataInboxSupport, .testACOnboard,
            .testBroccoliOnboard, .testGamerOnboard, .changeLanguage]
    )
  return userSettingData
}

func setUpDataSource() {
  let nib = UINib(nibName: Constants.sectionViewNib, bundle: nil)
  tableView.register(nib, forHeaderFooterViewReuseIdentifier: Constants.sectionViewNib)
  tableView.register(cellType: FooterCell.self)
  tableView.rowHeight = 56
  tableView.estimatedRowHeight = 56
  if UserManager.shared.user?.referFriendEnabled == true {
    settingDatasource.settingsData = updateSettingWithReferFriend()
  } else {
    settingDatasource.settingsData = updateSettingData()
  }
  settingDatasource.dataSourceDelegate = self
  tableView.dataSource = settingDatasource
  tableView.delegate = settingDatasource
  tableView.reloadData()
}
    
func checkMaintenanceStatus() {
  Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
    if isSuccess == false { return }
    guard let this = self else { return }
    if measureAppStatus == .available {
        if this.isMaintenancePageDisplayed == true {
            this.isMaintenancePageDisplayed = false
        }
    } else if measureAppStatus == .unavailable
                && this.isMaintenancePageDisplayed == false {
        Helper.clickToOpenUrl(Constants.statusDownBaseURL,
                              controller: this,
                              presentationStyle: .fullScreen)
        this.isMaintenancePageDisplayed = true
      }
   }
}
    
@objc func onApplicationEnterForeground() {
    Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
      if isSuccess == false { return }
      guard let this = self else { return }
       if measureAppStatus == .available {
          if this.isMaintenancePageDisplayed == true {
               this.isMaintenancePageDisplayed = false
           }
       } else if measureAppStatus == .unavailable
                    && this.isMaintenancePageDisplayed == false {
          Helper.clickToOpenUrl(Constants.statusDownBaseURL,
                    controller: this,
                    presentationStyle: .fullScreen, shouldPresent: true)
         this.isMaintenancePageDisplayed = true
      }
    }
  }
}

extension SettingViewController: WebContentDelegate {
func didFinishNavigation(navigationAction: WKNavigationAction) {
    if let clickedUrl = navigationAction.request.url?.absoluteString,
        clickedUrl == Constants.maintananceRefreshButtonUrl {
        Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
            if isSuccess == false { return }
            guard let this = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let refreshNotif = NSNotification.Name.refreshWebview
                NotificationCenter.default.post(name: refreshNotif,
                                                object: nil, userInfo: nil)
            }
            if measureAppStatus == .available {
                if this.isMaintenancePageDisplayed == true {
                    this.isMaintenancePageDisplayed = false
                }
                this.dismissSelf()
                this.isMaintenancePageDisplayed = false
            }
        }
     }
  }
}
