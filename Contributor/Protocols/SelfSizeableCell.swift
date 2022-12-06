//
//  SelfSizableCell.swift
//  Contributor
//
//  Created by arvindh on 31/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import UIKit

protocol SelfSizeableCell: class {
  func setupContentView()
  func selfSizingLayoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
}

extension SelfSizeableCell where Self: UICollectionViewCell {
  func setupContentView() {
    contentView.backgroundColor = Constants.backgroundColor
    contentView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
  }
  
  func selfSizingLayoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    setNeedsLayout()
    layoutIfNeeded()
    
    let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
    
    var newFrame = layoutAttributes.frame
    newFrame.size.height = ceil(size.height)
    layoutAttributes.frame = newFrame
    
    return layoutAttributes
  }
}
