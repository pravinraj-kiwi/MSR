//
//  CardContainerView.swift
//  Contributor
//
//  Created by arvindh on 20/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class CardContainerView: UIView {
  var borderColor: UIColor = UIColor(white: 0.9, alpha: 1)
  var cornerRadius: CGFloat = 0 {
    didSet {
      container.layer.cornerRadius = cornerRadius
      innerContainer.layer.cornerRadius = cornerRadius
    }
  }
  
  lazy var container: UIView = {
    let view = UIView()
    view.layer.cornerRadius = Constants.cardCornerRadius
    view.layer.shadowRadius = 10
    view.layer.shadowOpacity = 0.1
    view.layer.shadowOffset = CGSize(width: 0, height: 0)
    view.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    return view
  }()
  
  lazy var innerContainer: UIView = {
    let view = UIView()
    view.clipsToBounds = true
    view.layer.cornerRadius = Constants.cardCornerRadius
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupViews() {
    setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    
    addSubview(container)
    container.snp.makeConstraints { (make) in
      make.edges.equalTo(self)
    }
    
    container.addSubview(innerContainer)
    innerContainer.snp.makeConstraints { (make) in
      make.edges.equalTo(container)
    }
  }
  
  func addContentView(_ view: UIView) {
    innerContainer.addSubview(view)
    view.snp.makeConstraints { (make) in
      make.edges.equalTo(innerContainer)
    }
  }
}
