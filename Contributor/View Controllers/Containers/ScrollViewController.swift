//
//  ScrollViewController.swift
//
//  Created by arvindh on 20/10/18.
//

import SnapKit
import UIKit

class ScrollViewController: UIViewController, KeyboardDisplayable {
  var keyboardWrapper: KeyboardWrapper!
  var bottomConstraint: Constraint!

  let scrollView: UIScrollView = {
    let sv = UIScrollView(frame: CGRect.zero)
    sv.alwaysBounceVertical = true
    sv.backgroundColor = Constants.backgroundColor
    return sv
  }()
  
  let contentViewController: UIViewController
  
  init(contentViewController: UIViewController) {
    self.contentViewController = contentViewController
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    keyboardWrapper = KeyboardWrapper(delegate: self)
    
    self.setupViews()
    hideBackButtonTitle()
    self.navigationItem.leftBarButtonItem = self.contentViewController.navigationItem.leftBarButtonItem
    self.navigationItem.title = self.contentViewController.navigationItem.title
    self.navigationItem.rightBarButtonItem = self.contentViewController.navigationItem.rightBarButtonItem
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.hidesBottomBarWhenPushed = true
  }
  
  override func setupViews() {
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { (make) in
      make.top.equalTo(view)
      make.left.equalTo(view)
      make.right.equalTo(view)
      self.bottomConstraint = make.bottom.equalTo(view).constraint
    }
    
    let container = UIView()
    container.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    
    scrollView.addSubview(container)
    container.snp.makeConstraints({ make in
      make.edges.equalTo(self.scrollView)
      make.width.equalTo(self.scrollView)
    })
    
    contentViewController.willMove(toParent: self)
    addChild(contentViewController)
    container.addSubview(contentViewController.view)
    contentViewController.view.snp.makeConstraints { make in
      make.edges.equalTo(container)
    }
    contentViewController.didMove(toParent: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }  
}
