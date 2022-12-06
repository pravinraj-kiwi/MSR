//
//  FeedController+ReferFriendView.swift
//  Contributor
//
//  Created by KiwiTech on 10/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension FeedViewController {
    
 func addReferView() {
   self.referView.removeFromSuperview()
    if let offset = adapter.collectionView?.contentOffset.y, offset == CGFloat(0),
       let tabBar = currentTabBar,
       UserManager.shared.user?.isAcceptingOffers == true,
       UserManager.shared.user?.isFraudSuspect == false,
       UserManager.shared.user?.referFriendEnabled == true {
    let bottomY = view.frame.size.height - tabBar.tabBarHeight - 28
    referView.referFriendDelegate = self
    self.view.addSubview(self.referView)
    addReferViewWithAnimation(bottomY)
    resetValues()
   }
}
    
func addReferViewWithAnimation(_ bottomY: CGFloat) {
  UIView.animate(withDuration: 1.0,
                     delay: 0, usingSpringWithDamping: 1.0,
                     initialSpringVelocity: 1.0,
                     options: .curveEaseInOut, animations: {
    self.referView.frame = CGRect(x: 0, y: bottomY, width: self.view.frame.size.width, height: 78)
    }, completion: nil)
}
    
func removeReferViewWithAnimation() {
  if let tabBar = self.currentTabBar {
    let bottomY = view.frame.size.height - tabBar.tabBarHeight - 28
    UIView.animate(withDuration: 1.2,
                        delay: 0, usingSpringWithDamping: 1.0,
                        initialSpringVelocity: 1.0,
                        options: .curveEaseInOut, animations: {
        self.referView.frame = CGRect(x: 0, y: bottomY + 78, width: self.view.frame.size.width, height: 78)
    }, completion: nil)
   }
}
    
func resetValues() {
    feedVisitCount = 0
    Defaults[.appLaunchCount] = 0
  }
}

extension FeedViewController: ReferFriendViewDelegate {
  func didTapToCloseFriendView() {
    Defaults[.closeReferFriendView] = true
    removeReferViewWithAnimation()
  }
    
  func didTapToOpenReferView() {
    if let code = UserManager.shared.user?.inviteCode {
        Router.shared.route(to: .referView(inviteCode: code),
                            from: self,
                            presentationType: .modal(presentationStyle: .pageSheet,
                                                     transitionStyle: .coverVertical))
    }
  }
}
