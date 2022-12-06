//
//  WalletDetailDataSource.swift
//  Contributor
//
//  Created by KiwiTech on 8/31/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import AFDateHelper

protocol TransactionDelegate: class {
  func didTapTransactionDetail(_ transaction: TransactionData)
  func sendMailToSupport(_ transaction: TransactionData?, _ detail: TransactionDetail)
}

class TransactionDetailDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
var transactionDetail: TransactionDetail?
weak var detailDelegate: TransactionDelegate?
let transDetailSection = TransactionDetailSection.detailSection.rawValue
let transHeaderSection = TransactionDetailSection.transForHeaderSection.rawValue
var walletDetail: WalletTransaction?
    
func numberOfSections(in tableView: UITableView) -> Int {
    if let sections = transactionDetail?.detailHeader {
        return transDetailSection + sections.count + transDetailSection
    }
    return transHeaderSection
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == transHeaderSection {
        return transDetailSection
    }
    if let sectionHeader = transactionDetail?.detailHeader?.count, section <= sectionHeader {
        if let sections = transactionDetail?.detailHeader {
            let data = sections.map({$0.data.map({$0.filter({Utilities.isNotNil($0.value) == true})})})
            if let sectionData = data[section - transDetailSection] {
                return sectionData.count
            }
        }
    }
    return transDetailSection
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == transHeaderSection {
        let cell = tableView.dequeueReusableCell(with: TransactionDetailHeaderCell.self, for: indexPath)
        guard let detail = transactionDetail else { return UITableViewCell() }
        cell.walletTransactions = walletDetail
        cell.configure(detail)
        return cell
    }
    if let sectionHeader = transactionDetail?.detailHeader?.count, indexPath.section <= sectionHeader {
        let cell = tableView.dequeueReusableCell(with: TransactionDetailCell.self, for: indexPath)
        let transactionRow = transactionDetail?.detailHeader?[indexPath.section - transDetailSection]
        guard let data = transactionRow.map({$0.data.map({$0.filter({Utilities.isNotNil($0.value) == true})})})
        else { return UITableViewCell() }
        guard let trasanctionDetail = data?[indexPath.row] else { return UITableViewCell() }
        cell.detail = trasanctionDetail
        cell.configure(trasanctionDetail)
        return cell
    }
    let cell = tableView.dequeueReusableCell(with: TransactionReportCell.self, for: indexPath)
    guard let detail = transactionDetail else { return UITableViewCell() }
    cell.transactionDetail = detail
    cell.reportDelegate = self
    return cell
}
    
func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let view = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: Constants.headerViewNib)
                               as? HeaderView else {
         return nil
     }
    if section == transDetailSection {
        view.topConstraint.constant = TransactionDetails.topForFirstHeaderSec
    } else {
        view.topConstraint.constant = TransactionDetails.topForHeaderSec
    }
    view.dateLabel.text = getHeaderTitle(section)
    return view
}
    
func getHeaderTitle(_ section: Int) -> String? {
    if section == transHeaderSection {
        return nil
    }
    if let sectionHeader = transactionDetail?.detailHeader?.count, section <= sectionHeader {
       let transactionRow = transactionDetail?.detailHeader?[section - transDetailSection]
       let headingText = transactionRow?.heading
       return headingText
    }
    return nil
}
    
func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == transHeaderSection {
        return CGFloat(TransactionDetails.zero)
    }
    if let sectionHeader = transactionDetail?.detailHeader?.count, section <= sectionHeader {
        if section == transDetailSection {
            return TransactionDetails.heightForFirstHeaderSec
        }
        return TransactionDetails.heightForHeaderSec
    }
    return CGFloat(TransactionDetails.zero)
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == transHeaderSection {
        return TransactionDetails.heightForHeaderRowSec
    }
    if let sectionHeader = transactionDetail?.detailHeader?.count, indexPath.section <= sectionHeader {
        return TransactionDetails.heightForRowReportIssue
    }
    return TransactionDetails.heightForRowTranDetailSec
  }
    
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  if indexPath.section == transHeaderSection {
    return
  }
  if let sectionHeader = transactionDetail?.detailHeader?.count, indexPath.section <= sectionHeader {
    let transactionRow = transactionDetail?.detailHeader?[indexPath.section - transDetailSection]
    guard let data = transactionRow.map({$0.data.map({$0.filter({Utilities.isNotNil($0.value) == true})})})
    else { return }
    guard let trasanctionDetail = data?[indexPath.row] else { return  }
    if trasanctionDetail.detailsAvailable == true {
        detailDelegate?.didTapTransactionDetail(trasanctionDetail)
      }
    }
  }
}

extension TransactionDetailDataSource: TransactionReportDelegate {
func sendMailToSupport(_ transaction: TransactionData?, _ detail: TransactionDetail) {
    detailDelegate?.sendMailToSupport(transaction, detail)
  }
}
