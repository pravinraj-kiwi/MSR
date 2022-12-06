//
//  NavigationViewController.swift
//  Contributor
//
//  Created by arvindh on 29/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationBar.tintColor = Color.navigationItemTint.value
    navigationBar.isTranslucent = false
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

extension NavigationViewController: Tabbable {
  fileprivate var tabbableViewController: Tabbable? {
    return self.viewControllers.first as? Tabbable
  }
  var tabName: String {
    return tabbableViewController?.tabName ?? ""
  }
  
  var tabImage: Image {
    return tabbableViewController?.tabImage ?? Image.emptyTab
  }
  
  var tabHighlightedImage: Image {
    return tabbableViewController?.tabHighlightedImage ?? Image.emptyTabHighlighted
  }
    
  override func present(_ viewControllerToPresent: UIViewController,
                        animated flag: Bool, completion: (() -> Void)? = nil) {
    if let webVC = viewControllers.filter({ $0 is WebContentViewController }).first as? WebContentViewController {
       webVC.setUIDocumentMenuViewControllerSoureViewsIfNeeded(viewControllerToPresent)
    }
    super.present(viewControllerToPresent, animated: flag, completion: completion)
  }
}
