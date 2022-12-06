//
//  WalletHeaderTableViewCell.swift
//  Contributor
//
//  Created by KiwiTech on 8/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol RedemptionViewDelegate: class {
  func didTapRedeemButton(for balance: Balance)
}

class WalletHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var balanceInfoLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceFiatLabel: UILabel!
    @IBOutlet weak var giftCardButton: UIButton!
    @IBOutlet weak var paypalButton: UIButton!
    @IBOutlet weak var redeemtypeLabel: UILabel!


let generator = UIImpactFeedbackGenerator(style: .light)
weak var delegate: RedemptionViewDelegate?
    
override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    addListeners()
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
}

func addListeners() {
  NotificationCenter.default.addObserver(self, selector: #selector(onBalanceUpdated),
                                         name: NSNotification.Name.userChanged, object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(onBalanceUpdated),
                                         name: NSNotification.Name.balanceChanged, object: nil)
}
    
func configureHeader(_ wallet: Wallet) {
    balanceInfoLabel.text = WalletCell.currentBalanceText.localized()
    giftCardButton.isHidden = true
    paypalButton.isHidden = true
  balanceLabel.text = wallet.balanceMSRString
  balanceFiatLabel.text = wallet.balanceFiatString
    if wallet.hasMultipleBalances {
        backgroundColor = Color.veryLightBorder.value
        redeemtypeLabel.text = Text.redeemYourPoints.localized()
        for tmpObj in  wallet.user.balances {
            if tmpObj.balanceType == PaymentType.giftCard.rawValue {
                giftCardButton.isHidden = false
                giftCardButton.setTitle(tmpObj.walletTitle, for: .normal)
            }
            if tmpObj.balanceType == PaymentType.paypal.rawValue {
                paypalButton.isHidden = false
                paypalButton.setTitle(tmpObj.walletTitle, for: .normal)
            }
        }
    } else {
        redeemtypeLabel.text = ""
        giftCardButton.isHidden = false
        giftCardButton.setTitle(Text.redeemButtonTitleText.capitalized.localized(), for: .normal)
    }
    applyCommunityTheme()
 }
    
@objc func onBalanceUpdated() {
  if let wallet = UserManager.shared.wallet {
    configureHeader(wallet)
  }
}
    
@IBAction func clickToReedemGiftCard(_ sender: Any) {
   guard let balance = UserManager.shared.user?.balances.first else {
     return
   }
   generator.impactOccurred()
   delegate?.didTapRedeemButton(for: balance)
  }
@IBAction func clickToReedemPayPal(_ sender: Any) {

    guard let balance =  UserManager.shared.user?.balances.filter({$0.balanceType == PaymentType.paypal.rawValue}).first else {
        return
    }
   generator.impactOccurred()
    delegate?.didTapRedeemButton(for: balance)
  }
}

extension WalletHeaderTableViewCell: CommunityThemeConfigurable {
    @objc func applyCommunityTheme() {
        guard let community = UserManager.shared.user?.selectedCommunity,
              let colors = community.colors else {
            return
        }
        giftCardButton.setBackgroundColor(color: colors.primary, forState: .normal)
        paypalButton.setBackgroundColor(color: colors.primary, forState: .normal)
        
    }
}
