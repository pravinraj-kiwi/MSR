//
//  RatingItemCollectionViewCell.swift
//  Contributor
//
//  Created by John Martin on 2/24/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

class RatingItemCollectionViewCell: UICollectionViewCell {
  let itemContainer: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBackground.value
    view.layer.cornerRadius = 6
    return view
  }()

  let itemLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = Color.lightBackground.value
    label.font = Font.regular.of(size: 15)
    label.textAlignment = .center
    label.textColor = Color.text.value
    label.numberOfLines = 1
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
    contentView.addSubview(itemContainer)
    itemContainer.snp.makeConstraints { (make) in
      make.edges.equalTo(contentView)
    }

    itemContainer.addSubview(itemLabel)
    itemLabel.snp.makeConstraints { (make) in
      make.top.equalTo(itemContainer).offset(10)
      make.bottom.equalTo(itemContainer).offset(-10)
      make.left.equalTo(itemContainer).offset(15)
      make.right.equalTo(itemContainer).offset(-15)
    }
  }
  
  func configure(with item: String) {
    itemLabel.text = item
  }
  
  func setSelected() {
    itemContainer.backgroundColor = Color.selectedItem.value
    itemLabel.backgroundColor = Color.selectedItem.value
  }

  func setUnselected() {
    itemContainer.backgroundColor = Color.lightBackground.value
    itemLabel.backgroundColor = Color.lightBackground.value
  }
}
