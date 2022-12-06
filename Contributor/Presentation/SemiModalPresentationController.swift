//
//  SemiModalPresentationController.swift
//  Contributor
//
//  Created by arvindh on 07/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import UIKit

class SemiModalPresentationController: UIPresentationController {
  let dimmingView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.4)
    view.alpha = 0
    return view
  }()
  
  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    setupDimmingView()
  }
  
  func setupDimmingView() {
    let tapGR = UITapGestureRecognizer(target: self, action: #selector(SemiModalPresentationController.dismissPresentedViewController(_:)))
    dimmingView.addGestureRecognizer(tapGR)
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    let containerSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
    return CGRect(x: 0, y: containerView!.bounds.height/2, width: containerView!.bounds.width, height: containerSize.height)
  }
  
  @objc func dismissPresentedViewController(_ tap: UITapGestureRecognizer) {
    if tap.state == .recognized {
      presentingViewController.dismiss(animated: true, completion: nil)
    }
  }
  
  override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
    return CGSize(width: containerView!.bounds.width, height: containerView!.bounds.height/2)
  }
  
  override func containerViewWillLayoutSubviews() {
    dimmingView.frame = containerView!.bounds
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
  
  override var shouldPresentInFullscreen: Bool {
    return true
  }
  
  override var adaptivePresentationStyle: UIModalPresentationStyle {
    return UIModalPresentationStyle.overFullScreen
  }
  
  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else {return}
    
    dimmingView.frame = containerView.bounds
    dimmingView.alpha = 0
    
    containerView.insertSubview(dimmingView, at: 0)
    presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
      self.dimmingView.alpha = 1
    }, completion: { (_) in
      
    })
  }
  
  override func dismissalTransitionWillBegin() {
    presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
      self.dimmingView.alpha = 0      
    }, completion: { (_) in
      
    })
  }
}
