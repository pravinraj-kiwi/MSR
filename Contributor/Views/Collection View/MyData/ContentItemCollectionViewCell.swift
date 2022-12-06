//
//  ContentItemCollectionViewCell.swift
//  Contributor
//
//  Created by arvindh on 26/12/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import CoreMotion
import Kingfisher
import SwiftyAttributes

class ContentItemCollectionViewCell: CardCollectionViewCell {
  struct Layout {
    static var cardContentInset = UIEdgeInsets(top: 25, left: 20, bottom: 23, right: 20)
    static var titleFont = Font.bold.of(size: 22)
    static var detailFont = Font.regular.of(size: 16)
    static var urlFont = Font.regular.of(size: 16)
    static var lineSpacing = Constants.defaultLineSpacing
    static var defaultStackSpacing: CGFloat = 10
    static var cardFooterHeight: CGFloat = 30
    static var openerImageSize: CGSize = CGSize(width: 16, height: 16)
  }
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    return iv
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.titleFont
    label.numberOfLines = 0
    return label
  }()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.detailFont
    label.numberOfLines = 0
    return label
  }()

  let cardFooterContainer = UIView()

  let urlLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.urlFont
    label.numberOfLines = 0
    return label
  }()
  
  let openerImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.image = Image.opener.value
    return iv
  }()

  let stackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = Layout.defaultStackSpacing
    return stack
  }()
  
  static func calculateHeightForWidth(item: ContentItem, width: CGFloat) -> CGFloat {
    let cardWidth = width - CardLayout.cardInset.left - CardLayout.cardInset.right
    
    var imageHeight: CGFloat = 0
    
    if let _ = item.imageURL {
      switch item.layoutType {
      case .topImage1x1:
        imageHeight = calculateImageHeight(width: cardWidth, widthRatio: 1, heightRatio: 1)
      case .topImage2x1:
        imageHeight = calculateImageHeight(width: cardWidth, widthRatio: 2, heightRatio: 1)
      case .topImage3x1:
        imageHeight = calculateImageHeight(width: cardWidth, widthRatio: 3, heightRatio: 1)
      default:
        break
      }
    }
    
    let contentWidth = cardWidth - Layout.cardContentInset.left - Layout.cardContentInset.right
    
    var titleLabelHeight: CGFloat = 0
    var titleLabelBottomMargin: CGFloat = 0
    if let title = item.title, !title.isEmpty {
      titleLabelHeight = TextSize.calculateHeight(title, font: Layout.titleFont, width: contentWidth, lineSpacing: Layout.lineSpacing)
      titleLabelBottomMargin = Layout.defaultStackSpacing
    }
    
    var detailLabelHeight: CGFloat = 0
    if let body = item.body, !body.isEmpty {
      detailLabelHeight = TextSize.calculateHeight(body, font: Layout.detailFont, width: contentWidth, lineSpacing: Layout.lineSpacing)
    }
    
    var cardFooterTopMargin: CGFloat = 0
    var cardFooterHeight: CGFloat = 0
    if item.contentType == ContentItem.ContentType.externalLink, let _ = item.url {
      cardFooterTopMargin = Layout.defaultStackSpacing
      cardFooterHeight = Layout.cardFooterHeight
    }
    
    let height: CGFloat = CardLayout.cardInset.top
      + imageHeight
      + Layout.cardContentInset.top
      + titleLabelHeight
      + titleLabelBottomMargin
      + detailLabelHeight
      + cardFooterTopMargin
      + cardFooterHeight
      + Layout.cardContentInset.bottom
      + CardLayout.cardInset.bottom
    
    return height
  }
  
  static func calculateImageHeight(width: CGFloat, widthRatio: CGFloat, heightRatio: CGFloat) -> CGFloat {
    return width * heightRatio / widthRatio
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupViews() {
    cardView.addSubview(imageView)  // constraints set in showImage/hideImage

    cardView.addSubview(stackView)
    stackView.snp.makeConstraints { (make) in
      make.top.equalTo(imageView.snp.bottom).offset(Layout.cardContentInset.top)
      make.left.right.equalToSuperview().inset(Layout.cardContentInset)
    }
    
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(detailLabel)
    stackView.addArrangedSubview(cardFooterContainer)
    
    cardFooterContainer.snp.makeConstraints { (make) in
      make.height.equalTo(Layout.cardFooterHeight)
      make.width.equalToSuperview()
    }
    
    cardFooterContainer.addSubview(urlLabel)
    urlLabel.snp.makeConstraints { (make) in
      make.bottom.equalToSuperview()
      make.left.equalTo(cardFooterContainer)
    }
    
    cardFooterContainer.addSubview(openerImageView)
    openerImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(urlLabel)
      make.size.equalTo(Layout.openerImageSize)
      make.right.equalTo(cardFooterContainer)
    }
  }
  
  func configure(with item: ContentItem) {
    if let url = item.imageURL {
      imageView.kf.setImage(with: url)
      switch item.layoutType {
      case .topImage1x1:
        showImage(widthRatio: 1.0, heightRatio: 1.0)
      case .topImage2x1:
        showImage(widthRatio: 2.0, heightRatio: 1.0)
      case .topImage3x1:
        showImage(widthRatio: 3.0, heightRatio: 1.0)
      default:
        hideImage()
      }
    } else {
      hideImage()
    }
    
    var backgroundColor = Constants.backgroundColor
    var foregroundColor = Color.text.value
    var foregroundLightColor = Color.lightText.value

    if let customBackgroundColor = item.backgroundColor {
      backgroundColor = customBackgroundColor
    }
    
    if item.useWhiteText {
      foregroundColor = Color.whiteText.value
      foregroundLightColor = Color.almostWhiteText.value
    }
    
    titleLabel.textColor = foregroundColor
    detailLabel.textColor = foregroundColor
    urlLabel.textColor = foregroundLightColor
    cardView.backgroundColor = backgroundColor
    
    if let title = item.title, !title.isEmpty {
      titleLabel.attributedText = title.lineSpaced(Layout.lineSpacing)
      titleLabel.isHidden = false
    } else {
      titleLabel.isHidden = true
    }
    
    if let body = item.body, !body.isEmpty {
      detailLabel.attributedText = body.lineSpaced(Layout.lineSpacing)
      detailLabel.isHidden = false
    } else {
      detailLabel.isHidden = true
    }
    
    if item.contentType == ContentItem.ContentType.externalLink, let url = item.url {
      cardFooterContainer.isHidden = false
      urlLabel.text = url.host?.replacingOccurrences(of: "www.", with: "")
    } else {
      cardFooterContainer.isHidden = true
    }
    
    contentView.setNeedsUpdateConstraints()
  }
  
  func showImage(widthRatio: CGFloat, heightRatio: CGFloat) {
    imageView.snp.remakeConstraints { make in
      make.top.width.centerX.equalToSuperview()
      make.height.equalTo(cardView.snp.width).multipliedBy(heightRatio).dividedBy(widthRatio)
    }
  }
  
  func hideImage() {
    imageView.snp.remakeConstraints { make in
      make.top.width.centerX.equalToSuperview()
      make.height.equalTo(0)
    }
  }
}
