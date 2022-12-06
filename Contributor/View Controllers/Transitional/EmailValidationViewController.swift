//
//  EmailValidationViewController.swift
//  Contributor
//
//  Created by John Martin on 1/23/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import UserNotifications
import SnapKit
import SwiftyAttributes

class EmailValidationViewController: UIViewController, KeyboardWrapperDelegate {
  struct Layout {
    static let topMargin: CGFloat = 200
    static let topMarginWithKeyboard: CGFloat = 30
    static let contentMaxWidth: CGFloat = 300
    static let imageSize: CGFloat = 100
    static let imageTopMargin: CGFloat = 20
    static let imageBottomMargin: CGFloat = 40
    static let titleBottomMargin: CGFloat = 20
    static let detailBottomMargin: CGFloat = 30
    static let didNotReceiveEmailButtonWidth: CGFloat = 260
    static let didNotReceiveEmailButtonHeight: CGFloat = 44
    static let didNotReceiveEmailButtonBottomMargin: CGFloat = 30
    static let resendButtonWidth: CGFloat = 190
    static let resendButtonHeight: CGFloat = 44
    static var fieldHeight: CGFloat = 58
    static let containerInset: CGFloat = 20
    static let linkFont = Font.regular.of(size: 18)
  }
  
  var keyboardWrapper: KeyboardWrapper!
  var topConstraint: Constraint!

  let container: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    return view
  }()
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.backgroundColor = Constants.backgroundColor
    iv.image = Message.emailValidation.image?.value
    return iv
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 20)
    label.backgroundColor = Constants.backgroundColor
    label.textAlignment = .center
    label.attributedText = Message.emailValidation.title.lineSpacedAndCentered(1.2)
    return label
  }()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 18)
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.textColor = Color.lightText.value
    label.textAlignment = .center
    label.attributedText = Message.emailValidation.detail.lineSpacedAndCentered(1.2)
    return label
  }()
  
  @objc let didNotReceiveEmailButton: UIButton = {
    let button = UIButton(type: .custom)
    return button
  }()

  var emailField: MSRTextField = {
    let tf = MSRTextField(frame: CGRect.zero)
    tf.textField.placeholder = Text.email.localized()
    tf.textField.autocorrectionType = .no
    tf.textField.textContentType = UITextContentType.emailAddress
    tf.textField.text = UserManager.shared.user?.email
    return tf
  }()

  let emailFieldCardView: CardContainerView = {
    let cv = CardContainerView()
    cv.cornerRadius = 2
    return cv
  }()
  
  let emailFieldContainer: UIView = {
    let c = UIView()
    c.backgroundColor = Constants.backgroundColor
    return c
  }()

  let resendButton = ActivityIndicatorButton(frame: CGRect.zero)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    keyboardWrapper = KeyboardWrapper(delegate: self)

    hideBackButtonTitle()
    setupViews()
    
    let t = RepeatingTimer(timeInterval: 3)
    t.eventHandler = {
      NetworkManager.shared.getUserEmailValidationStatus {
        [weak self] (status, error) in
        guard let this = self else {return}
        
        if let _ = error {
          os_log("Error in the user email validation.", log: OSLog.signUp, type: .info)
        }
        else {
          if let status = status {
            if status {
              t.suspend()
              os_log("Got email validation, finishing onboarding.", log: OSLog.signUp, type: .info)
              AnalyticsManager.shared.log(event: .validatedEmail)
              NetworkManager.shared.reloadCurrentUser() { _ in
                this.finish()
              }
            }
          }
        }
      }
    }
    t.resume()
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.emailVerificationScreen)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override func setupViews() {
    view.backgroundColor = Constants.backgroundColor
    
    view.addSubview(container)
    container.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.view)
      topConstraint = make.top.equalTo(self.view).offset(Layout.topMargin).constraint
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
    
    container.addSubview(didNotReceiveEmailButton)
    didNotReceiveEmailButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.detailLabel.snp.bottom).offset(Layout.detailBottomMargin)
      make.width.equalTo(Layout.didNotReceiveEmailButtonWidth)
      make.centerX.equalTo(self.container)
    }
    didNotReceiveEmailButton.addTarget(self, action: #selector(self.showResend), for: UIControl.Event.touchUpInside)

    emailFieldContainer.addSubview(emailField)
    emailField.snp.makeConstraints { (make) in
      make.top.equalTo(emailFieldContainer)
      make.left.equalTo(emailFieldContainer)
      make.right.equalTo(emailFieldContainer)
      make.height.equalTo(Layout.fieldHeight)
      make.bottom.equalTo(emailFieldContainer)
    }

    emailFieldCardView.addContentView(emailFieldContainer)
    
    container.addSubview(emailFieldCardView)
    emailFieldCardView.snp.makeConstraints { (make) in
      make.height.width.equalTo(0)
    }

    container.addSubview(resendButton)
    resendButton.snp.makeConstraints { (make) in
      make.height.width.equalTo(0)
    }
    resendButton.setTitle(Text.resendEmail.localized(), for: .normal)
    resendButton.addTarget(self, action: #selector(self.resend), for: UIControl.Event.touchUpInside)
    
    applyCommunityTheme()
  }
  
  @objc func showResend() {
    didNotReceiveEmailButton.snp.removeConstraints()
    didNotReceiveEmailButton.removeFromSuperview()
    
    emailFieldCardView.snp.remakeConstraints { (make) in
      make.top.equalTo(self.detailLabel.snp.bottom).offset(Layout.detailBottomMargin)
      make.centerX.equalTo(self.container)
      make.width.equalTo(self.container)
    }
    
    resendButton.snp.remakeConstraints { (make) in
      make.top.equalTo(self.emailFieldCardView.snp.bottom).offset(15)
      make.width.equalTo(Layout.resendButtonWidth)
      make.height.equalTo(Layout.resendButtonHeight)
      make.centerX.equalTo(self.container)
    }
    
    container.setNeedsUpdateConstraints()
  }
  
  func hideResend() {
    titleLabel.text = EmailValidationText.resentTitleText.localized()
    didNotReceiveEmailButton.setTitle(EmailValidationText.resentSubTitleText.localized(), for: .normal)
    
    container.addSubview(didNotReceiveEmailButton)
    didNotReceiveEmailButton.snp.remakeConstraints { (make) in
      make.top.equalTo(self.detailLabel.snp.bottom).offset(Layout.detailBottomMargin)
      make.width.equalTo(Layout.didNotReceiveEmailButtonWidth)
      make.centerX.equalTo(self.container)
    }
    
    emailFieldCardView.snp.remakeConstraints { (make) in
      make.height.width.equalTo(0)
    }
    
    resendButton.snp.remakeConstraints { (make) in
      make.height.width.equalTo(0)
    }
    
    container.setNeedsUpdateConstraints()
  }
  
  @objc func resend() {
    guard let user = UserManager.shared.user else {
      os_log("For some reason, can't get current user to resend email", log: OSLog.signUp, type: .info)
      return
    }
    
    resendButton.state = .loading
    
    let existingEmail = user.email
    let newEmail = emailField.text ?? existingEmail
    NetworkManager.shared.resendValidationEmail(newEmail, completion: {
      [weak self] (error) in
      guard let this = self else {return}
      
      if let error = error {
        os_log("Error resending validation email: %{public}@", log: OSLog.settings, error.localizedDescription)
      } else {
        AnalyticsManager.shared.log(event: .emailResent)
        
        if existingEmail != newEmail {
          let modifiedUser = user.copy() as! User
          modifiedUser.email = newEmail
          UserManager.shared.setUser(modifiedUser)
        }
        this.resendButton.state = .normal
        this.resendButton.setTitle(Text.send.localized(), for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          this.hideResend()
            this.resendButton.setTitle(Text.resendEmail.localized(), for: .normal)
        }
      }
    })
  }
  
  func finish() {
    Router.shared.route(
      to: Route.mainNav,
      from: self,
      presentationType: PresentationType.root(embedInNav: false)
    )
  }
  
  func keyboardWrapper(_ wrapper: KeyboardWrapper, didChangeKeyboardInfo info: KeyboardInfo) {
    if info.state == .willHide || info.state == .hidden {
      topConstraint.update(offset: 200)
    }
    else {
      topConstraint.update(offset: 60)
    }
    
    UIView.animate(withDuration: info.animationDuration, delay: 0, options: info.animationOptions, animations: {
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    }, completion: { _ in })
  }
}

extension EmailValidationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension EmailValidationViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    didNotReceiveEmailButton.backgroundColor = colors.background
    let didNotReceiveEmailButtonAttributedText = Text.didNotReceiveEmailButtonText.localized().withAttributes([
      Attribute.font(Layout.linkFont),
      Attribute.textColor(colors.primary),
    ])
    didNotReceiveEmailButton.setAttributedTitle(didNotReceiveEmailButtonAttributedText, for: .normal)
    
    resendButton.setDarkeningBackgroundColor(color: colors.primary)
    resendButton.buttonTitleColor = colors.background
    resendButton.spinnerColor = colors.text
  }
}
