//
//  WalletDetailViewController.swift
//  Contributor
//
//  Created by KiwiTech on 8/31/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import MessageUI
import SwiftyUserDefaults

class WalletDetailViewController: UIViewController, SpinnerDisplayable, StaticViewDisplayable {
    
@IBOutlet weak var tableView: UITableView!

var walletTransactions: WalletTransaction?
var transactionDatasource = TransactionDetailDataSource()
var spinnerViewController: SpinnerViewController = SpinnerViewController()
var staticMessageViewController: FullScreenMessageViewController?
var transactionDetail: TransactionDetail?
var appType: ConnectedApp?
var transactionId: Int?
var isFromNotification: Bool? = false

override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setUpHeaderView()
}

func setUpHeaderView() {
  tableView.isHidden = true
  setUpDataSource()
}

override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  navigationController?.navigationBar.isHidden = false
  self.currentTabBar?.setBar(hidden: true, animated: false)
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
    let wallet = TabName.wallet.localized()
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.transactionDetailScreen(type: wallet))
}
    
override func viewWillDisappear(_ animated: Bool) {
  super.viewWillDisappear(animated)
  self.currentTabBar?.setBar(hidden: false, animated: false)
  Defaults[.shouldRefreshWallet] = false
}
    
func setUpDataSource() {
  view.backgroundColor = Constants.backgroundColor
  let nib = UINib(nibName: Constants.headerViewNib, bundle: nil)
  tableView.register(nib, forHeaderFooterViewReuseIdentifier: Constants.headerViewNib)
  tableView.dataSource = transactionDatasource
  tableView.delegate = transactionDatasource
  tableView.rowHeight = 64
  tableView.estimatedRowHeight = 64
  transactionDatasource.detailDelegate = self
  if let type = appType {
     getPartnersDetail(app: type)
  } else {
     getTransactionDetail()
  }
}
    
func updateData(detail: TransactionDetail) {
   hideSpinner()
   transactionDetail = detail
   updateTransactionModel(transactionDetail)
   transactionDatasource.transactionDetail = transactionDetail
   transactionDatasource.walletDetail = walletTransactions
   updateUI()
}
    
func updateTransactionModel(_ transactionDetail: TransactionDetail?) {
  guard let dataDetail = transactionDetail?.detailHeader?.map({$0.data.map({$0.filter({Utilities.isNotNil($0.value) == true})})}) else { return }
      if dataDetail.count == 1 {
        _ = dataDetail[0]?.map({$0.shouldShowTopCorners == true})
        _ = dataDetail[0]?.map({$0.shouldShowBottomCorners == true})
      }
      _ = dataDetail.map({$0?.first.map({$0.shouldShowTopCorners = true})})
      _ = dataDetail.map({$0?.last.map({$0.shouldShowBottomCorners = true})})
}
    
func updateUI() {
  tableView.reloadData()
  tableView.isHidden = false
 }
}

extension WalletDetailViewController: ErrorMessageSectionControllerDelegate {
func didTapActionButton() {
    getTransactionDetail()
  }
}

extension WalletDetailViewController: TransactionDelegate {
func didTapTransactionDetail(_ transaction: TransactionData) {
    let webContentViewController = WebContentViewController()
    webContentViewController.shouldHideBackButton = false
    if let detailUrl = transaction.detailURL {
        webContentViewController.startURL = URL(string: detailUrl)
        self.navigationController?.pushViewController(webContentViewController, animated: true)
    }
  }
    
func sendMailToSupport(_ transaction: TransactionData?, _ detail: TransactionDetail) {
    guard let transactionData = transaction else {
         guard let transactionId = detail.transactionID else { return }
         Router.shared.route(to: .support(isFromWallet: true, "\(transactionId)"), from: self,
                                           presentationType: .modal(presentationStyle: .pageSheet,
                                                                    transitionStyle: .coverVertical))
         return
     }
     if let jobId = transactionData.value as? String {
        Router.shared.route(to: .support(isFromWallet: true, jobId), from: self,
                                           presentationType: .modal(presentationStyle: .pageSheet,
                                                                    transitionStyle: .coverVertical))
     }
  }
}

extension WalletDetailViewController: MFMailComposeViewControllerDelegate {
func sendEmail(_ transactionId: String) {
  if MFMailComposeViewController.canSendMail() {
    let mail = MFMailComposeViewController()
    mail.mailComposeDelegate = self
    mail.setToRecipients([Constants.supportEmail])
    mail.setSubject("\(Constants.supportSubjectEmail)\(transactionId)")
    present(mail, animated: true)
  } else {}
}

func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
}
