//
//  WalletListViewController.swift
//  Contributor
//
//  Created by KiwiTech on 8/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class WalletListViewController: UIViewController, SpinnerDisplayable, StaticViewDisplayable {
   
@IBOutlet weak var headerView: UIView!
@IBOutlet weak var tableView: UITableView!
    
var fetchBalanceError: Error?
var fetchExchangeRatesError: Error?
var fetchTransactionsError: Error?
var isMaintanencePageDisplayed = false
var spinnerViewController: SpinnerViewController = SpinnerViewController()
var staticMessageViewController: FullScreenMessageViewController?
var walletTransactionsHolder: WalletTransactionsHolder?
var balancesHolder: BalancesHolder?
var walletDatasource = WalletDatasource()
var transactionItem = [GroupedSection<Date, WalletTransaction>]()

var gotFetchError: Bool {
  return fetchBalanceError != nil || fetchExchangeRatesError != nil || fetchTransactionsError != nil
}
    
lazy var refreshControl: UIRefreshControl = {
  let refreshControl = UIRefreshControl()
  refreshControl.addTarget(self, action: #selector(self.refreshBalance), for: .valueChanged)
  return refreshControl
}()
    
lazy var topHeaderView: TopHeaderViewCell = {
  let topHeader = TopHeaderViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 97))
  topHeader.delegate = self
    topHeader.configure(with: TopHeaderItem(text: TabName.wallet.localized(), showDate: false))
  topHeader.translatesAutoresizingMaskIntoConstraints = false
  return topHeader
}()
    
override func viewDidLoad() {
  super.viewDidLoad()
  setUpHeaderView()
  addListeners()
}
    
override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  if Defaults[.shouldRefreshWallet] {
    refresh()
  }
  refreshControl.endRefreshing()
  navigationController?.navigationBar.isHidden = true
  self.currentTabBar?.setBar(hidden: false, animated: false)
  Defaults[.shouldRefreshWallet] = true
}

func setUpHeaderView() {
  view.backgroundColor = Constants.backgroundColor
  headerView.addSubview(topHeaderView.contentView)
  tableView.refreshControl = refreshControl
  walletDatasource.datasourceDelegate = self
  setUpDataSource()
}
    
func setUpDataSource() {
  let nib = UINib(nibName: Constants.headerViewNib, bundle: nil)
  tableView.register(nib, forHeaderFooterViewReuseIdentifier: Constants.headerViewNib)
  tableView.dataSource = walletDatasource
  tableView.delegate = walletDatasource
  tableView.rowHeight = 64
  tableView.estimatedRowHeight = 64
}
    
func addListeners() {
  NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                         name: NSNotification.Name.giftCardRedeemed, object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                         name: NSNotification.Name.balanceChanged, object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationEnterForeground),
                                         name: UIApplication.willEnterForegroundNotification, object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(self.reloadPage),
                                         name: NSNotification.Name.refreshController, object: nil)
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
    if isSuccess == false { return }
    guard let this = self else { return }
     if measureAppStatus == .available {
        if this.isMaintanencePageDisplayed == true {
             this.isMaintanencePageDisplayed = false
         }
     } else if measureAppStatus == .unavailable && this.isMaintanencePageDisplayed == false {
       this.updateUI()
    }
   }
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.walletScreen)
}
    
func updateUI() {
  Helper.clickToOpenUrl(Constants.statusDownBaseURL,
                        controller: self,
                        presentationStyle: .fullScreen)
  isMaintanencePageDisplayed = true
}
    
@objc func reloadPage() {
   refresh()
}
    
@objc func onApplicationEnterForeground() {
    Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
      if isSuccess == false { return }
      guard let this = self else { return }
       if measureAppStatus == .available {
          if this.isMaintanencePageDisplayed == true {
               this.isMaintanencePageDisplayed = false
           }
       } else if measureAppStatus == .unavailable && this.isMaintanencePageDisplayed == false {
          this.updateUI()
      }
    }
  }
}
