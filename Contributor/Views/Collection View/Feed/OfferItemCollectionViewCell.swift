//
//  FeedItemCollectionViewCell.swift
//  Contributor
//
//  Created by arvindh on 17/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import CoreMotion
import Kingfisher
import SwiftyAttributes

class OfferItemCollectionViewCell: CardCollectionViewCell {
  struct Layout {
    static var cardContentInset = UIEdgeInsets(top: 15, left: 20, bottom: 20, right: 20)
    static var cardHeaderBottomMargin: CGFloat = 20
    static var cardHeaderHeight: CGFloat = 26
    static var jobTypeFont = Font.regular.of(size: 16)
    static var msrFont = Font.bold.of(size: 16)
    static var titleFont = Font.bold.of(size: 22)
    static var detailFont = Font.regular.of(size: 16)
    static var contentFont = Font.regular.of(size: 16)
    static var lineSpacing = Constants.defaultLineSpacing
    static var defaultStackSpacing: CGFloat = 10
    static var msrPillViewHeight: CGFloat = 26
    static var msrPillInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    static var detailLabelBottomMargin: CGFloat = 25
    static var timeLabelBottomMargin: CGFloat = 5
  }
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    return iv
  }()

  let cardHeaderContainer = UIView()
  
  let jobTypeLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.jobTypeFont
    label.numberOfLines = 0
    return label
  }()

  let msrPillView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 3
    return view
  }()
  
  let msrLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.msrFont
    label.numberOfLines = 1
    label.textColor = Color.text.value
    return label
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
  
  let timeLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.numberOfLines = 1
    return label
  }()

  let expiryLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.numberOfLines = 1
    return label
  }()

  let stackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = Layout.defaultStackSpacing
    return stack
  }()
  
  static func calculateHeightForWidth(item: OfferItem, width: CGFloat) -> CGFloat {
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
    var detailLabelBottomMargin: CGFloat = 0
    if let itemDescription = item.itemDescription, !itemDescription.isEmpty {
      detailLabelHeight = TextSize.calculateHeight(itemDescription, font: Layout.detailFont, width: contentWidth, lineSpacing: Layout.lineSpacing)
      detailLabelBottomMargin = Layout.detailLabelBottomMargin
    }
    
    var timeLabelHeight: CGFloat = 0
    var timeLabelBottomMargin: CGFloat = 0
    if let _ = item.estimatedMinutes {
      timeLabelHeight = TextSize.calculateSingleLineHeight(font: Layout.contentFont, width: contentWidth)
      timeLabelBottomMargin = Layout.timeLabelBottomMargin
    }
    
    var expiryLabelHeight: CGFloat = 0
    if let _ = item.expiryString, let _ = item.minutesUntilExpiry {
      expiryLabelHeight = timeLabelHeight
    }
    
    let height: CGFloat = CardLayout.cardInset.top
      + imageHeight
      + Layout.cardContentInset.top
      + Layout.cardHeaderHeight
      + Layout.cardHeaderBottomMargin
      + titleLabelHeight
      + titleLabelBottomMargin
      + detailLabelHeight
      + detailLabelBottomMargin
      + timeLabelHeight
      + timeLabelBottomMargin
      + expiryLabelHeight
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
    stackView.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(Layout.cardContentInset.top)
      make.left.right.equalToSuperview().inset(Layout.cardContentInset)
    }

    stackView.addArrangedSubview(cardHeaderContainer)
    stackView.setCustomSpacing(Layout.cardHeaderBottomMargin, after: cardHeaderContainer)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(detailLabel)
    stackView.setCustomSpacing(Layout.detailLabelBottomMargin, after: detailLabel)
    stackView.addArrangedSubview(timeLabel)
    stackView.setCustomSpacing(Layout.timeLabelBottomMargin, after: timeLabel)
    stackView.addArrangedSubview(expiryLabel)

    cardHeaderContainer.snp.makeConstraints { make in
      make.height.equalTo(Layout.cardHeaderHeight)
      make.width.equalToSuperview()
    }

    cardHeaderContainer.addSubview(jobTypeLabel)
    jobTypeLabel.snp.makeConstraints { make in
      make.centerY.equalTo(cardHeaderContainer)
      make.left.equalTo(cardHeaderContainer)
      make.height.equalTo(Layout.cardHeaderHeight)
    }
  }
  
  func configure(with item: OfferItem) {
    showHeader()
    showFooter()

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

    msrPillView.backgroundColor = Color.lightBackground.value
    
    jobTypeLabel.textColor = foregroundLightColor
    titleLabel.textColor = foregroundColor
    detailLabel.textColor = foregroundColor
    timeLabel.textColor = foregroundLightColor
    expiryLabel.textColor = foregroundLightColor
    cardView.backgroundColor = backgroundColor
    
    jobTypeLabel.text = item.offerTypeLabel
    
    if item.estimatedEarnings > 0 {
      msrLabel.text = item.estimatedEarnings.formattedMSRString
      showMSRPill()
    } else {
      hideMSRPill()
    }
    
    if let title = item.title, !title.isEmpty {
      titleLabel.attributedText = title.lineSpaced(Layout.lineSpacing)
      titleLabel.isHidden = false
    } else {
      titleLabel.isHidden = true
    }
    
    if let detail = item.itemDescription, !detail.isEmpty {
      detailLabel.attributedText = detail.lineSpaced(Layout.lineSpacing)
      detailLabel.isHidden = false
    } else {
      detailLabel.isHidden = true
    }

    if let estimatedMinutes = item.estimatedMinutes {
      if estimatedMinutes == 1 {
        timeLabel.text = OfferItemCell.completeTimeText.localized()
      } else {
        timeLabel.text = "\(estimatedMinutes) \(SurveyText.complete.localized())"
      }
      
      timeLabel.isHidden = false
    } else {
      timeLabel.isHidden = true
    }
    
    if let expiryString = item.expiryString, let minutesUntilExpiry = item.minutesUntilExpiry {
      expiryLabel.isHidden = false
      if minutesUntilExpiry < 60 {
        let prefix = SurveyText.expiresIn.localized().withAttributes([
          Attribute.font(Layout.contentFont),
          Attribute.textColor(foregroundLightColor)
        ])
        
        let suffix = expiryString.withAttributes([
          Attribute.font(Layout.contentFont),
          Attribute.textColor(UIColor.red)
        ])
        
        expiryLabel.attributedText = prefix + suffix
      } else {
        expiryLabel.text = "\(SurveyText.expiresIn.localized()) \(expiryString)"
      }
    } else {
      expiryLabel.isHidden = true
    }
    
    // special case for community offers
    var community: Community? = nil
    if let slug = item.communitySlug {
      community = UserManager.shared.user?.getCommunityForSlug(slug: slug)
    } else {
      // if the user is only in a single community and it is not msr then default to that
      if UserManager.shared.user?.communities.count == 1 && !UserManager.shared.isDefaultCommunity {
        community = UserManager.shared.currentCommunity
      }
    }
    
    if let _ = community {
        jobTypeLabel.text = OfferItemCell.communitySurveyText.localized()
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
  
  func hideHeader() {
    cardHeaderContainer.isHidden = true
  }

  func showHeader() {
    cardHeaderContainer.isHidden = false
  }

  func showMSRPill() {
    msrPillView.addSubview(msrLabel)
    msrLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(Layout.msrPillInset)
    }

    cardHeaderContainer.addSubview(msrPillView)
    msrPillView.snp.makeConstraints { make in
      make.centerY.equalTo(jobTypeLabel)
      make.height.equalTo(Layout.msrPillViewHeight)
      make.right.equalTo(cardHeaderContainer)
    }

    cardHeaderContainer.setNeedsUpdateConstraints()
  }

  func hideMSRPill() {
    msrPillView.snp.removeConstraints()
    msrLabel.snp.removeConstraints()
    msrPillView.removeFromSuperview()
    cardHeaderContainer.setNeedsUpdateConstraints()
  }

  func hideFooter() {
    timeLabel.isHidden = true
    expiryLabel.isHidden = true
  }
  
  func showFooter() {
    timeLabel.isHidden = false
    expiryLabel.isHidden = false
  }
}
