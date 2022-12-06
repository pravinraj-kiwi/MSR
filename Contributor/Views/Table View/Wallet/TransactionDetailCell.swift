//
//  TransactionDetailCell.swift
//  Contributor
//
//  Created by KiwiTech on 8/31/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Cosmos

class TransactionDetailCell: UITableViewCell {
    
@IBOutlet weak var transactionTitle: UILabel!
@IBOutlet weak var transactionValue: UILabel!
@IBOutlet weak var imgArrow: UIImageView!
@IBOutlet weak var divider: UIView!
@IBOutlet weak var transactionStack: UIView!
@IBOutlet weak var ratingView: CosmosView!

var detail: TransactionData?
    
override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    transactionStack.backgroundColor = Utilities.getRgbColor(116.0, 116.0, 128.0, 0.08)
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
}
        
override func draw(_ rect: CGRect) {
  super.draw(rect)
    updateCorners()
}

func configure(_ detail: TransactionData) {
   transactionTitle.text = detail.label
   if let amount = detail.value as? String {
       transactionValue.text = amount
   } else {
      transactionValue.text = ""
   }
   updateRatingSection(detail)
   if detail.detailsAvailable == true {
      imgArrow.isHidden = false
   } else {
      imgArrow.isHidden = true
   }
   applyCommunityTheme()
}
    
func updateRatingSection(_ detail: TransactionData) {
  if detail.type == Constants.ratingType,
    let value = detail.value as? Int {
    ratingView.isHidden = false
    ratingView.rating = Double(value)
    transactionValue.isHidden = true
  } else {
    ratingView.isHidden = true
    transactionValue.isHidden = false
  }
 }
}

extension TransactionDetailCell {
func updateCorners() {
  if let topCorner = detail?.shouldShowTopCorners, topCorner == true {
    transactionStack.roundCorners(corners: [.topLeft, .topRight], radius: 12.0)
    divider.backgroundColor = Utilities.getRgbColor(228.0, 228.0, 228.0)
  }
  if let bottomCorner = detail?.shouldShowBottomCorners, bottomCorner == true {
    transactionStack.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12.0)
    divider.backgroundColor = .clear
  }
  if let topCorner = detail?.shouldShowTopCorners, topCorner == true,
    let bottomCorner = detail?.shouldShowBottomCorners, bottomCorner == true {
    transactionStack.roundCorners(corners: [.allCorners], radius: 12.0)
    divider.backgroundColor = .clear
  }
  if let topCorner = detail?.shouldShowTopCorners, topCorner == false,
    let bottomCorner = detail?.shouldShowBottomCorners, bottomCorner == false {
    transactionStack.layer.mask = nil
    divider.backgroundColor = Utilities.getRgbColor(228.0, 228.0, 228.0)
  }
 }
}

extension TransactionDetailCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    if detail?.type == Constants.ratingType {
        transactionTitle.textColor = .black
        return
    }
    switch detail?.style {
    case TransactionListDisplay.primary.display:
        transactionTitle.textColor = colors.primary
        transactionValue.textColor = colors.primary
    case TransactionListDisplay.danger.display:
        transactionTitle.textColor = .black
        transactionValue.textColor = Utilities.getRgbColor(215.0, 87.0, 102.0)
    default:
        transactionTitle.textColor = .black
        transactionValue.textColor = Utilities.getRgbColor(44.0, 44.0, 44.0)
    }
  }
}
