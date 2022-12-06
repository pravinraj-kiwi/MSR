//
//  WalletDetailHeaderCell.swift
//  Contributor
//
//  Created by KiwiTech on 8/31/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class TransactionDetailHeaderCell: UITableViewCell {

@IBOutlet weak var transactionTitle: UILabel!
@IBOutlet weak var transactionSubTitle: UILabel!
@IBOutlet weak var imgHeader: UIImageView!
var walletTransactions: WalletTransaction?
    
override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
}

func walletDetailDate(_ dateStr: String) -> String? {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = DateFormatType.serverDateFormat.rawValue
  dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
  if let date = dateFormatter.date(from: dateStr) {
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = DateFormatType.shortFormat.rawValue
    return dateFormatter.string(from: date)
  }
 return nil
}
    
func configure(_ detail: TransactionDetail) {
    transactionTitle.text = detail.title
    if let detailDate = walletTransactions?.date {
      transactionSubTitle.text = walletDetailDate(detailDate)
    }
    if let icon = detail.titleIcon, icon == ConnectedApp.pollfish.rawValue {
        imgHeader.image = Image.walletpollfish.value
    }
    if let icon = detail.titleIcon, icon == ConnectedApp.dynata.rawValue {
        imgHeader.image = Image.walletdynata.value
    }
    if let icon = detail.titleIcon, icon == ConnectedApp.kantar.rawValue {
        imgHeader.image = Image.walletcint.value
    }
    if let icon = detail.titleIcon, icon == Constants.msrSymbol {
        imgHeader.image = Image.walletmsr.value
    }
  }
}
