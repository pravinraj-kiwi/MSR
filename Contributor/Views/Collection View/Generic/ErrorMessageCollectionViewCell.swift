//
//  ErrorMessageCollectionViewCell.swift
//  Contributor
//
//  Created by John Martin on 5/8/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

protocol ErrorMessageCollectionViewCellDelegate: class {
  func didTapActionButton()
}

class ErrorMessageCollectionViewCell: UICollectionViewCell {
  struct Layout {
    static var contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    static var stackViewMaxWidth: CGFloat = 300
    static let borderHeight: CGFloat = 1
    static let borderBottomMargin: CGFloat = 50
    static let imageWidth: CGFloat = 105
    static let imageBottomMargin: CGFloat = 6
    static let titleFont = Font.bold.of(size: 20)
    static let titleLabelBottomMargin: CGFloat = 10
    static let detailFont = Font.regular.of(size: 18)
    static let detailLabelBottomMargin: CGFloat = 35
    static let actionButtonSize: CGSize = CGSize(width: 160, height: 44)
    static let actionButtonSizeInPT: CGSize = CGSize(width: 180, height: 44)
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
    return iv
  }()
  
  let imageViewContainer = UIView()
  
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
  
  let actionButton: UIButton = {
    let button = UIButton(type: UIButton.ButtonType.custom)
    button.backgroundColor = Constants.primaryColor
    button.setTitleColor(Constants.backgroundColor, for: UIControl.State.normal)
    button.titleLabel?.font = Font.regular.of(size: 18)
    button.layer.cornerRadius = Constants.buttonCornerRadius
    button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    return button
  }()
  
  let buttonContainer = UIView()

  let stackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.distribution = .fill
    stack.spacing = Layout.defaultStackSpacing
    return stack
  }()
  
  weak var delegate: ErrorMessageCollectionViewCellDelegate?

  static func calculateHeightForWidth(message: MessageHolder, width: CGFloat) -> CGFloat {
    let contentWidth = width - Layout.contentInset.left - Layout.contentInset.right
    let stackViewWidth = contentWidth > Layout.stackViewMaxWidth ? Layout.stackViewMaxWidth : contentWidth

    var imageHeight: CGFloat = 0
    var imageBottomMargin: CGFloat = 0
    
    if let image = message.image {
      imageHeight = image.value.calculateHeight(for: Layout.imageWidth)
      imageBottomMargin = Layout.imageBottomMargin
    }
    
    let labelWidth = stackViewWidth
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
      detailLabelBottomMargin = Layout.detailLabelBottomMargin
    }
    
    var actionButtonHeight: CGFloat = 0
    if let _ = message.buttonTitle {
      actionButtonHeight = Layout.actionButtonSize.height
    }

    let height: CGFloat = Layout.borderHeight
      + Layout.borderBottomMargin
      + imageHeight
      + imageBottomMargin
      + titleLabelHeight
      + titleLabelBottomMargin
      + detailLabelHeight
      + detailLabelBottomMargin
      + actionButtonHeight
    
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
    let stackViewWidth = contentWidth > Layout.stackViewMaxWidth ? Layout.stackViewMaxWidth : contentWidth

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
      make.width.equalTo(stackViewWidth)
      make.centerX.equalToSuperview()
    }
    
    stackView.addArrangedSubview(imageViewContainer)
    stackView.setCustomSpacing(Layout.imageBottomMargin, after: imageView)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(detailLabel)
    stackView.setCustomSpacing(Layout.detailLabelBottomMargin, after: detailLabel)
    stackView.addArrangedSubview(buttonContainer)

    imageViewContainer.addSubview(imageView)
    
    buttonContainer.snp.makeConstraints { (make) in
      make.height.equalTo(Layout.actionButtonSize.height)
    }
    
    buttonContainer.addSubview(actionButton)
    
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        actionButton.snp.makeConstraints { (make) in
          make.size.equalTo(Layout.actionButtonSizeInPT)
          make.centerX.equalToSuperview()
          make.top.equalToSuperview()
        }
    } else {
        actionButton.snp.makeConstraints { (make) in
          make.size.equalTo(Layout.actionButtonSize)
          make.centerX.equalToSuperview()
          make.top.equalToSuperview()
        }
    }
    
    
    
    actionButton.addTarget(self, action: #selector(self.didTapActionButton(_:)), for: UIControl.Event.touchUpInside)
    applyCommunityTheme()
  }
  
  func showImage() {
    guard let image = imageView.image else {
      hideImage()
      return
    }
    
    let imageHeight = image.calculateHeight(for: Layout.imageWidth)
    
    imageViewContainer.snp.remakeConstraints { (make) in
      make.height.equalTo(imageHeight)
    }
    imageView.snp.remakeConstraints { (make) in
      make.width.equalTo(Layout.imageWidth)
      make.height.equalTo(imageHeight)
      make.centerX.equalToSuperview()
    }
    imageViewContainer.isHidden = false
  }
  
  func hideImage() {
    imageViewContainer.isHidden = true
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
    
    if let buttonTitle = message.buttonTitle {
      actionButton.setTitle(buttonTitle, for: UIControl.State.normal)
      buttonContainer.isHidden = false
    } else {
      buttonContainer.isHidden = true
    }
  }
  
  @objc func didTapActionButton(_ sender: UIButton) {
    delegate?.didTapActionButton()
  }
}
extension ErrorMessageCollectionViewCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    actionButton.backgroundColor = colors.primary
    actionButton.setTitleColor(colors.background, for: UIControl.State.normal)
  }
}
