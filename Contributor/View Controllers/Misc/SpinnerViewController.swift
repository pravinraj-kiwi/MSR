//
//  SpinnerViewController.swift
//  Contributor
//
//  Created by arvindh on 17/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import SnapKit

protocol SpinnerDisplayable: class {
  var spinnerViewController: SpinnerViewController {get set}
  func showSpinner(inView: UIView?)
  func hideSpinner()
}

extension SpinnerDisplayable where Self: UIViewController {
  func showSpinner(inView: UIView? = nil) {
    let viewToShowIn: UIView = inView ?? self.view
    
    spinnerViewController.willMove(toParent: self)
    addChild(spinnerViewController)
    viewToShowIn.addSubview(spinnerViewController.view)
    spinnerViewController.view.snp.makeConstraints { (make) in
      make.edges.equalTo(viewToShowIn)
    }
    spinnerViewController.didMove(toParent: self)
    
    spinnerViewController.start()
    
    viewToShowIn.setNeedsLayout()
    viewToShowIn.layoutIfNeeded()
  }
  
  func hideSpinner() {
    spinnerViewController.stop()
    spinnerViewController.view.removeFromSuperview()
    spinnerViewController.willMove(toParent: nil)
    spinnerViewController.removeFromParent()
  }
}

class SpinnerViewController: UIViewController {
  struct Layout {
    static let spinnerSize: CGFloat = 20
  }
  
  let spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    spinner.hidesWhenStopped = true
    return spinner
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupViews()
  }
  
  override func setupViews() {
    view.backgroundColor = Constants.backgroundColor
    
    view.addSubview(spinner)
    spinner.snp.makeConstraints { (make) in
      make.width.equalTo(Layout.spinnerSize)
      make.height.equalTo(spinner.snp.width)
      make.center.equalTo(view)
    }
  }
  
  func start() {
    spinner.startAnimating()
  }
  
  func stop() {
    spinner.stopAnimating()
  }
}
