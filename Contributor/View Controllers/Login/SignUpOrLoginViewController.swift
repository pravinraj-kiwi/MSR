//
//  SignUpOrLoginViewController.swift
//  Contributor
//
//  Created by johnm on 26/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import UserNotifications
import SwiftyUserDefaults
import SwiftyAttributes

class SignUpOrLoginViewController: UIViewController {
  struct Layout {
    static let instructionLabelBottomMargin: CGFloat = 50
    static let signUpButtonWidth: CGFloat = 240
    static let signUpButtonHeight: CGFloat = 44
    static let signUpButtonBottomMargin: CGFloat = 20
    static let orLabelBottomMargin: CGFloat = 10
    static let defaultLogoWidth: CGFloat = 150
    static let communityLogoWidth: CGFloat = 260
    static let contentFont: UIFont = Font.regular.of(size: 18)
  }
  
  let container: UIView = {
    let view = UIView()
    return view
  }()
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    return iv
  }()
  
  let instructionLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.textAlignment = .center
    label.numberOfLines = 0
    label.text = Text.accountLabelText.localized()
    return label
  }()

  let signUpButton: UIButton = {
    let button = UIButton(frame: CGRect.zero)
    button.titleLabel?.font = Layout.contentFont
    button.layer.cornerRadius = Constants.buttonCornerRadius
    button.layer.masksToBounds = true
    button.setTitle(Text.signUpButtonText.localized(), for: .normal)
    return button
  }()

  let orLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.textAlignment = .center
    label.numberOfLines = 0
    label.text = Text.orLabelText.localized()
    return label
  }()

  let signInButton: UIButton = {
    let button = UIButton(type: .custom)
    return button
  }()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
    hideBackButtonTitle()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    AnalyticsManager.shared.logOnce(event: .createOrLogin)
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.landingScreen)
  }
  
  override func setupViews() {
    view.addSubview(container)
    container.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
      make.left.equalTo(view).offset(30)
      make.right.equalTo(view).offset(-30)
    }

    container.addSubview(imageView)
    
    container.addSubview(instructionLabel)
    instructionLabel.snp.makeConstraints { (make) in
      make.top.equalTo(imageView.snp.bottom).offset(50)
      make.centerX.equalTo(container)
      make.width.equalTo(280)
    }
    
    container.addSubview(signUpButton)
    signUpButton.snp.makeConstraints { (make) in
      make.width.equalTo(Layout.signUpButtonWidth)
      make.height.equalTo(Layout.signUpButtonHeight)
      make.centerX.equalTo(container)
      make.top.equalTo(instructionLabel.snp.bottom).offset(Layout.instructionLabelBottomMargin)
    }
    signUpButton.addTarget(self, action: #selector(self.goToSignUp), for: .touchUpInside)

    container.addSubview(orLabel)
    orLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(container)
      make.top.equalTo(signUpButton.snp.bottom).offset(Layout.signUpButtonBottomMargin)
    }

    container.addSubview(signInButton)
    signInButton.snp.makeConstraints { (make) in
      make.centerX.equalTo(container)
      make.top.equalTo(orLabel.snp.bottom).offset(Layout.orLabelBottomMargin)
      make.bottom.equalTo(container)
    }
    signInButton.addTarget(self, action: #selector(self.goToLogin), for: .touchUpInside)
    
    applyCommunityTheme()
  }
  
  @objc func goToSignUp() {
    Router.shared.route(
      to: Route.signup,
      from: self,
      presentationType: PresentationType.push())
  }

  @objc func goToLogin() {
    Router.shared.route(
      to: Route.login,
      from: self,
      presentationType: PresentationType.push())
  }
}

extension SignUpOrLoginViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors, let images = community.images else {
      return
    }
    
    view.backgroundColor = colors.background
    container.backgroundColor = colors.background
    instructionLabel.backgroundColor = colors.background
    instructionLabel.textColor = colors.text
    orLabel.backgroundColor = colors.background
    orLabel.textColor = colors.text
    signUpButton.setDarkeningBackgroundColor(color: colors.primary)
    signUpButton.setTitleColor(colors.whiteText, for: .normal)
    signUpButton.titleLabel?.textColor = colors.whiteText
    signInButton.backgroundColor = colors.background
    
    let signInButtonAttributedText = Text.signInButtonText.localized().withAttributes([
      Attribute.font(Layout.contentFont),
      Attribute.textColor(colors.primary),
      Attribute.underlineStyle(NSUnderlineStyle.single),
      Attribute.underlineColor(colors.primary)
    ])
    signInButton.setAttributedTitle(signInButtonAttributedText, for: .normal)
    
    if images.logo.starts(with: "http") {
      // special handling to wait for the image to load so we know the size
      imageView.kf.setImage(with: URL(string: images.logo)) {
        result in
        
        switch result {
        case .success(let value):
          self.imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.container).offset(20)
            make.centerX.equalTo(self.container)
            make.width.equalTo(Layout.communityLogoWidth)
            make.height.equalTo(Layout.communityLogoWidth / value.image.size.width * value.image.size.height)
          }
        default:
          break
        }
      }
    } else {
      imageView.image = UIImage(named: images.logo)!
      imageView.setImageColor(color: .black)
      imageView.snp.makeConstraints { (make) in
        make.top.equalTo(self.container).offset(20)
        make.centerX.equalTo(container)
        make.width.equalTo(UserManager.shared.isDefaultCommunity ? Layout.defaultLogoWidth : Layout.communityLogoWidth)
      }
    }
    
    self.view.setNeedsUpdateConstraints()  }
}
