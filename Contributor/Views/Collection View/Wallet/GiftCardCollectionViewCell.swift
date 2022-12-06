//
//  GiftCardCollectionViewCell.swift
//  Contributor
//
//  Created by arvindh on 16/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

class GiftCardCollectionViewCell: UICollectionViewCell, SelfSizeableCell {
  struct Layout {
    static let imageTopMargin: CGFloat = 0
    static let titleTopMargin: CGFloat = 3
    static let titleBottomMargin: CGFloat = 6
    static let sideMargin: CGFloat = 0
    static let minImageHeight: CGFloat = 150
  }
  
  let imageContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    view.clipsToBounds = true
    view.layer.cornerRadius = Constants.cardCornerRadius
    return view
  }()
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    return iv
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = Constants.backgroundColor
    label.font = Font.semiBold.of(size: 15)
    label.textAlignment = .center
    label.textColor = Color.lightText.value
    label.numberOfLines = 1
    return label
  }()
  
  let descriptionLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = Constants.backgroundColor
    label.font = Font.regular.of(size: 13)
    label.textAlignment = .center
    label.textColor = Color.lightText.value
    label.numberOfLines = 3
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
    imageContainerView.addSubview(imageView)
    imageView.snp.makeConstraints { (make) in
      make.edges.equalTo(imageContainerView)
    }
    
    contentView.addSubview(imageContainerView)
    imageContainerView.snp.makeConstraints { (make) in
      make.top.equalTo(contentView).offset(Layout.imageTopMargin)
      make.left.equalTo(contentView).offset(Layout.sideMargin)
      make.right.equalTo(contentView).offset(-Layout.sideMargin)
    }
        
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.left.equalTo(contentView).offset(Layout.sideMargin)
      make.right.equalTo(contentView).offset(-Layout.sideMargin)
      make.top.equalTo(imageContainerView.snp.bottom).offset(Layout.titleTopMargin)
      make.height.equalTo(20)
    }
    
    contentView.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { (make) in
      make.left.equalTo(contentView).offset(Layout.sideMargin)
      make.right.equalTo(contentView).offset(-Layout.sideMargin)
      make.top.equalTo(titleLabel.snp.bottom).offset(2)
      make.bottom.equalTo(contentView).offset(-Layout.titleBottomMargin)
      make.height.equalTo(20)
    }
  }
  
  func configure(with giftCard: GiftCard, options: [GiftCardRedemptionOption]) {
    let optionsStrings = options.map { (option) -> String in
      return option.formattedFiatValue
    }
    
    let joinedOptionsString = optionsStrings.joined(separator: ", ")
    titleLabel.text = giftCard.name
    descriptionLabel.text = "Available in \(joinedOptionsString)"
  }
  
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    return selfSizingLayoutAttributes(layoutAttributes)
  }
}
