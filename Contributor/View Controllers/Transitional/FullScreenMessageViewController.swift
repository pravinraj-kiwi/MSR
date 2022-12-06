//
//  FullScreenMessageViewController.swift
//  Contributor
//
//  Created by arvindh on 26/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

class FullScreenMessageViewController: MessageViewController {
  struct Layout {
    static let imageSize: CGFloat = 120
    static let imageTopMargin: CGFloat = 0
    static let imageBottomMargin: CGFloat = 20
    static let titleBottomMargin: CGFloat = 10
    static let detailBottomMargin: CGFloat = 30
    static let actionButtonBottomMargin: CGFloat = 10
    static let actionButtonWidth: CGFloat = 160
    static let actionButtonHeight: CGFloat = 44
    static let containerInset: CGFloat = 20
  }
  
  let container: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func setupViews() {
    view.backgroundColor = Constants.backgroundColor
    
    container.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    
    view.addSubview(container)
    container.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.view)
      make.centerY.equalTo(self.view).offset(-60)
      make.top.greaterThanOrEqualTo(self.view).offset(Layout.containerInset).priority(750)
      make.bottom.greaterThanOrEqualTo(self.view).offset(-Layout.containerInset).priority(750)
      make.left.greaterThanOrEqualTo(self.view).offset(Layout.containerInset).priority(751)
      make.right.greaterThanOrEqualTo(self.view).offset(-Layout.containerInset).priority(751)
      make.width.lessThanOrEqualTo(300).priority(751)
    }
    
    container.addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { (make) in
      make.top.equalTo(container).offset(Layout.imageTopMargin)
      make.width.equalTo(Layout.imageSize)
      make.height.equalTo(imageView.snp.width)
      make.centerX.equalTo(container)
    }
    
    container.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(imageView.snp.bottom).offset(Layout.imageBottomMargin)
      make.left.equalTo(self.container)
      make.right.equalTo(self.container)
    }
    titleLabel.font = Font.semiBold.of(size: 24)
    
    container.addSubview(detailLabel)
    detailLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(Layout.titleBottomMargin)
      make.left.equalTo(self.container)
      make.right.equalTo(self.container)
    }
    
    container.addSubview(actionButton)
    actionButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.detailLabel.snp.bottom).offset(Layout.detailBottomMargin)
      make.width.equalTo(Layout.actionButtonWidth)
      make.height.equalTo(Layout.actionButtonHeight)
      make.centerX.equalTo(self.container)
      make.bottom.equalTo(self.container)
    }
  }
}
