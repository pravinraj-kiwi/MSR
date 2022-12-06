//
//  WalletView+Delegate.swift
//  Contributor
//
//  Created by KiwiTech on 8/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import WebKit

extension WalletListViewController: RedemptionDelegate {
func didTapWalletDetail(_ transaction: WalletTransaction) {
  switch transaction.type {
  case .referalBonusTrans:
    Router.shared.route(
        to: Route.referWalletDetail(nil, transaction),
        from: self,
        presentationType: .push(surveyToolBarNeeded: false, fromTabBar: true)
      )
  case .giftTransDetail:
    Router.shared.route(
        to: Route.giftWalletDetail(nil, transaction),
        from: self,
        presentationType: .push(surveyToolBarNeeded: false, fromTabBar: true)
      )
  default:
    Router.shared.route(
        to: Route.walletDetail(nil, transaction),
        from: self,
        presentationType: .push(surveyToolBarNeeded: false, fromTabBar: true)
      )
    }
    hidesBottomBarWhenPushed = true
}
    
func didTapRedeemButton(for balance: Balance) {
  var showAlert = false
  var alertTitle = ""
  var alertMessage = ""
    
  if let user = UserManager.shared.user {
    let data = updateAlertOnUserExist(user, balance)
    alertTitle = data.0
    alertMessage = data.1
    showAlert = data.2
  } else {
    showAlert = true
    alertTitle = WalletViewText.noAccountAlertTitle
    alertMessage = WalletViewText.noAccountAlertMessage
  }
    
  if showAlert {
    let alert = UIAlertController(title: alertTitle,
                                  message: alertMessage,
                                  preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: Text.ok.localized(), style: .cancel, handler: { _ in
      alert.dismiss(animated: true, completion: nil)
    }))
    present(alert, animated: true, completion: nil)
   }
  }
}

extension WalletListViewController {
@objc func goToWalletDetail(_ notification: Notification) {
    if let transactionId = notification.userInfo?["transactionID"] as? Int {
        Router.shared.route(
            to: Route.walletDetail(nil, nil, transactionId, isFromNotif: true),
            from: self,
            presentationType: .push(surveyToolBarNeeded: false, fromTabBar: true)
        )
    }
  }
}

extension WalletListViewController {
 func showAlertData(_ balance: Balance) {
   let alerter = Alerter(viewController: self)
   let messageHolder = MessageHolder(
    message: Message.redeemGenericRewardAlert,
    customValues: [
     "TYPE": balance.walletTitle,
     "MSR": balance.balanceMSR.formattedMSRString]
    )
    alerter.alert(
      messageHolder: messageHolder,
      confirmButtonTitle: Text.yes.localized(),
      cancelButtonTitle: Text.cancel.localized(),
      onConfirm: {
        self.navigateToReedemView(balance)
      },
      onCancel: nil
    )
 }
    
func updateAlertOnUserExist(_ user: User, _ balance: Balance) -> (String, String, Bool) {
 if let _ = user.country, let _ = user.currency {
    if balance.isDefaultBalance || balance.balanceType == PaymentType.paypal.rawValue {
        let paymentType = balance.paymentType
        navigateToGiftCard(type: paymentType)
   } else {
      showAlertData(balance)
   }
 } else {
   if user.isFraudSuspect {
     return (WalletViewText.fraudAlertTitle, WalletViewText.fraudAlertMessage, true)
   } else {
     return (WalletViewText.noAccountAlertTitle, WalletViewText.noAccountAlertMessage, true)
   }
  }
  return("", "", false)
}
    
func navigateToReedemView(_ balance: Balance) {
    Router.shared.route(
      to: Route.redeemGenericReward(balance: balance),
      from: self,
      presentationType: .modal(presentationStyle: .overCurrentContext, transitionStyle: .crossDissolve)
    )
}
    
    func navigateToGiftCard(type: PaymentType) {
    Router.shared.route(
      to: Route.showGiftCards(option: type),
      from: self,
      presentationType: .modal(presentationStyle: .fullScreen, transitionStyle: .coverVertical)
    )
 }
}

extension WalletListViewController: TopHeaderCollectionViewCellDelegate {
 func didTapSettingsButton() {
  if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
   }
   Router.shared.route(to: Route.settings, from: self,
                       presentationType: .modal(presentationStyle: .fullScreen, transitionStyle: .coverVertical))
 }
}

extension WalletListViewController: Tabbable {
  var tabName: String {
    return TabName.wallet.localized()
  }
  
  var tabImage: Image {
    return Image.walletIcon
  }
  
  var tabHighlightedImage: Image {
    return Image.walletIcon
  }
}

extension WalletListViewController: WebContentDelegate {
func didFinishNavigation(navigationAction: WKNavigationAction) {
    if let clickedUrl = navigationAction.request.url?.absoluteString,
        clickedUrl == Constants.maintananceRefreshButtonUrl {
        Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
            if isSuccess == false { return }
            guard let this = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: NSNotification.Name.refreshWebview, object: nil, userInfo: nil)
            }
            if measureAppStatus == .available {
                if this.isMaintanencePageDisplayed == true {
                    this.isMaintanencePageDisplayed = false
                }
                this.dismissSelf()
                this.refresh()
                this.isMaintanencePageDisplayed = false
            }
        }
     }
  }
}

extension WalletListViewController: ErrorMessageSectionControllerDelegate {
func didTapActionButton() {
    refresh()
  }
}
