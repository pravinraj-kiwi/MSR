//
//  WalletDatasource.swift
//  Contributor
//
//  Created by KiwiTech on 8/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import AFDateHelper

protocol RedemptionDelegate: class {
  func didTapRedeemButton(for balance: Balance)
  func didTapWalletDetail(_ transaction: WalletTransaction)
}

class WalletDatasource: NSObject, UITableViewDelegate, UITableViewDataSource {
var userTransactions = [GroupedSection<Date, WalletTransaction>]()
weak var datasourceDelegate: RedemptionDelegate?
let reedemCount = WalletListSection.reedemCount.rawValue
let reedemSection = WalletListSection.reedemSection.rawValue
    
func numberOfSections(in tableView: UITableView) -> Int {
    if userTransactions.isEmpty == true { return reedemCount + reedemCount}
    return reedemCount + userTransactions.map({$0.sectionItem}).count
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == reedemSection {
        return reedemCount
    }
    if userTransactions.isEmpty == true { return reedemCount }
    let section = userTransactions[section - reedemCount]
    return section.rows.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == reedemSection {
        let cell = tableView.dequeueReusableCell(with: WalletHeaderTableViewCell.self, for: indexPath)
        if let userWallet = UserManager.shared.wallet {
            cell.configureHeader(userWallet)
        }
        cell.delegate = self
        return cell
    }
    if userTransactions.isEmpty {
        let cell = tableView.dequeueReusableCell(with: WalletTransactionCell.self, for: indexPath)
        cell.transactionTitle.text = DynataDetail.noJobCompleted.localized()
        cell.imgArrow.isHidden = true
        cell.transactionStack.layer.cornerRadius = 12.0
        cell.divider.isHidden = true
        return cell
    }
    let cell = tableView.dequeueReusableCell(with: WalletTransactionCell.self, for: indexPath)
    if !userTransactions.isEmpty == true {
        let section = userTransactions[indexPath.section - reedemCount]
        let trasanction = section.rows[indexPath.row]
        cell.divider.isHidden = false
        cell.transactionStack.layer.cornerRadius = 0
        cell.transaction = trasanction
        cell.configure(trasanction)

    }
    return cell
}
    
func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let view = tableView.dequeueReusableHeaderFooterView(
                               withIdentifier: Constants.headerViewNib)
                               as? HeaderView else {
         return nil
     }
    if userTransactions.isEmpty == false {
    if section == reedemCount {
        view.topConstraint.constant = WalletList.topForFirstHeaderSec
    } else {
        view.topConstraint.constant = WalletList.topForHeaderSec
    }
      view.dateLabel.text = getHeaderTitle(section)
    } else {
       view.topConstraint.constant = WalletList.topForFirstHeaderSec
       view.dateLabel.text = DynataDetail.history.localized()
    }
    return view
}
    
func getHeaderTitle(_ section: Int) -> String? {
    if section == reedemSection {
        return nil
    }
    let section = userTransactions[section - reedemCount]
    let serverDate = section.sectionItem
    let diff = Calendar.current.dateComponents([.day], from: Date(), to: serverDate)
    if diff.day == 0 {
      return WalletTransactionText.todayText
    }
    if diff.day == -1 {
      return WalletTransactionText.yesterdayText
    }
    if serverDate.compare(.isThisMonth) {
      return WalletTransactionText.thisMonthText
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormatType.yearFormat.rawValue
    return dateFormatter.string(from: serverDate)
}
    
func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == reedemSection {
        return CGFloat(WalletList.zero)
    }
    if userTransactions.isEmpty == true { return WalletList.heightForFirstHeaderSec }
    if section == reedemCount {
        return WalletList.heightForFirstHeaderSec
    }
    return WalletList.heightForHeaderSec
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == reedemSection {
        return WalletList.heightForHeaderRowSec
    }
    return WalletList.heightForRowTranSec
  }
    
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == reedemSection {
        return
    }
    if userTransactions.isEmpty == false {
      let section = userTransactions[indexPath.section - reedemCount]
      let transaction = section.rows[indexPath.row]
      datasourceDelegate?.didTapWalletDetail(transaction)
    }
  }
}

extension WalletDatasource: RedemptionViewDelegate {
func didTapRedeemButton(for balance: Balance) {
    datasourceDelegate?.didTapRedeemButton(for: balance)
 }
}
