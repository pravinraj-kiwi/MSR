//
//  MessageViewController.swift
//  Contributor
//
//  Created by arvindh on 20/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import SnapKit

protocol MessageViewControllerDelegate: class {
  func didTapActionButton()
}

class MessageViewController: UIViewController {
  struct Layout {
    static let imageViewBottomMargin: CGFloat = 24
    static let labelLeftMargin: CGFloat = 14
    static let labelRightMargin: CGFloat = 14
    static let titleLabelBottomMargin: CGFloat = 10
    static let detailLabelBottomMargin: CGFloat = 16
    static let actionButtonBottomMargin: CGFloat = 18
    static let actionButtonSize: CGSize = CGSize(width: 160, height: 44)
  }
  
  var messageHolder: MessageHolder
  weak var delegate: MessageViewControllerDelegate?
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    return iv
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.bold.of(size: 20)
    label.numberOfLines = 0
    label.textAlignment = .center
    label.backgroundColor = Constants.backgroundColor
    label.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    return label
  }()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 18)
    label.textColor = Color.lightText.value
    label.textAlignment = .center
    label.numberOfLines = 0
    label.backgroundColor = Constants.backgroundColor
    label.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
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
  
  var buttonHeightConstraint: Constraint!

  init(messageHolder: MessageHolder) {
    self.messageHolder = messageHolder
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupViews()
    updateViews()
  }

  override func setupViews() {
    view.backgroundColor = Constants.backgroundColor
    
    view.addSubview(imageView)
    imageView.snp.makeConstraints { (make) in
      make.top.equalTo(view)
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.height.lessThanOrEqualTo(150)
    }
    
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(imageView.snp.bottom).offset(Layout.imageViewBottomMargin)
      make.left.equalTo(view).offset(Layout.labelLeftMargin)
      make.right.equalTo(view).offset(-Layout.labelRightMargin)
    }
    
    view.addSubview(detailLabel)
    detailLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(Layout.titleLabelBottomMargin)
      make.left.equalTo(titleLabel)
      make.right.equalTo(titleLabel)
    }
    
    view.addSubview(actionButton)
    actionButton.snp.makeConstraints { (make) in
      make.top.equalTo(detailLabel.snp.bottom).offset(Layout.detailLabelBottomMargin)
      make.centerX.equalTo(view)
      make.width.equalTo(Layout.actionButtonSize.width)
      self.buttonHeightConstraint = make.height.equalTo(Layout.actionButtonSize.height).constraint
      make.bottom.equalTo(view).offset(-Layout.actionButtonBottomMargin)
    }
  }
  
  func updateViews() {
    imageView.image = messageHolder.image?.value
    titleLabel.attributedText = messageHolder.title?.lineSpacedAndCentered(1.2)
    detailLabel.attributedText = messageHolder.detail?.lineSpacedAndCentered(1.2)
    
    if let buttonTitle = messageHolder.buttonTitle {
      actionButton.setTitle(buttonTitle, for: UIControl.State.normal)
    }
    else {
      buttonHeightConstraint.update(offset: 0)
    }
    
    actionButton.addTarget(self, action: #selector(self.didTapActionButton(_:)), for: UIControl.Event.touchUpInside)
    applyCommunityTheme()
  }
  
  @objc func didTapActionButton(_ sender: UIButton) {
    delegate?.didTapActionButton()
  }
}
extension MessageViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
     actionButton.setBackgroundColor(color: colors.primary, forState: .normal)
  }
}
