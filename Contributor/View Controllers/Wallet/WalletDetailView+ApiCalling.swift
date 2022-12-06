//
//  WalletDetailView+ApiCalling.swift
//  Contributor
//
//  Created by KiwiTech on 9/3/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension WalletDetailViewController {

func getTransId() -> Int? {
  if let isNotif = isFromNotification, isNotif == true {
    if let transactionId = transactionId {
     return transactionId
    }
  } else {
    if let transId = walletTransactions?.transactionID {
      return transId
    }
  }
 return nil
}

func getTransactionDetail() {
  if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
  }
  showSpinner()
  guard let transactionId = getTransId() else { return }
  NetworkManager.shared.getTransactionDetail(transactionId) { [weak self] (detailData, _) in
    guard let this = self else { return }
    guard let detail = detailData else { return }
    this.updateData(detail: detail)
  }
}

func getPartnersDetail(app: ConnectedApp) {
  if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
  }
  if let transactionId = walletTransactions?.transactionID {
    showSpinner()
    NetworkManager.shared.getPartnerJobDetail(app, transactionId) { [weak self] (detailData, _) in
        guard let this = self else { return }
        guard let detail = detailData else { return }
        this.updateData(detail: detail)
      }
   }
  }
}
