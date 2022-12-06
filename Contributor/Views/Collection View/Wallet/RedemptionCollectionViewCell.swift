//
//  RedemptionCollectionViewCell.swift
//  Contributor
//
//  Created by John Martin on 8/15/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

protocol RedemptionCollectionViewCellDelegate: class {
  func didTapRedeemButton(for balance: Balance)
}

class RedemptionCollectionViewCell: UICollectionViewCell {
  struct Layout {
    static var contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    static let amountAvailableTopMargin: CGFloat = 5
    static let amountLabelWidth: CGFloat = 100
    static let dateFont = Font.regular.of(size: 13)
    static let descriptionFont = Font.regular.of(size: 16)
    static let amountFont = Font.semiBold.of(size: 16)
    static var redeemButtonFont = Font.semiBold.of(size: 14)
    static var redeemButtonHeight: CGFloat = 30
    static var redeemButtonWidth: CGFloat = 82
    static var redeemButtonCornerRadius: CGFloat = redeemButtonHeight / 2
    static let borderHeight: CGFloat = 1
  }
    
  let textContainer = UIView()
  
  let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.descriptionFont
    label.textColor = Color.text.value
    return label
  }()
  
  let amountAvailableLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.dateFont
    label.textColor = Color.lightText.value
    return label
  }()
  
  let redeemButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = Color.lightBackground.value
    button.setTitle(Text.redeemButtonTitleText.localized(), for: .normal)
    button.setTitleColor(Color.lightText.value, for: .disabled)
    button.titleLabel?.font = Layout.redeemButtonFont
    button.layer.cornerRadius = Layout.redeemButtonCornerRadius
    button.setBackgroundColor(color: Color.border.value, forState: .highlighted)
    return button
  }()
  
  let border1: UIView = {
    let view = UIView()
    view.backgroundColor = Color.veryLightBorder.value
    return view
  }()
  
  var balanceType: String?
  weak var delegate: RedemptionCollectionViewCellDelegate?
  let generator = UIImpactFeedbackGenerator(style: .light)

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    addListeners()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addListeners() {
    NotificationCenter.default.addObserver(self, selector: #selector(onBalanceUpdated), name: NSNotification.Name.balanceChanged, object: nil)
  }

  func setupViews() {
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.addSubview(textContainer)
    textContainer.snp.makeConstraints { make in
      make.left.equalToSuperview().inset(Layout.contentInset)
      make.centerY.equalToSuperview()
    }
    
    textContainer.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.top.left.right.equalToSuperview()
    }
    
    textContainer.addSubview(amountAvailableLabel)
    amountAvailableLabel.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(Layout.amountAvailableTopMargin)
      make.left.right.bottom.equalToSuperview()
    }

    contentView.addSubview(redeemButton)
    redeemButton.snp.remakeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().inset(Layout.contentInset)
      make.width.equalTo(Layout.redeemButtonWidth)
      make.height.equalTo(Layout.redeemButtonHeight)
    }
    redeemButton.addTarget(self, action: #selector(redeem), for: .touchUpInside)

    contentView.addSubview(border1)
    border1.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.height.equalTo(Layout.borderHeight)
      make.left.right.equalToSuperview().inset(Layout.contentInset)
    }
    
    applyCommunityTheme()
  }
  
  func showBorder() {
    border1.snp.updateConstraints { make in
      make.height.equalTo(Layout.borderHeight)
    }
  }
  
  func hideBorder() {
    border1.snp.updateConstraints { make in
      make.height.equalTo(0)
    }
  }
  
  func updateValues(with balance: Balance) {
    descriptionLabel.text = "Redeem for \(balance.walletTitle)"
    amountAvailableLabel.text = "\(balance.balanceMSR.formattedMSRString) available"
    
    if balance.isDefaultBalance || balance.balanceMSR > 0 {
      redeemButton.isEnabled = true
      redeemButton.alpha = 1.0
    } else {
      redeemButton.isEnabled = false
      redeemButton.alpha = 0.5
    }
  }
  
  func configure(with balance: Balance, isLastInList: Bool = false) {
    balanceType = balance.balanceType
    updateValues(with: balance)
    isLastInList ? hideBorder() : showBorder()
  }
  
  @objc func onBalanceUpdated() {
    guard let user = UserManager.shared.user else {
      return
    }
    
    if let balanceType = balanceType, let balance = user.getBalance(forType: balanceType) {
      updateValues(with: balance)
    }
  }
  
  @objc func redeem() {
    guard let user = UserManager.shared.user else {
      return
    }

    if let balanceType = balanceType, let balance = user.getBalance(forType: balanceType), balance.isDefaultBalance || balance.balanceMSR > 0 {
      
      // bzzzz
      generator.impactOccurred()

      delegate?.didTapRedeemButton(for: balance)
    }
  }
}

extension RedemptionCollectionViewCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let colors = UserManager.shared.currentCommunity?.colors else {
      return
    }

    redeemButton.setTitleColor(colors.primary, for: .normal)
  }
}
