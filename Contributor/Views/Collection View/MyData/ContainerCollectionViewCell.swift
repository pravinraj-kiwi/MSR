//
//  ContainerCollectionViewCell.swift
//  Contributor
//
//  Created by arvindh on 18/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class ContainerCollectionViewCell: UICollectionViewCell, SelfSizeableCell {
  static var containerInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupContentView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func add(contentViewController: UIViewController) {
    contentView.addSubview(contentViewController.view)
    contentViewController.view.snp.makeConstraints { (make) in
      make.edges.equalToSuperview().inset(ContainerCollectionViewCell.containerInset)
    }
    
    contentView.setNeedsLayout()
    contentView.layoutIfNeeded()
  }
  
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    return self.selfSizingLayoutAttributes(layoutAttributes)
  }
}
