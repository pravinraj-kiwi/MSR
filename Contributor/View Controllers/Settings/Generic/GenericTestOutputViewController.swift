//
//  GenericTestOutputViewController.swift
//  Contributor
//
//  Created by John Martin on 1/13/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import os
import UIKit
import UserNotifications
import SwiftyUserDefaults

class GenericTestOutputViewController: UIViewController {
  struct Layout {
    static let topMargin: CGFloat = 200
    static let contentMaxWidth: CGFloat = 300
    static let imageSize: CGFloat = 100
    static let imageTopMargin: CGFloat = 20
    static let imageBottomMargin: CGFloat = 40
    static let titleBottomMargin: CGFloat = 20
    static let detailBottomMargin: CGFloat = 30
    static let actionButtonBottomMargin: CGFloat = 20
    static let actionButtonWidth: CGFloat = 120
    static let actionButtonHeight: CGFloat = 44
    static let containerInset: CGFloat = 20
  }
  
  let container: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    return view
  }()
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.backgroundColor = Constants.backgroundColor
    iv.image = Message.ageRequirementNotMet.image?.value
    return iv
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 20)
    label.backgroundColor = Constants.backgroundColor
    label.textAlignment = .center
    label.attributedText = Message.ageRequirementNotMet.title.lineSpacedAndCentered(1.2)
    return label
  }()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 18)
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.textColor = Color.lightText.value
    label.textAlignment = .center
    label.attributedText = Message.ageRequirementNotMet.detail.lineSpacedAndCentered(1.2)
    return label
  }()
  
  let actionButton: UIButton = {
    let button = UIButton(type: UIButton.ButtonType.custom)
    button.setDarkeningBackgroundColor(color: Constants.primaryColor)
    button.setTitleColor(Constants.backgroundColor, for: UIControl.State.normal)
    button.titleLabel?.font = Font.regular.of(size: 18)
    button.setTitle(Message.ageRequirementNotMet.buttonTitle, for: UIControl.State.normal)
    button.layer.cornerRadius = Constants.buttonCornerRadius
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    AnalyticsManager.shared.log(event: .ageWarningDisplayed)
  }
  
  override func setupViews() {
    view.backgroundColor = Constants.backgroundColor
    
    view.addSubview(container)
    container.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.view)
      make.top.equalTo(Layout.topMargin)
      make.bottom.equalTo(self.view).offset(-Layout.containerInset)
      make.width.lessThanOrEqualTo(Layout.contentMaxWidth).priority(751)
      make.left.greaterThanOrEqualToSuperview().offset(Layout.containerInset).priority(750)
      make.right.greaterThanOrEqualToSuperview().offset(-Layout.containerInset).priority(750)
    }
    
    container.addSubview(imageView)
    imageView.snp.makeConstraints { (make) in
      make.top.equalTo(container).offset(Layout.imageTopMargin)
      make.width.equalTo(Layout.imageSize)
      make.height.equalTo(imageView.snp.width)
      make.centerX.equalTo(container)
    }
    
    container.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(imageView.snp.bottom).offset(Layout.imageBottomMargin)
      make.centerX.equalTo(self.container)
      make.width.equalTo(self.container)
    }
    
    container.addSubview(detailLabel)
    detailLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(Layout.titleBottomMargin)
      make.centerX.equalTo(self.container)
      make.width.equalTo(self.container)
    }
    
    container.addSubview(actionButton)
    actionButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.detailLabel.snp.bottom).offset(Layout.detailBottomMargin)
      make.width.equalTo(Layout.actionButtonWidth)
      make.height.equalTo(Layout.actionButtonHeight)
      make.centerX.equalTo(self.container)
    }
    applyCommunityTheme()
  }
}
extension GenericTestOutputViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    actionButton.setDarkeningBackgroundColor(color: colors.primary)
  }
}
