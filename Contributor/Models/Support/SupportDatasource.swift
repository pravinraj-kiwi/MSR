//
//  SupportDatasource.swift
//  Contributor
//
//  Created by KiwiTech on 10/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol SupportDatasourceDelegate: class {
  func clickToSubmitFeedback(_ concern: String, message: String,
                             isEmailCopyNeeded: Bool)
  func updateTableCellHeight()
  func clickToOpenSupportURL(_ url: URL)
}

class SupportDatasource: NSObject, UITableViewDataSource, UITableViewDelegate {
 weak var delegate: SupportDatasourceDelegate?
 var isFromWalletDetail = false

 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return SupportList.noOfRows
 }
    
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == SupportList.firstIndex {
        let cell = tableView.dequeueReusableCell(with: SupportHeaderCell.self, for: indexPath)
        cell.supportDelegate = self
        return cell
    }
   let cell = tableView.dequeueReusableCell(with: SupportFeedbackCell.self, for: indexPath)
   cell.isFromWalletDetail = isFromWalletDetail
   cell.updateInitialUI()
   cell.delegate = self
   return cell
 }
  
 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == SupportList.firstIndex {
        return SupportList.heightForHeaderCell
    }
    return UITableView.automaticDimension
 }
}

extension SupportDatasource: SupportDelegate {
 func clickToSubmitFeedback(_ concern: String, message: String,
                            isEmailCopyNeeded: Bool) {
    delegate?.clickToSubmitFeedback(concern, message: message,
                                    isEmailCopyNeeded: isEmailCopyNeeded)
 }
    
 func updateCellHeight() {
    delegate?.updateTableCellHeight()
 }
}

extension SupportDatasource: SupportHeaderDelegate {
 func clickToOpenSupportURL(_ url: URL) {
    delegate?.clickToOpenSupportURL(url)
 }
}
