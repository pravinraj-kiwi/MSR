//
//  DataSourceToggleCollectionViewCell.swift
//  Contributor
//
//  Created by arvindh on 13/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

class DataSourceToggleCollectionViewCell: UICollectionViewCell, SelfSizeableCell {
  struct Layout {
    static let verticalMargin: CGFloat = 16
    static let sideMargin: CGFloat = 20
    static let imageViewSize: CGSize = CGSize(width: 22, height: 22)
    
    static let switchLeftMargin: CGFloat = 10
    static let descriptionTopMargin: CGFloat = 10
  }
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.backgroundColor = Constants.backgroundColor
    return iv
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 16)
    label.backgroundColor = Constants.backgroundColor
    return label
  }()
  
  let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 13)
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    return label
  }()
  
  let toggleSwitch = UISwitch()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupViews() {
    setupContentView()
    
    contentView.addSubview(imageView)
    imageView.snp.makeConstraints { (make) in
      make.top.equalTo(contentView)//.offset(Layout.verticalMargin)
      make.left.equalTo(contentView).offset(Layout.sideMargin)
      make.size.equalTo(Layout.imageViewSize)
    }
    
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(imageView)
      make.bottom.equalTo(imageView)
      make.left.equalTo(imageView.snp.right).offset(Layout.sideMargin)
    }
    
    contentView.addSubview(toggleSwitch)
    toggleSwitch.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel)
      make.centerY.equalTo(titleLabel)
      make.right.equalTo(contentView).offset(-Layout.sideMargin)
      make.left.equalTo(titleLabel.snp.right).offset(Layout.switchLeftMargin)
    }
    
    contentView.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(Layout.descriptionTopMargin)
      make.height.greaterThanOrEqualTo(25)
      make.left.equalTo(titleLabel)
      make.right.equalTo(titleLabel)
      make.bottom.equalTo(contentView).offset(-Layout.verticalMargin)
    }
    
    applyCommunityTheme()
  }
  
  func configure(with item: DataSource) {
    titleLabel.text = item.displayString
    descriptionLabel.attributedText = item.itemDescription.lineSpaced(1.2)
    imageView.image = item.image?.value
    toggleSwitch.isOn = UserManager.shared.isOn(dataSource: item)
  }
  
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    return selfSizingLayoutAttributes(layoutAttributes)
  }
}

extension DataSourceToggleCollectionViewCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    toggleSwitch.onTintColor = colors.primary
  }
}
