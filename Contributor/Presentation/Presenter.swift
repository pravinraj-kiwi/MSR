//
//  Presenter.swift
//  Contributor
//
//  Created by arvindh on 12/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import UIKit

class Presenter: NSObject {
  var presentingViewController: UIViewController
  var presentedViewController: UIViewController
  
  required init(presentingViewController: UIViewController, presentedViewController: UIViewController) {
    self.presentingViewController = presentingViewController
    self.presentedViewController = presentedViewController
    super.init()
  }
  
  func present() {
    presentedViewController.modalPresentationStyle = .custom
    presentedViewController.transitioningDelegate = self
    
    presentingViewController.present(presentedViewController, animated: true, completion: nil)
  }
}

extension Presenter: UIViewControllerTransitioningDelegate {}
