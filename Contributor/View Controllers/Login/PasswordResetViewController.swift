//
//  PasswordResetViewController.swift
//  Contributor
//
//  Created by arvindh on 09/04/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SnapKit
import os

class PasswordResetViewController: UIViewController, KeyboardDisplayable, StaticViewDisplayable, MessageViewControllerDelegate {
  struct Layout {
    static let topMargin: CGFloat = 70
    static let topMarginWithKeyboard: CGFloat = 30
    static let contentMaxWidth: CGFloat = 300
    static let titleBottomMargin: CGFloat = 20
    static let detailBottomMargin: CGFloat = 30
    static let didNotReceiveEmailButtonWidth: CGFloat = 260
    static let didNotReceiveEmailButtonHeight: CGFloat = 44
    static let didNotReceiveEmailButtonBottomMargin: CGFloat = 30
    static let sendButtonWidth: CGFloat = 190
    static let sendButtonHeight: CGFloat = 44
    static var fieldHeight: CGFloat = 50
    static let containerInset: CGFloat = 20
    static let lineSpacing: CGFloat = 1.2
  }
  
  var staticMessageViewController: FullScreenMessageViewController?
  
  let container: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    view.hugContent(in: NSLayoutConstraint.Axis.vertical)
    return view
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.bold.of(size: 18)
    label.textAlignment = .center
    label.backgroundColor = Constants.backgroundColor
    label.text = Message.forgotPassword.title
    label.hugContent(in: NSLayoutConstraint.Axis.vertical)
    return label
  }()
  
  let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 18)
    label.numberOfLines = 0
    label.backgroundColor = Constants.backgroundColor
    label.textColor = Color.lightText.value
    label.attributedText = Message.forgotPassword.detail.lineSpacedAndCentered(Layout.lineSpacing)
    label.hugContent(in: NSLayoutConstraint.Axis.vertical)
    return label
  }()
  
  let emailField: MSRTextField = {
    let tf = MSRTextField(frame: CGRect.zero)
    tf.textField.font = Font.regular.of(size: 18)
    tf.textField.placeholder = PlaceholderText.email.localized()
    tf.textField.autocorrectionType = .no
    tf.textField.autocapitalizationType = .none
    tf.textField.textContentType = UITextContentType.emailAddress
    tf.textField.text = UserManager.shared.user?.email
    tf.validation = MSRTextfieldValidation.email
    return tf
  }()
  
  let sendButton: ActivityIndicatorButton = {
    let button = ActivityIndicatorButton(frame: CGRect.zero)
    button.setTitle(Text.sendLink.localized(), for: UIControl.State.normal)
    return button
  }()

  var keyboardWrapper: KeyboardWrapper!
  var bottomConstraint: Constraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    keyboardWrapper = KeyboardWrapper(delegate: self)
    setupViews()
    hideBackButtonTitle()
    setupTextChangeListeners()
    
    enableOrDisableActionButton(nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.forgotPasswordScreen)
  }
  
  override func setupViews() {
    view.backgroundColor = Constants.backgroundColor
    
    view.addSubview(container)
    container.snp.makeConstraints { (make) in
      make.center.equalTo(self.view)
      make.top.greaterThanOrEqualTo(self.view).offset(Layout.topMargin).priority(500)
      make.bottom.greaterThanOrEqualTo(self.view).offset(-Layout.containerInset).priority(500)
      make.width.lessThanOrEqualTo(Layout.contentMaxWidth).priority(751)
      make.left.greaterThanOrEqualToSuperview().offset(Layout.containerInset).priority(750)
      make.right.greaterThanOrEqualToSuperview().offset(-Layout.containerInset).priority(750)
    }
    
    container.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(container)
      make.left.equalTo(container)
      make.right.equalTo(container)
    }
    
    container.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(Layout.titleBottomMargin)
      make.left.equalTo(titleLabel)
      make.right.equalTo(titleLabel)
    }
    
    container.addSubview(emailField)
    emailField.snp.makeConstraints { (make) in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(Layout.titleBottomMargin)
      make.left.equalTo(container)
      make.right.equalTo(container)
      make.height.equalTo(Layout.fieldHeight)
    }
    
    container.addSubview(sendButton)
    sendButton.snp.makeConstraints { (make) in
      make.top.equalTo(emailField.snp.bottom).offset(Layout.detailBottomMargin)
      make.centerX.equalTo(container)
      make.width.equalTo(Layout.sendButtonWidth)
      make.height.equalTo(Layout.sendButtonHeight)
      bottomConstraint = make.bottom.equalTo(container).constraint
    }
    sendButton.addTarget(self, action: #selector(self.resetPassword), for: UIControl.Event.touchUpInside)
    
    applyCommunityTheme()
  }

  @objc func resetPassword() {
    emailField.resignFirstResponder()
    
    if let _ = emailField.validate() {
      
    }
    else {
      guard let text = emailField.text, !text.isEmpty else {
        return
      }
      
      sendButton.state = .loading
      NetworkManager.shared.requestPasswordReset(email: text) {
        [weak self] (error) in
        guard let this = self else {
          return
        }
        this.sendButton.state = .normal
        if let error = error {
          os_log("Error requesting password reset: %{public}@", log: OSLog.settings, error.localizedDescription)
        }
        else {
          this.view.endEditing(true)
          this.show(staticMessage: MessageHolder(message: Message.passwordResetSuccess))
        }
      }
    }
  }
  
  func setupTextChangeListeners() {
    emailField.onTextChange = {
      [weak self] textField, text in
      
      self?.enableOrDisableActionButton(text)
    }
    
    emailField.onErrorButtonTapped = {
      [weak self] textfield, error in
      
      guard let this = self else {
        return
      }
      
      let alerter = Alerter(viewController: this)
        alerter.alert(title: Text.error.localized(), message: error.localizedDescription,
                      confirmButtonTitle: nil, cancelButtonTitle: Text.ok.localized(),
                      onConfirm: nil, onCancel: nil)
    }
    
    emailField.onShouldReturn = {
      [weak self] textField in
      
      textField.resignFirstResponder()
      self?.resetPassword()
    }
  }
  
  func enableOrDisableActionButton(_ text: String?) {
    if let text = text, !text.isEmpty {
      sendButton.isEnabled = true
      return
    }

    sendButton.isEnabled = false
  }
  
  func didTapActionButton() {
    Router.shared.route(to: Route.login, from: self, presentationType: PresentationType.pop)
  }
}

extension PasswordResetViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity,
          let colors = community.colors,
          let _ = community.images else {
      return
    }
    
    sendButton.setDarkeningBackgroundColor(color: colors.primary)
    sendButton.buttonTitleColor = colors.whiteText
    sendButton.spinnerColor = colors.text
  }
}
