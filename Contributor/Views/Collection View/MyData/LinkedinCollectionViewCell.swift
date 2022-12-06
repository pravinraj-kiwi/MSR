//
//  LinkedinCollectionViewCell.swift
//  Contributor
//
//  Created by KiwiTech on 3/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol LinkedinViewDelegate: class {
    func clickToOpenConnectionScreen(appType: ConnectedApp)
    func clickToCloseAdView(appType: ConnectedApp)
}

class LinkedinCollectionViewCell: UICollectionViewCell {
    
  weak var linkedinViewDelegate: LinkedinViewDelegate?
  var appType: ConnectedApp = .linkedin
    
  struct Layout {
    static var contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    static var labelInset = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
    static let borderHeight: CGFloat = 1
    static let borderBottomMargin: CGFloat = 10
    static let imageBottomMargin: CGFloat = 24
    static let dashViewBottomMargin: CGFloat = 30
    static let dashViewHeight: CGFloat = 85
    static let linkedinViewHeight: CGFloat = 57
    static let linkedinImageWidth: CGFloat = 30
    static let linkedinImageTrailing: CGFloat = 11
    static let linkedinViewLeadingTrailing: CGFloat = 14
    static let linkedinButtonsWidth: CGFloat = 49
    static let linkedinButtonsHeight: CGFloat = 29
    static let linkedinImageHeight: CGFloat = 49
    static var detailLabelMarginInset = UIEdgeInsets(top: 0, left: 27, bottom: 0, right: -27)
    static let titleFont = Font.regular.of(size: 16)
    static let buttonFont = Font.regular.of(size: 16)
    static let titleLabelBottomMargin: CGFloat = 10
    static let dashTitleFont = Font.regular.of(size: 16)
    static var lineSpacing = Constants.defaultLineSpacing
    static var defaultStackSpacing: CGFloat = 5
  }

  let border1: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
    return view
  }()

  let imageView: UIImageView = {
    let imagev = UIImageView()
    imagev.contentMode = .scaleAspectFit
    imagev.clipsToBounds = true
    return imagev
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.titleFont
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    return label
  }()
    
  let dashView: DashBorderView = {
    let view = DashBorderView()
    view.dashColor = Color.dashColor.value
    view.dashWidth = 1
    view.dashLength = 5
    view.betweenDashesSpace = 10
    view.backgroundColor = Color.mydataBackroundColor.value
    return view
  }()
    
  let dashLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.dashTitleFont
    label.textColor = .black
    label.numberOfLines = 0
    return label
 }()
    
 let adView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 3
    view.backgroundColor = Color.veryLightBorder.value
    return view
 }()
    
 let adImageView: UIImageView = {
    let adImagev = UIImageView()
    adImagev.contentMode = .scaleAspectFit
    adImagev.clipsToBounds = true
    return adImagev
 }()
    
 let adLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.titleFont
    label.text = ConnectedAppCellText.connectedLinkedinText.localized()
    label.textColor = Color.linkedinTextColor.value
    label.numberOfLines = 0
    return label
 }()
    
 let adYesButton: UIButton = {
    let linkedinYesButton = UIButton()
    linkedinYesButton.setTitle(ConnectedAppCellText.connectedYesButtonText.localized(), for: .normal)
    linkedinYesButton.setTitleColor(.white, for: .normal)
    linkedinYesButton.layer.cornerRadius = 2
    linkedinYesButton.setBackgroundColor(color: Constants.primaryColor, forState: .normal)
    linkedinYesButton.titleLabel?.font = Layout.buttonFont
    linkedinYesButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.09).cgColor
    linkedinYesButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
    linkedinYesButton.layer.shadowRadius = 1.0
    linkedinYesButton.layer.shadowOpacity = 0.7
    return linkedinYesButton
 }()
    
 let adNoButton: UIButton = {
    let linkedinNoButton = UIButton()
    linkedinNoButton.setTitle(ConnectedAppCellText.connectedNoButtonText.localized(), for: .normal)
    linkedinNoButton.setTitleColor(.white, for: .normal)
    linkedinNoButton.layer.cornerRadius = 2
    linkedinNoButton.setBackgroundColor(color: Constants.primaryColor, forState: .normal)
    linkedinNoButton.titleLabel?.font = Layout.buttonFont
    linkedinNoButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.09).cgColor
    linkedinNoButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
    linkedinNoButton.layer.shadowRadius = 1.0
    linkedinNoButton.layer.shadowOpacity = 0.7
    return linkedinNoButton
 }()
    
 let stackView: UIStackView = {
   let stack = UIStackView(frame: CGRect.zero)
   stack.axis = .vertical
   stack.distribution = .fill
   stack.spacing = Layout.defaultStackSpacing
   return stack
 }()

    //view
  static func calculateHeightForWidth(message: MessageHolder,
                                      adData: ConnectedAppData?, width: CGFloat) -> CGFloat {
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
      titleLabelHeight = TextSize.calculateHeight(title, font: Layout.titleFont,
                                                  width: labelWidth, lineSpacing: Layout.lineSpacing)
      titleLabelBottomMargin = Layout.titleLabelBottomMargin
    }
    
    var linkedinViewHeight: CGFloat = 0
    var linkedinViewBottomMargin: CGFloat = 0
    if let data = adData?.displayAd, data == true {
        linkedinViewHeight = Layout.linkedinViewHeight
        linkedinViewBottomMargin = Layout.dashViewBottomMargin
    }
    
     let height: CGFloat = Layout.borderHeight
        + Layout.borderBottomMargin
        + imageHeight
        + imageBottomMargin
        + titleLabelHeight
        + titleLabelBottomMargin
        + linkedinViewHeight
        + linkedinViewBottomMargin
           
    return height
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    addListeners()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
    addListeners()
  }
    
 func addListeners() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateLinkedinData),
                                           name: NSNotification.Name.connectingAppStatusChanged, object: nil)
 }

 func setupViews() {
    let contentWidth = contentView.frame.width - Layout.contentInset.left - Layout.contentInset.right
    
    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { (make) in
        make.top.equalTo(contentView.snp.top).offset(Layout.borderBottomMargin)
        make.width.equalTo(contentWidth)
        make.centerX.equalToSuperview()
        make.bottom.equalToSuperview()
    }

    stackView.addArrangedSubview(imageView)
    stackView.setCustomSpacing(Layout.imageBottomMargin, after: imageView)
    stackView.addArrangedSubview(titleLabel)
    stackView.setCustomSpacing(Layout.imageBottomMargin, after: titleLabel)
    stackView.addArrangedSubview(adView)
    stackView.setCustomSpacing(Layout.dashViewBottomMargin, after: adView)

    let labelWidth = contentWidth - Layout.labelInset.left - Layout.labelInset.right
    
    titleLabel.snp.makeConstraints { (make) in
        make.width.greaterThanOrEqualTo(labelWidth)
    }
    
    dashView.snp.makeConstraints { (make) in
        make.width.equalTo(contentWidth)
        make.height.equalTo(Layout.dashViewHeight)
    }
    
    dashView.addSubview(dashLabel)
    dashLabel.snp.makeConstraints { (make) in
        make.leading.equalTo(Layout.detailLabelMarginInset.left)
        make.trailing.equalTo(Layout.detailLabelMarginInset.right)
        make.top.equalTo(Layout.detailLabelMarginInset.top)
        make.bottom.equalTo(Layout.detailLabelMarginInset.bottom)
    }
    
    adView.snp.makeConstraints { (make) in
        make.width.equalTo(contentWidth)
        make.height.equalTo(Layout.linkedinViewHeight)
    }
    
    adView.addSubview(adImageView)
    adImageView.snp.makeConstraints { (make) in
        make.leading.equalTo(Layout.linkedinImageTrailing)
        make.width.equalTo(Layout.linkedinImageWidth)
        make.centerY.equalTo(adView)
    }
    
    adView.addSubview(adLabel)
    adLabel.snp.makeConstraints { (make) in
        make.centerY.equalTo(adImageView)
        make.leading.equalTo(adImageView.snp.trailing).offset(11)
    }
    
    adView.addSubview(adYesButton)
    adYesButton.snp.makeConstraints { (make) in
        make.centerY.equalTo(adLabel)
        make.height.equalTo(Layout.linkedinButtonsHeight)
        make.width.equalTo(Layout.linkedinButtonsWidth)
     }
       
    adYesButton.addTarget(self, action: #selector(self.clickToConnectApp), for: UIControl.Event.touchUpInside)
    
    adView.addSubview(adNoButton)
    adNoButton.snp.makeConstraints { (make) in
        make.centerY.equalTo(adYesButton)
        make.trailing.equalTo(adView.snp.trailing).offset(-11)
        make.leading.equalTo(adYesButton.snp.trailing).offset(6)
        make.height.equalTo(Layout.linkedinButtonsHeight)
        make.width.equalTo(Layout.linkedinButtonsWidth)
    }
    
    adNoButton.addTarget(self, action: #selector(self.closeAd), for: UIControl.Event.touchUpInside)
    applyCommunityTheme()
  }
    
  deinit {
     NotificationCenter.default.removeObserver(self)
    }
}
extension LinkedinCollectionViewCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
     adNoButton.setBackgroundColor(color: colors.primary, forState: .normal)
     adYesButton.setBackgroundColor(color: colors.primary, forState: .normal)
  }
}
