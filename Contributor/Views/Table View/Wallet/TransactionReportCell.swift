//
//  TransactionReportCell.swift
//  Contributor
//
//  Created by KiwiTech on 9/2/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol TransactionReportDelegate: class {
  func sendMailToSupport(_ transaction: TransactionData?, _ detail: TransactionDetail)
}

class TransactionReportCell: UITableViewCell {
  
var transactionDetail: TransactionDetail?
weak var reportDelegate: TransactionReportDelegate?
@IBOutlet weak var reportButton: UIButton!

override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    applyCommunityTheme()
}

override func setSelected(_ selected: Bool, animated: Bool) {
  super.setSelected(selected, animated: animated)
  // Configure the view for the selected state
}
    
@IBAction func clickToReport(_ sender: Any) {
    if let detail = transactionDetail {
      guard let data = detail.detailHeader?.map({$0.data})[0]?.filter({$0.label == Constants.jobId})[0] else {
        reportDelegate?.sendMailToSupport(nil, detail)
        return
      }
      reportDelegate?.sendMailToSupport(data, detail)
    }
  }
}

extension TransactionReportCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    reportButton.setTitleColor(colors.primary, for: .normal)
    reportButton.setTitle(WalletViewText.reportAnIssue.localized(), for: .normal)
  }
}
