//
//  StaticViewDisplayable.swift
//  Contributor
//
//  Created by arvindh on 05/02/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol StaticViewDisplayable: class {
  var staticMessageViewController: FullScreenMessageViewController?{get set}
  func show(staticMessage message: MessageHolder, inView: UIView?)
  func hideStaticMessage()
}

extension StaticViewDisplayable where Self: UIViewController {
  func show(staticMessage message: MessageHolder, inView: UIView? = nil) {
    let messageViewController = staticMessageViewController ?? FullScreenMessageViewController(messageHolder: message)
    messageViewController.delegate = self as? MessageViewControllerDelegate
    self.staticMessageViewController = messageViewController
    
    let viewToAddIn: UIView = inView ?? self.view
    
    messageViewController.willMove(toParent: self)
    
    viewToAddIn.addSubview(messageViewController.view)
    messageViewController.view.snp.makeConstraints { (make) in
      make.edges.equalTo(viewToAddIn)
    }
    
    self.addChild(messageViewController)
    messageViewController.didMove(toParent: self)
  }
  
  func hideStaticMessage() {
    guard let messageViewController = self.staticMessageViewController else {
      return
    }
    
    messageViewController.willMove(toParent: nil)
    messageViewController.view.removeFromSuperview()
    messageViewController.removeFromParent()
    self.staticMessageViewController = nil
  }
}
