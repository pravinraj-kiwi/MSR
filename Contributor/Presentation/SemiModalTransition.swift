//
//  SemiModalTransition.swift
//  Pods
//
//  Created by Arvindh Sukumar on 18/07/16.
//
//

import UIKit

protocol SemiModalViewable {
  var dimView: UIView! { get set }
}

class SemiModalTransition: NSObject, UIViewControllerAnimatedTransitioning {
  var presenting: Bool = false
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return presenting ? 0.5 : 0.3
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
      return
    }
    
    let containerView = transitionContext.containerView
    
    if presenting {
      containerView.addSubview(toViewController.view)
    }
    
    let animatingVC = presenting ? toViewController : fromViewController
    let animatingView = animatingVC.view
    
    let appearedFrame = transitionContext.finalFrame(for: animatingVC)
    var dismissedFrame = appearedFrame
    dismissedFrame.origin.y += dismissedFrame.size.height
    
    let initialFrame = presenting ? dismissedFrame : appearedFrame
    let finalFrame = presenting ? appearedFrame : dismissedFrame
    
    animatingView?.frame = initialFrame
    
    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
      animatingView?.frame = finalFrame      
    }, completion: {
      _ in
      
      if !self.presenting {
        fromViewController.view.removeFromSuperview()
      }
      transitionContext.completeTransition(true)
    })
  }
}
