//
//  Toaster.swift
//  Contributor
//
//  Created by arvindh on 30/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import Toast_Swift

class Toaster: NSObject {
  var view: UIView
  var activeColor = Constants.primaryColor
    
  init(view: UIView) {
    self.view = view
    super.init()
  }
  
func toast(message: String, title: String? = nil,
               position: ToastPosition = ToastPosition.bottom,
               completion: ((_ didTap: Bool) -> Void)? = nil) {
    applyCommunityTheme()
    var style = ToastStyle()
    style.backgroundColor = activeColor
    view.makeToast(
      message,
      duration: 3,
      position: ToastPosition.bottom,
      title: title,
      image: nil,
      style: style,
      completion: completion
    )
  }
}

extension Toaster: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity,
          let colors = community.colors else {
      return
    }
    activeColor = colors.primary
  }
}
