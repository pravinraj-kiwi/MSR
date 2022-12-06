//
//  LoginNavigationViewController.swift
//  Contributor
//
//  Created by arvindh on 31/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class LoginNavigationViewController: UINavigationController {
  override var childForStatusBarStyle: UIViewController? {
    return topViewController
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .default
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setNavigationBarHidden(true, animated: false)
    setNeedsStatusBarAppearanceUpdate()
    
    navigationBar.barTintColor = Constants.backgroundColor
    navigationBar.isTranslucent = false
    navigationBar.tintColor = Color.navigationItemTint.value
    navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backIndicatorImage = UIImage(named: "back-arrow")
    navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back-arrow")

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
