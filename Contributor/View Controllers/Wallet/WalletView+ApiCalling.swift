//
//  WalletView+ApiCalling.swift
//  Contributor
//
//  Created by KiwiTech on 8/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension WalletListViewController {
func fetchBalance(completion: (() -> Void)? = nil) {
 NetworkManager.shared.reloadCurrentUser { [weak self] (error) in
  guard let this = self else {
    return
  }
  if let error = error {
    this.fetchBalanceError = error
    completion?()

  } else {
    this.fetchBalanceError = nil
    if let user = UserManager.shared.user {
      this.balancesHolder = BalancesHolder(balances: user.balances)
    }
    completion?()
  }
 }
}
  
func fetchExchangeRates(completion: (() -> Void)? = nil) {
 NetworkManager.shared.getExchangeRates(completion: { [weak self] (_, error) in
  guard let this = self else {
    return
  }
  if let error = error {
    this.fetchExchangeRatesError = error
    completion?()
  } else {
    this.fetchExchangeRatesError = nil
    completion?()
  }
  })
}

@objc func fetchTransactions(page: Int = 0, completion: (() -> Void)? = nil) {
 NetworkManager.shared.getWalletTransactions(page: page) { [weak self] (items, error) in
  guard let this = self else {
    return
  }
  if let error = error {
    this.fetchTransactionsError = error
    completion?()
  } else {
    this.walletTransactionsHolder = WalletTransactionsHolder(transactions: items)
    if let transactionsList = this.walletTransactionsHolder?.transactions {
        this.getFilterList(transactionsList) { (_) in
            completion!()
        }
       completion?()
    }
    this.fetchTransactionsError = nil
  }
 }
}
     
func checkIfMeasureAppAvailable(completion: @escaping (Bool) -> Void) {
  Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
   if isSuccess == false { return }
    guard let this = self else { return }
    if measureAppStatus == .available {
       if this.isMaintanencePageDisplayed == true {
            this.isMaintanencePageDisplayed = false
        }
       completion(true)
    } else if measureAppStatus == .unavailable && this.isMaintanencePageDisplayed == false {
       Helper.clickToOpenUrl(Constants.statusDownBaseURL,
                 controller: this,
                 presentationStyle: .fullScreen)
      this.isMaintanencePageDisplayed = true
      completion(false)
   }
  }
}
  
@objc func refresh(isManual: Bool = false) {
  if ConnectivityUtils.isConnectedToNetwork() == false {
      refreshControl.endRefreshing()
      Helper.showNoNetworkAlert(controller: self)
      return
  }
  if isManual {
    refreshControl.beginRefreshing()
  } else {
    tableView.isHidden = true
    showSpinner()
  }
  checkIfMeasureAppAvailable { (isAvailable) in
    if isAvailable {
        self.resetValues()
        self.callWalletApi(isManual: isManual)
    }
  }
}
    
func resetValues() {
  transactionItem = []
  walletDatasource.userTransactions = []
  transactionItem.removeAll()
  walletDatasource.userTransactions.removeAll()
}
    
func callWalletApi(isManual: Bool = false) {
  if ConnectivityUtils.isConnectedToNetwork() == false {
    refreshControl.endRefreshing()
    Helper.showNoNetworkAlert(controller: self)
    return
  }
 let serialQueue = DispatchQueue(label: "wallet.serial.queue")
 serialQueue.async {
   self.fetchBalance {
     self.fetchExchangeRates {
     self.fetchTransactions {
        DispatchQueue.main.async {
          [weak self] in
          guard let this = self else {
            return
          }
           this.updateTableUI()
          }
        }
      }
    }
  }
}

func updateTableUI() {
 hideSpinner()
 tableView.isHidden = false
 headerView.isHidden = false
 if transactionItem.isEmpty == false {
    walletDatasource.userTransactions = transactionItem
  }
  tableView.reloadData()
  refreshControl.endRefreshing()
}
  
@objc func refreshBalance() {
    refresh(isManual: true)
  }
}
