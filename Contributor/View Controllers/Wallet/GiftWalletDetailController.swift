//
//  GiftWalletDetailController.swift
//  Contributor
//
//  Created by KiwiTech on 10/29/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class GiftWalletDetailController: UIViewController {

 @IBOutlet weak var reviewButton: UIButton!
 @IBOutlet weak var referImageView: UIImageView!
 @IBOutlet weak var referHeaderLabel: UILabel!
 @IBOutlet weak var referSubHeaderLabel: UILabel!
    
 var walletTransactions: WalletTransaction?
    
 override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    applyCommunityTheme()
    updateUI()
 }
    
 override func viewWillAppear(_ animated: Bool) {
   super.viewWillAppear(animated)
   navigationController?.navigationBar.isHidden = false
   self.currentTabBar?.setBar(hidden: true, animated: false)
 }
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  let giftCardWallet = GiftCardViewText.title.localized()
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.transactionDetailScreen(type: giftCardWallet))
}
    
 override func viewWillDisappear(_ animated: Bool) {
   super.viewWillDisappear(animated)
   self.currentTabBar?.setBar(hidden: false, animated: false)
   Defaults[.shouldRefreshWallet] = false
 }

 func updateUI() {
   referImageView.image = updateImage()
 }
    
func updateImage() -> UIImage {
  if walletTransactions?.amountMSR == -1000 {
    referHeaderLabel.text = "\(GiftCardViewText.successRedeem.localized()) 1000 MSR"
    return Image.tenRedeem.value
  }
  if walletTransactions?.amountMSR == -2500 {
    referHeaderLabel.text = "\(GiftCardViewText.successRedeem.localized()) 2500 MSR"
    return Image.twentyRedeem.value
  }
  if walletTransactions?.amountMSR == -5000 {
    referHeaderLabel.text = "\(GiftCardViewText.successRedeem.localized()) 5000 MSR"
    return Image.fiftyRedeem.value
  }
  return UIImage()
 }
    
@IBAction func clickToLeaveReview(_ sender: Any) {
   if let reviewURL = URL(string: Constants.appStoreURL),
    UIApplication.shared.canOpenURL(reviewURL) {
    if #available(iOS 10.0, *) {
       UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
    } else {
       UIApplication.shared.openURL(reviewURL)
     }
   }
 }
}

extension GiftWalletDetailController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    reviewButton.backgroundColor = colors.primary
    referHeaderLabel.textColor = colors.primary
  }
}
