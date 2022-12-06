//
//  ReferFriendSuccessController.swift
//  Contributor
//
//  Created by KiwiTech on 10/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyUserDefaults
protocol RedeemCompletionDelegate: class {
    func redeemptionComplete()
}
class ReferFriendSuccessController: UIViewController, SpinnerDisplayable, StaticViewDisplayable {
    
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var referImageView: UIImageView!
    @IBOutlet weak var referHeaderLabel: UILabel!
    @IBOutlet weak var referSubHeaderLabel: UILabel!
    @IBOutlet weak var referView: UIView!
    weak var delegate: RedeemCompletionDelegate?

    var redeemOption: GiftCardRedemptionOption?
    var spinnerViewController: SpinnerViewController = SpinnerViewController()
    var staticMessageViewController: FullScreenMessageViewController?
    var redemptionType: PaymentType = .giftCard
    var payPalEmail: String? = nil
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Defaults[.shouldRefreshWallet] = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        applyCommunityTheme()
        setUpNavBar(Text.navBack.localized())
        referView.isHidden = true
        redeem()
    }
    
    override func clickToMoveBack() {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.redeemptionComplete()
    }
    
    func redeem() {
        showSpinner()
        guard let redeemOption = redeemOption else { return }
        NetworkManager.shared.redeemGiftCard(redemptionType: redemptionType,
                                             email: payPalEmail,
                                             redeemOption) { [weak self] (_, error) in
            guard let this = self else {
                return
            }
            this.hideSpinner()
            if let _ = error {
                let message = MessageHolder(message: Message.genericActionError)
                this.show(staticMessage: message)
            }
            else {
                this.referView.isHidden = false
                this.referImageView.image = this.updateImage()
                this.referHeaderLabel.text = "\(GiftCardViewText.successRedeem.localized()) \(this.getRedeemValue())"
                NotificationCenter.default.post(name: NSNotification.Name.giftCardRedeemed, object: nil, userInfo: nil)
            }
        }
    }
    
    func getRedeemValue() -> String {
       // let currency = UserManager.shared.user?.currency ?? .USD
        if let amount = redeemOption?.formattedFiatValue {
            return "\(amount)"
        }
        return ""
    }
    
    func updateImage() -> UIImage {
        if redeemOption?.localFiatValue == 10 {
            return Image.tenRedeem.value
        }
        if redeemOption?.localFiatValue == 25 {
            return Image.twentyRedeem.value
        }
        if redeemOption?.localFiatValue == 50 {
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

extension ReferFriendSuccessController: MessageViewControllerDelegate {
    func didTapActionButton() {
        hideStaticMessage()
        redeem()
    }
}

extension ReferFriendSuccessController: CommunityThemeConfigurable {
    @objc func applyCommunityTheme() {
        guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
            return
        }
        reviewButton.backgroundColor = colors.primary
        referHeaderLabel.textColor = colors.primary
    }
}
