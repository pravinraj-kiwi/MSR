//
//  DataProfileAttributeCollectionCell.swift
//  Contributor
//
//  Created by KiwiTech on 11/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class DataProfileAttributeCollectionCell: UICollectionViewCell {
    
 let titleLabel: EdgeInsetLabel = {
   let label = EdgeInsetLabel()
   label.font = Font.semiBold.of(size: 11)
   label.textAlignment = .center
   label.numberOfLines = 0
   label.textColor = .white
   label.sizeToFit()
   return label
}()
  
override init(frame: CGRect) {
  super.init(frame: frame)
  setupViews()
}
  
required init?(coder aDecoder: NSCoder) {
  super.init(coder: aDecoder)
  setupViews()
}
    
func setupViews() {
    self.layer.cornerRadius = self.frame.size.height / 2
  contentView.addSubview(titleLabel)
  titleLabel.snp.makeConstraints { (make) in
    make.centerX.equalToSuperview()
    make.centerY.equalToSuperview()
  }
 }
}
