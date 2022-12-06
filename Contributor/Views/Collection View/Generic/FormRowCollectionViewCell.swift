//
//  FormRowCollectionViewCell.swift
//  Contributor
//
//  Created by arvindh on 31/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class FormRowCollectionViewCell: UICollectionViewCell, SelfSizeableCell {
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }
  
  func setupViews() {
    setupContentView()
  }
  
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    return selfSizingLayoutAttributes(layoutAttributes)
  }

}
