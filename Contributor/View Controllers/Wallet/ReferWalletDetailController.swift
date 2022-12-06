//
//  ReferWalletDetail Controller.swift
//  Contributor
//
//  Created by KiwiTech on 10/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class ReferWalletDetailController: UIViewController {

 @IBOutlet weak var referFriendButton: UIButton!
 @IBOutlet weak var referHeaderLabel: UILabel!

 override func viewDidLoad() {
  super.viewDidLoad()
  // Do any additional setup after loading the view.
    referHeaderLabel.text = "\(GiftCardViewText.referHeaderText.localized())"
    applyCommunityTheme()
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  let referWallet = "refer"
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.transactionDetailScreen(type: referWallet))
}
    
override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  navigationController?.navigationBar.isHidden = false
  self.currentTabBar?.setBar(hidden: true, animated: false)
}
   
override func viewWillDisappear(_ animated: Bool) {
  super.viewWillDisappear(animated)
  self.currentTabBar?.setBar(hidden: false, animated: false)
  Defaults[.shouldRefreshWallet] = false
}
    
@IBAction func clickToReferAFriend(_ sender: Any) {
   guard let code = UserManager.shared.user?.inviteCode else { return }
   let shareText = ReferFriendViewText.shareText
        + ReferFriendViewText.sharePreixText
        + " \(code) "
        + ReferFriendViewText.shareSuffixText
   let activityItems: [Any] = [shareText,
      URL(string: "\(Constants.baseContributorURLString)/i/\(code)")!
    ]
    let activityViewController = UIActivityViewController(activityItems: activityItems,
                                                          applicationActivities: nil)
    activityViewController.completionWithItemsHandler = {
      activityType, completed, returnedItems, error  in
      AnalyticsManager.shared.log(event: .friendReferred)
    }
    present(activityViewController, animated: true, completion: nil)
   }
}

extension ReferWalletDetailController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    referFriendButton.backgroundColor = colors.primary
    referHeaderLabel.textColor = colors.primary
  }
}
