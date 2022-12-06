//
//  SupportViewController.swift
//  Contributor
//
//  Created by KiwiTech on 10/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya

class SupportViewController: UIViewController {
    
 @IBOutlet weak var supportTableView: UITableView!
 private var supportDatasource = SupportDatasource()
 @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
 var isFromWalletDetail = false
 var transactionId: String? = ""
    
 override func viewDidLoad() {
   super.viewDidLoad()
    // Do any additional setup after loading the view.
    activityIndicator.updateIndicatorView(self, hidden: true)
    setupNavbar()
    setUpDataSource()
}
    
func setupNavbar() {
  setTitle(Text.supportText.localized())
  if let _ = self.presentingViewController {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: Text.close.localized(), style: UIBarButtonItem.Style.plain,
                                                         target: self, action: #selector(close))
    navigationItem.leftBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 17), for: .normal)
  }
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.supportScreen)
}

@objc func close() {
  dismissSelf()
}
    
func registerNib() {
 supportTableView.register(cellType: SupportHeaderCell.self)
 supportTableView.register(cellType: SupportFeedbackCell.self)
 supportTableView.rowHeight = 200
 supportTableView.estimatedRowHeight = 200
}
   
func setUpDataSource() {
 registerNib()
 supportTableView.dataSource = supportDatasource
 supportTableView.delegate = supportDatasource
 supportDatasource.isFromWalletDetail = isFromWalletDetail
 supportDatasource.delegate = self
 supportTableView.reloadData()
  }
}

extension SupportViewController: SupportDatasourceDelegate {
func clickToSubmitFeedback(_ concern: String, message: String, isEmailCopyNeeded: Bool) {
  if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
   }
  activityIndicator.updateIndicatorView(self, hidden: false)
  var concernText = concern
  if isFromWalletDetail, let jobId = transactionId {
    concernText = "\(concern) (\(jobId))"
  }
  NetworkManager.shared.sendSupportEmail(selectedConcern: concernText, message,
                                           shouldSendEmailCopy: isEmailCopyNeeded) { [weak self] (error) in
    guard let this = self else { return }
    this.activityIndicator.updateIndicatorView(this, hidden: true)
    if (error as? MoyaError) != nil {
        let toaster = Toaster(view: this.view)
        toaster.toast(message: SignUpViewText.requestError.localized())
     } else {
        this.supportTableView.beginUpdates()
        this.supportTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        this.supportTableView.endUpdates()
        NotificationCenter.default.post(name: .showSupportThankView, object: nil, userInfo: nil)
     }
  }
}
    
func clickToOpenSupportURL(_ url: URL) {
    Helper.clickToOpenUrl(url, controller: self, isFromSupport: true)
}

func updateTableCellHeight() {
  supportTableView.beginUpdates()
  supportTableView.endUpdates()
 }
}
