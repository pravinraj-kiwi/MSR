//
//  RootViewController.swift
//  Contributor
//
//  Created by arvindh on 29/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import SnapKit

class RootViewController: UIViewController {
  var viewController: UIViewController {
    didSet {
      updateViewController(oldVC: oldValue, newVC: viewController)
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  var vcLeftConstraint: Constraint!
  var vcRightConstraint: Constraint!
  var isLoggingOut = false
  
  override var shouldAutomaticallyForwardAppearanceMethods: Bool {
    return true
  }

  init(viewController: UIViewController) {
    self.viewController = viewController
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    addListeners()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func setupViews() {
    view.backgroundColor = UIColor.black
    
    viewController.willMove(toParent: self)
    view.addSubview(viewController.view)
    viewController.view.snp.makeConstraints { (make: ConstraintMaker) in
      self.vcLeftConstraint = make.left.equalTo(view).constraint
      self.vcRightConstraint = make.right.equalTo(view).constraint
      make.top.equalTo(view)
      make.width.equalTo(view)
      make.bottom.equalTo(view)
    }
    addChild(viewController)
    viewController.beginAppearanceTransition(true, animated: true)
    viewController.didMove(toParent: self)
    viewController.endAppearanceTransition()
  }
  
  func addListeners() {
    NotificationCenter.default.addObserver(self, selector: #selector(onShouldLogout(_:)), name: NSNotification.Name.shouldLogout, object: nil)
  }
  
  @objc func onShouldLogout(_ notification: Notification) {
    
    var existingViewController = notification.object as? UIViewController
    
    if UserManager.shared.isLoggedIn && !self.isLoggingOut {
      self.isLoggingOut = true
      DispatchQueue.main.async {
        os_log("Forcing log out on shouldLogout notification.", log: OSLog.views, type: .info)
        
        guard let rootViewController = self.rootViewController else {
          os_log("Can't find rootViewController to logout on shouldLogout message, ignoring", log: OSLog.views, type: .error)
          return
        }
        
        UserManager.shared.logout()
                
        // special handling for demo-ing community onboarding without a link
        var vc: UIViewController? = nil
        if let testCommunityOnboardingSlug = notification.userInfo?["testCommunityOnboardingSlug"] as? String {
          os_log("Special logout to test a community onboard...", log: OSLog.views, type: .info)
          UserManager.shared.deepLinkCommunitySlug = testCommunityOnboardingSlug
          vc = AppIntroViewController()
        } else {
          vc = LoginViewController()
        }

        let nav = LoginNavigationViewController(rootViewController: vc!)
        
        if existingViewController == nil {
          existingViewController = rootViewController.viewController
        }
        
        rootViewController.viewController = nav
        existingViewController?.dismissSelf()
        
        self.isLoggingOut = false
      }
    }
  }
  
  fileprivate func updateViewController(oldVC: UIViewController, newVC: UIViewController) {
    var newVCLeftConstraint: Constraint!
    var newVCRightConstraint: Constraint!
    
    let offset = view.frame.size.width + 20
    
    newVC.willMove(toParent: self)
    view.addSubview(newVC.view)
    newVC.view.snp.makeConstraints { (make: ConstraintMaker) in
      make.top.equalTo(view)
      newVCLeftConstraint = make.left.equalTo(view).offset(offset).constraint
      newVCRightConstraint = make.right.equalTo(view).offset(offset).constraint
      make.width.equalTo(view)
      make.height.equalTo(view)
    }
    addChild(newVC)
    newVC.didMove(toParent: self)

    view.layoutIfNeeded()
    
    vcLeftConstraint.update(offset: -offset)
    vcRightConstraint.update(offset: -offset)
    newVCLeftConstraint.update(offset: 0)
    newVCRightConstraint.update(offset: 0)
    
    view.setNeedsLayout()
    
    UIView.animate(
      withDuration: 0.5,
      animations: {
        self.view.layoutIfNeeded()
      },
      completion: { (finished: Bool) in
        if finished {
          oldVC.view.removeFromSuperview()
          oldVC.willMove(toParent: nil)
          oldVC.removeFromParent()
          oldVC.didMove(toParent: nil)
          self.vcLeftConstraint = newVCLeftConstraint
          self.vcRightConstraint = newVCRightConstraint
        }
      }
    )
  }  
}

extension UIViewController {
  var rootViewController: RootViewController? {
    if let rootVC = UIApplication.shared.keyWindow?.rootViewController as? RootViewController {
      return rootVC
    }
    return nil
  }
}
