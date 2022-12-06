//
//  WalletTrasactionCell.swift
//  Contributor
//
//  Created by KiwiTech on 8/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class WalletTransactionCell: UITableViewCell {

@IBOutlet weak var transactionTitle: UILabel!
@IBOutlet weak var transactionDescription: UILabel!
@IBOutlet weak var transactionPrice: UILabel!
@IBOutlet weak var imgArrow: UIImageView!
@IBOutlet weak var transactionStack: UIView!
@IBOutlet weak var divider: UIView!

var transaction: WalletTransaction?
    
override func awakeFromNib() {
  super.awakeFromNib()
  // Initialization code
  transactionStack.backgroundColor = Utilities.getRgbColor(116.0, 116.0, 128.0, 0.08)
}
    
func configure(_ transaction: WalletTransaction) {
  transactionTitle.text = transaction.title
  if let desc = transaction.transactionDescription {
    transactionDescription.text = desc
  } else {
    transactionDescription.text = ""
  }
  if let amount = transaction.amountMSR {
    transactionPrice.text = "\(amount.stringWithCommas) MSR"
  } else {
    transactionPrice.text = ""
  }
  if transaction.descriptionStyle == TransactionListDisplay.danger.display {
    transactionDescription.textColor = Utilities.getRgbColor(215.0, 87.0, 102.0)
  } else {
    transactionDescription.textColor = .black
  }
  imgArrow.isHidden = false
  updateCorners()
  applyCommunityTheme()
}
    
func updateCorners() {
  if let topCorner = transaction?.shouldShowTopCorners, topCorner == true,
     let bottomCorner = transaction?.shouldShowBottomCorners, bottomCorner == false {
    transactionStack.roundCorners(corners: [.topLeft, .topRight], radius: 12.0)
    divider.backgroundColor = Utilities.getRgbColor(228.0, 228.0, 228.0)
  }
  if let bottomCorner = transaction?.shouldShowBottomCorners, bottomCorner == true,
     let topCorner = transaction?.shouldShowTopCorners, topCorner == false {
    transactionStack.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12.0)
    divider.backgroundColor = .clear
  }
  if let topCorner = transaction?.shouldShowTopCorners, topCorner == true,
    let bottomCorner = transaction?.shouldShowBottomCorners, bottomCorner == true {
    transactionStack.roundCorners(corners: [.allCorners], radius: 12.0)
    divider.backgroundColor = .clear
  }
  if let topCorner = transaction?.shouldShowTopCorners, topCorner == false,
    let bottomCorner = transaction?.shouldShowBottomCorners, bottomCorner == false {
    transactionStack.layer.mask = nil
    divider.backgroundColor = Utilities.getRgbColor(228.0, 228.0, 228.0)
  }
}
    
override func layoutSubviews() {
  super.layoutSubviews()
  updateCorners()
 }
}

extension UIView {
func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                            cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}

extension WalletTransactionCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    switch transaction?.titleStyle {
    case TransactionListDisplay.primary.display:
        transactionTitle.textColor = colors.primary
        transactionPrice.textColor = colors.primary
    default:
        transactionTitle.textColor = .black
        transactionPrice.textColor = Utilities.getRgbColor(44.0, 44.0, 44.0)
    }
  }
}
