//
//  ReferFriendViewController.swift
//  Contributor
//
//  Created by arvindh on 05/07/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class ReferFriendViewController: UIViewController {
  struct Layout {
    static var titleFont = Font.bold.of(size: 16)
    static var detailFont = Font.regular.of(size: 16)
    static var statusFont = Font.regular.of(size: 14)
    static var actionButtonFont = Font.semiBold.of(size: 14)
    static var lineSpacing: CGFloat = 1.2
    static var borderHeight: CGFloat = 1
    static var maxBorderWidth: CGFloat = 200
    static let titleTopMargin: CGFloat = 40
    static let titleBottomMargin: CGFloat = 10
    static let titleHeight: CGFloat = 24
    static let detailBottomMargin: CGFloat = 15
    static let actionButtonBottomMargin: CGFloat = 15
    static let actionButtonWidth: CGFloat = 85
    static let actionButtonHeight: CGFloat = 30
    static var actionButtonCornerRadius: CGFloat = actionButtonHeight / 2
    static let statusLabelBottomMargin: CGFloat = 20
    static let containerInset: CGFloat = 20
    static let maxContentWidth: CGFloat = 250
  }
  
  static func generateDetailText(user: User) -> String {
    return "\(ReferFriendViewText.earn) \(user.invitationRewardMSR) \(ReferFriendViewText.referMessage)"
  }

  static func generateStatusText(user: User) -> String {
    return "\(user.remainingInvitations) \(Text.of.localized()) \(user.invitationLimit) \(ReferFriendViewText.remainingInvite)"
  }

  static func calculateHeightForWidth(width: CGFloat) -> CGFloat {
    let maxPossibleContentWidth = width - 2 * Layout.containerInset
    let contentWidth = maxPossibleContentWidth < Layout.maxContentWidth ? maxPossibleContentWidth : Layout.maxContentWidth
    
    guard let user = UserManager.shared.user else {
      return 0
    }
    
    let titleLabelHeight = TextSize.calculateHeight(ReferFriendViewText.titleText,
                                                    font: Layout.titleFont, width: contentWidth,
                                                    lineSpacing: Layout.lineSpacing)
    let detailLabelHeight = TextSize.calculateHeight(generateDetailText(user: user),
                                                     font: Layout.detailFont, width: contentWidth,
                                                     lineSpacing: Layout.lineSpacing)
    let statusLabelHeight = TextSize.calculateSingleLineHeight(font: Layout.statusFont, width: contentWidth)
    
    let height: CGFloat = Layout.borderHeight
      + Layout.titleTopMargin
      + titleLabelHeight
      + Layout.titleBottomMargin
      + detailLabelHeight
      + Layout.detailBottomMargin
      + Layout.actionButtonHeight
      + Layout.actionButtonBottomMargin
      + statusLabelHeight
      + Layout.statusLabelBottomMargin
    
    return height
  }
  
  let generator = UIImpactFeedbackGenerator(style: .light)
  
  let border1: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
    return view
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.titleFont
    label.textAlignment = .center
    label.backgroundColor = Constants.backgroundColor
    label.textColor = Color.text.value
    label.hugContent(in: NSLayoutConstraint.Axis.vertical)
    return label
  }()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.detailFont
    label.textColor = Color.text.value
    label.textAlignment = .center
    label.backgroundColor = Constants.backgroundColor
    label.hugContent(in: NSLayoutConstraint.Axis.vertical)
    label.numberOfLines = 0
    return label
  }()
  
  let actionButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = Color.lightBackground.value
    button.setTitle(ReferFriendViewText.actionButtonText, for: .normal)
    button.titleLabel?.font = Layout.actionButtonFont
    button.layer.cornerRadius = Layout.actionButtonCornerRadius
    button.setBackgroundColor(color: Color.border.value, forState: .highlighted)
    return button
  }()
  
  let statusLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.statusFont
    label.textColor = Color.lightText.value
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupViews()
  }

  override func setupViews() {
    view.backgroundColor = Constants.backgroundColor
    
    guard let user = UserManager.shared.user else {
      return
    }

    view.addSubview(border1)
    border1.snp.makeConstraints { (make) in
      make.top.equalTo(view)
      make.height.equalTo(Layout.borderHeight)
      make.width.lessThanOrEqualTo(Layout.maxContentWidth)
      make.width.lessThanOrEqualTo(view).inset(Layout.containerInset)
      make.centerX.equalTo(view)
    }

    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(border1).offset(Layout.titleTopMargin)
      make.width.lessThanOrEqualTo(Layout.maxContentWidth)
      make.width.lessThanOrEqualTo(view).inset(Layout.containerInset)
      make.centerX.equalTo(view)
      make.height.equalTo(Layout.titleHeight)
    }
    
    view.addSubview(detailLabel)
    detailLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(Layout.titleBottomMargin)
      make.width.lessThanOrEqualTo(Layout.maxContentWidth)
      make.width.lessThanOrEqualTo(view).inset(Layout.containerInset)
      make.centerX.equalTo(view)
    }
    
    view.addSubview(actionButton)
    actionButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.detailLabel.snp.bottom).offset(Layout.detailBottomMargin)
      make.width.equalTo(Layout.actionButtonWidth)
      make.height.equalTo(Layout.actionButtonHeight)
      make.centerX.equalTo(view)
    }
    actionButton.addTarget(self, action: #selector(self.actionButtonTapped(_:)), for: .touchUpInside)

    view.addSubview(statusLabel)
    statusLabel.snp.makeConstraints { (make) in
      make.top.equalTo(actionButton.snp.bottom).offset(Layout.actionButtonBottomMargin)
      make.width.lessThanOrEqualTo(Layout.maxContentWidth)
      make.width.lessThanOrEqualTo(view).inset(Layout.containerInset)
      make.centerX.equalTo(view)
    }

    titleLabel.attributedText = ReferFriendViewText.titleText.lineSpacedAndCentered(Layout.lineSpacing)
    detailLabel.attributedText = ReferFriendViewController.generateDetailText(user: user).lineSpacedAndCentered(Layout.lineSpacing)
    statusLabel.attributedText = ReferFriendViewController.generateStatusText(user: user).lineSpacedAndCentered(Layout.lineSpacing)

    applyCommunityTheme()
  }
  
  @objc func actionButtonTapped(_ sender: UIButton) {
    guard let inviteCode = UserManager.shared.user?.inviteCode else {
      return
    }
    
    // bzzzz
    generator.impactOccurred()
    
    let activityItems: [Any] = [
      ReferFriendViewText.downloadText,
      URL(string: "\(Constants.baseContributorURLString)/i/\(inviteCode)")!
    ]
    
    let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    activityViewController.completionWithItemsHandler = {
      activityType, completed, returnedItems, error  in
      AnalyticsManager.shared.log(event: .friendReferred)
    }
    present(activityViewController, animated: true, completion: nil)
  }
}

extension ReferFriendViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    actionButton.setTitleColor(colors.primary, for: .normal)
  }
}
