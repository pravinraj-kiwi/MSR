//
//  CardContainerViewController.swift
//  Contributor
//
//  Created by arvindh on 10/09/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import SnapKit

class CardContainerViewController: UIViewController {
  var contentViewController: UIViewController
  let container: CardContainerView = CardContainerView()
  var insets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
  var cornerRadius: CGFloat = Constants.cardCornerRadius {
    didSet {
      container.cornerRadius = cornerRadius
    }
  }
  
  init(contentViewController: UIViewController) {
    self.contentViewController = contentViewController
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func setupViews() {
    view.backgroundColor = .clear
    view.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    
    view.addSubview(container)
    container.snp.makeConstraints { make in
      make.edges.equalTo(view).inset(self.insets).priority(999)
    }
    
    contentViewController.willMove(toParent: self)
    container.addContentView(contentViewController.view)    
    addChild(contentViewController)
    contentViewController.didMove(toParent: self)
  }
}
