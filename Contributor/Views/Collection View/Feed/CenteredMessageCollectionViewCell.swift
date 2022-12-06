//
//  CenteredMessageCollectionViewCell.swift
//  Contributor
//
//  Created by John Martin on 5/6/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

class CenteredMessageCollectionViewCell: UICollectionViewCell {
  struct Layout {
    static var contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    static var labelInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    static let borderHeight: CGFloat = 1
    static let borderBottomMargin: CGFloat = 10
    static let imageBottomMargin: CGFloat = 24
    static let titleFont = Font.bold.of(size: 20)
    static let titleLabelBottomMargin: CGFloat = 10
    static let detailFont = Font.regular.of(size: 18)
    static var lineSpacing = Constants.defaultLineSpacing
    static var defaultStackSpacing: CGFloat = 5
  }

  let border1: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
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
    label.font = Layout.titleFont
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    return label
  }()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.detailFont
    label.textColor = Color.lightText.value
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    return label
  }()
  
  let stackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.distribution = .fill
    stack.spacing = Layout.defaultStackSpacing
    return stack
  }()

  static func calculateHeightForWidth(message: MessageHolder, width: CGFloat) -> CGFloat {
    let contentWidth = width - Layout.contentInset.left - Layout.contentInset.right
    
    var imageHeight: CGFloat = 0
    var imageBottomMargin: CGFloat = 0

    if let image = message.image {
      imageHeight = image.value.calculateHeight(for: width)
      imageBottomMargin = Layout.imageBottomMargin
    }
    
    let labelWidth = contentWidth - Layout.labelInset.left - Layout.labelInset.right
    var titleLabelHeight: CGFloat = 0
    var titleLabelBottomMargin: CGFloat = 0
    if let title = message.title, !title.isEmpty {
      titleLabelHeight = TextSize.calculateHeight(title, font: Layout.titleFont, width: labelWidth, lineSpacing: Layout.lineSpacing)
      titleLabelBottomMargin = Layout.titleLabelBottomMargin
    }
    
    var detailLabelHeight: CGFloat = 0
    var detailLabelBottomMargin: CGFloat = 0
    if let detail = message.detail, !detail.isEmpty {
      detailLabelHeight = TextSize.calculateHeight(detail, font: Layout.detailFont, width: labelWidth, lineSpacing: Layout.lineSpacing)
      detailLabelBottomMargin = Layout.defaultStackSpacing
    }
    
    let height: CGFloat = Layout.borderHeight
      + Layout.borderBottomMargin
      + imageHeight
      + imageBottomMargin
      + titleLabelHeight
      + titleLabelBottomMargin
      + detailLabelHeight
      + detailLabelBottomMargin
    
    return height
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }
  
  func setupViews() {
    let contentWidth = contentView.frame.width - Layout.contentInset.left - Layout.contentInset.right

    contentView.addSubview(border1)
    border1.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.height.equalTo(Layout.borderHeight)
      make.width.equalTo(contentWidth)
      make.centerX.equalToSuperview()
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { (make) in
      make.top.equalTo(border1.snp.bottom).offset(Layout.borderBottomMargin)
      make.width.equalTo(contentWidth)
      make.centerX.equalToSuperview()
    }
    
    stackView.addArrangedSubview(imageView)
    stackView.setCustomSpacing(Layout.imageBottomMargin, after: imageView)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(detailLabel)
    
    let labelWidth = contentWidth - Layout.labelInset.left - Layout.labelInset.right

    titleLabel.snp.makeConstraints { (make) in
      make.width.greaterThanOrEqualTo(labelWidth)
    }

    detailLabel.snp.makeConstraints { (make) in
      make.width.greaterThanOrEqualTo(labelWidth)
    }
  }
  
  func showImage() {
    let contentWidth = contentView.frame.width - Layout.contentInset.left - Layout.contentInset.right
    let imageHeight = imageView.image?.calculateHeight(for: contentWidth) ?? 0
    
    imageView.snp.remakeConstraints { (make) in
      make.width.equalTo(contentWidth)
      make.height.equalTo(imageHeight)
    }
    
    imageView.isHidden = false
  }
  
  func hideImage() {
    imageView.isHidden = true
  }
  
  func configure(with message: MessageHolder) {
    if let title = message.title {
      titleLabel.attributedText = title.lineSpacedAndCentered(Layout.lineSpacing)
      titleLabel.isHidden = false
    } else {
      titleLabel.isHidden = true
    }
    
    if let detail = message.detail {
      detailLabel.attributedText = detail.lineSpacedAndCentered(Layout.lineSpacing)
      detailLabel.isHidden = false
    } else {
      detailLabel.isHidden = true
    }

    if let image = message.image {
      imageView.image = image.value
      showImage()
    } else {
      imageView.image = nil
      hideImage()
    }
  }
}
