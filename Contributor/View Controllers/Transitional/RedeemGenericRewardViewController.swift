//
//  RedeemGenericRewardViewController.swift
//  Contributor
//
//  Created by John Martin on 8/18/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import UserNotifications
import SnapKit
import SwiftyUserDefaults

class RedeemGenericRewardViewController: UIViewController {
  struct Layout {
    static var contentInset = UIEdgeInsets(top: 50, left: 30, bottom: 30, right: 30)
    static let containerInset: CGFloat = 30
    static let containerHeight: CGFloat = 390
    static let communityLogoWidth: CGFloat = 200
    static let actionButtonBottomMargin: CGFloat = 15
    static let actionButtonWidth: CGFloat = 210
    static let actionButtonHeight: CGFloat = 44
    static let lineSpacing: CGFloat = 1.2
    static let formStackSpacing: CGFloat = 30
    static let resultStackSpacing: CGFloat = 30
    static var contentFont = Font.regular.of(size: 16)
  }
  
  var balance: Balance!
  
  let container: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    view.layer.cornerRadius = 10
    return view
  }()
  
  let resultContainer = UIView()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.textColor = Color.text.value
    label.textAlignment = .left
    return label
  }()
  
  let continueButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.font = Layout.contentFont
    button.setTitle(Text.continueText.localized(), for: .normal)
    button.layer.cornerRadius = Constants.buttonCornerRadius
    return button
  }()
  
  let resultStackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.alignment = .center
    stack.distribution = .fill
    stack.spacing = Layout.resultStackSpacing
    return stack
  }()
  
  let loadingActivityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: CGRect.zero)
    indicator.color = Color.text.value
    indicator.hidesWhenStopped = true
    return indicator
  }()
  
  let loadingLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 1
    label.textColor = Color.text.value
    label.textAlignment = .center
    label.text = Text.redeeming.localized()
    return label
  }()
  
  let resultImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.backgroundColor = Constants.backgroundColor
    return iv
  }()
  
  let resultLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.textColor = Color.text.value
    label.textAlignment = .center
    return label
  }()
  
  init(balance: Balance) {
    self.balance = balance
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    redeem()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
    
override func viewWillDisappear(_ animated: Bool) {
  super.viewWillDisappear(animated)
  Defaults[.shouldRefreshWallet] = false
}
  
  override func setupViews() {
    view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    
    view.addSubview(container)
    container.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.centerY.equalTo(view)
      make.width.equalToSuperview().inset(Layout.containerInset)
      make.height.equalTo(Layout.containerHeight)
    }
    
    container.addSubview(resultContainer)
    resultContainer.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(Layout.contentInset)
    }

    resultContainer.addSubview(resultStackView)
    resultStackView.snp.makeConstraints { make in
      make.top.left.right.equalToSuperview()
    }
    
    resultStackView.addArrangedSubview(loadingActivityIndicator)
    resultStackView.addArrangedSubview(resultImageView)
    resultStackView.addArrangedSubview(resultLabel)

    loadingActivityIndicator.startAnimating()
    loadingActivityIndicator.isHidden = false

    resultImageView.isHidden = true
    
    resultLabel.attributedText = RedeemText.title.localized().lineSpacedAndCentered(Layout.lineSpacing)
    resultLabel.isHidden = false
    
    applyCommunityTheme()
  }
  
  func showSuccess(message: String) {
    loadingActivityIndicator.isHidden = true
    loadingActivityIndicator.stopAnimating()
    
    resultImageView.image = Image.validationSuccess.value
    resultImageView.isHidden = false
    
    resultLabel.attributedText = message.lineSpacedAndCentered(Layout.lineSpacing)
    
    resultContainer.addSubview(continueButton)
    continueButton.snp.makeConstraints { make in
      make.bottom.width.equalToSuperview()
      make.height.equalTo(Layout.actionButtonHeight)
      make.centerX.equalTo(resultContainer)
    }
    continueButton.addTarget(self, action: #selector(onContinue), for: .touchUpInside)
    
    view.setNeedsUpdateConstraints()
  }
  
  func showError() {
    loadingActivityIndicator.isHidden = true
    loadingActivityIndicator.stopAnimating()
    
    resultImageView.image = Image.validationFailure.value
    resultImageView.isHidden = false
    
    resultLabel.attributedText = "\(RedeemText.error.localized()) \(balance.walletTitle). \(RedeemText.redeemTryAgain.localized())".lineSpacedAndCentered(Layout.lineSpacing)
    
    view.setNeedsUpdateConstraints()
  }
  
  @objc func onContinue() {
    self.dismissSelf()
  }
  
  @objc func redeem() {
    let params = GenericRewardRedemptionParams(redemptionType: balance.balanceType)
    
    NetworkManager.shared.redeemGenericReward(params) {
      [weak self] response, error in
      guard let this = self else {
        return
      }

      if let error = error {
        os_log("Error redeeming for %{public}@: %{public}@", log: OSLog.wallet, type: .error, this.balance.balanceType, error.localizedDescription)
        this.showError()
      } else {
        os_log("Redeemed %{public}@", log: OSLog.wallet, type: .info, this.balance.balanceType)
        let successMessage = response?.message ?? "Successfully redeemed \(this.balance.walletTitle)."
        this.showSuccess(message: successMessage)
        NetworkManager.shared.reloadCurrentUser() {_ in }
      }
    }
  }
}

extension RedeemGenericRewardViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    continueButton.setTitleColor(colors.whiteText, for: .normal)
    continueButton.setDarkeningBackgroundColor(color: colors.primary)
  }
}
