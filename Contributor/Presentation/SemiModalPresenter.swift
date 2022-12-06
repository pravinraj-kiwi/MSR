//
//  SemiModalPresenter.swift
//  Contributor
//
//  Created by arvindh on 07/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class SemiModalPresenter: Presenter {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    let semiModalTransition = SemiModalTransition()
    semiModalTransition.presenting = true
    return semiModalTransition
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let semiModalTransition = SemiModalTransition()
    return semiModalTransition
    
  }
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return SemiModalPresentationController(presentedViewController: presented, presenting: presenting)
  }
}
