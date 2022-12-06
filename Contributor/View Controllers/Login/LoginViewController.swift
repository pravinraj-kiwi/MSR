//
//  LoginViewController.swift
//  Contributor
//
//  Created by arvindh on 21/06/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import SnapKit
import Moya
import SwiftyAttributes
import SwiftyUserDefaults
import Kingfisher

class LoginViewController: UIViewController, KeyboardWrapperDelegate {
  struct Layout {
    static var fieldHeight: CGFloat = 58
    static var fieldSectionVerticalMargin: CGFloat = 30
    static var fieldSectionSideMargin: CGFloat = 16
    static let defaultLogoWidth: CGFloat = 150
    static let communityLogoWidth: CGFloat = 260
    static let contentFont: UIFont = Font.regular.of(size: 18)
  }
 
  struct FormValues {
    var email: String?
    var password: String?
  }
  
  var values: FormValues = FormValues()
  var keyboardWrapper: KeyboardWrapper!
  var topConstraint: Constraint!
  var imageMarginConstraint: Constraint!
  
  let container: UIView = {
    let view = UIView()
    view.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
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
    label.text = Text.instructionLabelText.localized()
    return label
  }()
  
  let emailField: MSRTextField = {
    let emailField = MSRTextField()
    emailField.textField.autocapitalizationType = .none
    emailField.textField.autocorrectionType = .no
    emailField.textField.keyboardType = .emailAddress
    emailField.textField.textContentType = UITextContentType.emailAddress
    emailField.textField.returnKeyType = .next
    emailField.trimTrailingSpace = true
    return emailField
  }()

  let passwordField: MSRTextField = {
    let passwordField = MSRTextField()
    passwordField.textField.isSecureTextEntry = true
    passwordField.textField.autocapitalizationType = .none
    passwordField.textField.textContentType = UITextContentType.password
    passwordField.textField.returnKeyType = .go
    return passwordField
  }()
  
  let actionButton: ActivityIndicatorButton = {
    let button = ActivityIndicatorButton(frame: CGRect.zero)
    return button
  }()
  
  let forgotPasswordButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.textAlignment = .center
    return button
  }()

  let signUpButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.textAlignment = .center
    return button
  }()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    keyboardWrapper = KeyboardWrapper(delegate: self)
    
    registerForNewCommunityThemeNotification()
    
    setupViews()
    setupTextChangeListeners()
    enableOrDisableActionButton()
    hideBackButtonTitle()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.signInScreen)
  }
  
  override func setupViews() {
    view.addSubview(container)
    container.snp.makeConstraints { (make) in
      self.topConstraint = make.top.equalTo(view.safeAreaLayoutGuide).offset(60).constraint
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
    }
    
    container.addSubview(imageView)

    container.addSubview(instructionLabel)
    instructionLabel.snp.makeConstraints { (make) in
      self.imageMarginConstraint = make.top.equalTo(imageView.snp.bottom).offset(50).constraint
      make.width.equalTo(container)
    }
    
    let emailFieldContainer = addSingleField(emailField, below: instructionLabel)
    let passwordFieldContainer = addSingleField(passwordField, below: emailFieldContainer)
    
    container.addSubview(actionButton)
    actionButton.snp.makeConstraints { (make) in
      make.centerX.equalTo(view)
      make.width.equalTo(150)
      make.height.equalTo(44)
      make.top.equalTo(passwordFieldContainer.snp.bottom).offset(50)
    }
    actionButton.setTitle(Text.signIn.localized(), for: .normal)
    actionButton.addTarget(self, action: #selector(self.loginOrSignup(_:)), for: .touchUpInside)

    view.addSubview(forgotPasswordButton)
    forgotPasswordButton.snp.makeConstraints { (make) in
      make.top.equalTo(actionButton.snp.bottom).offset(30)
      make.left.equalTo(view)
      make.right.equalTo(view)
    }
    forgotPasswordButton.addTarget(self, action: #selector(self.forgotPasswordButtonTapped), for: .touchUpInside)

    view.addSubview(signUpButton)
    signUpButton.snp.makeConstraints { (make) in
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(container)
    }
    signUpButton.addTarget(self, action: #selector(self.signUpButtonTapped), for: .touchUpInside)
    
    applyCommunityTheme()
  }
  
  func addSingleField(_ fieldView: UIView, below belowView: UIView? = nil) -> CardContainerView {
    let cardView = CardContainerView()
    cardView.cornerRadius = 2
    
    let container = UIView()
    container.backgroundColor = Constants.backgroundColor
    
    container.addSubview(fieldView)
    fieldView.snp.makeConstraints { (make) in
      make.top.equalTo(container)
      make.left.equalTo(container)
      make.right.equalTo(container)
      make.height.equalTo(Layout.fieldHeight)
      make.bottom.equalTo(container)
    }
    
    cardView.addContentView(container)
    view.addSubview(cardView)
    cardView.snp.makeConstraints { (make) in
      make.top.equalTo(belowView?.snp.bottom ?? view).offset(Layout.fieldSectionVerticalMargin)
      make.left.equalTo(view).offset(Layout.fieldSectionSideMargin)
      make.right.equalTo(view).offset(-Layout.fieldSectionSideMargin)
    }
    
    return cardView
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  func setupTextChangeListeners() {
    [emailField, passwordField].forEach { (tf) in
      
      tf.onTextChange = {
        [weak self] textField, text in
        
        guard let this = self else {return}
        
        var values = this.values
        
        switch textField {
        case this.emailField:
          values.email = text
        case this.passwordField:
          values.password = text
        default:
          break
        }
        
        this.values = values
        this.enableOrDisableActionButton()
      }
      
      tf.onErrorButtonTapped = {
        [weak self] textfield, error in
        
        guard let this = self else {
          return
        }
        
        let alerter = Alerter(viewController: this)
        alerter.alert(title: Text.error.localized(), message: error.localizedDescription,
                      confirmButtonTitle: nil, cancelButtonTitle: Text.ok.localized(),
                      onConfirm: nil, onCancel: nil)
      }
      
      tf.onShouldReturn = {
        [weak self] textField in
        
        guard let this = self else {
          return
        }
        
        switch textField {
        case this.emailField:
          textField.resignFirstResponder()
          this.passwordField.textField.becomeFirstResponder()
        case this.passwordField:
          textField.resignFirstResponder()
          this.login()
        default:
          break
        }
      }
    }
  }
  
  func enableOrDisableActionButton() {
    guard
      let email = values.email,
      let password = values.password,
      !email.isEmpty,
      !password.isEmpty
      else {
        actionButton.isEnabled = false
        return
    }
    actionButton.isEnabled = true
  }
  
  @objc func signUpButtonTapped() {
    Router.shared.route(to: .signup, from: self)
  }
  
  @objc func forgotPasswordButtonTapped() {
    Router.shared.route(
      to: Route.passwordReset,
      from: self,
      presentationType: PresentationType.push()
    )
  }
  
  @objc func loginOrSignup(_ sender: UIButton) {
    login()
  }
  
  func login() {
    guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty else {
      return
    }
    
    // Hide the keyboard
    view.endEditing(true)
    
    actionButton.state = .loading
    
    let params = AuthParams(email: email, password: password)
    
    NetworkManager.shared.loginUser(params) {
      [weak self] (error) in
      guard let this = self else { return }
      
      this.actionButton.state = .normal
      
      if let _ = error {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: this)
            return
        }
        do {
             let errorResponse = error as? Moya.MoyaError
             if let errorMessgae = try errorResponse?.response?.mapString(atKeyPath: "detail") {
                let toaster = Toaster(view: this.view)
                toaster.toast(message: errorMessgae, title: Text.signInFailed.localized())
             }
        } catch {
             print(error)
        }
         
      } else {
        
        // if there is a deep link slug, join the community
        if let newCommunitySlug = UserManager.shared.deepLinkCommunitySlug {
          
          let params = JoinCommunityParams(
            communitySlug: newCommunitySlug,
            communityUserID: UserManager.shared.deepLinkCommunityUserID,
            joinURLString: UserManager.shared.deepLinkURLString
          )
          
          NetworkManager.shared.joinCommunity(params) {
            [weak self] error in
            
            if let error = error {
              os_log("Error joining community during login: %{public}@", log: OSLog.community, type: .error, error.localizedDescription)
            } else {
              os_log("Joined community during login: %{public}@", log: OSLog.community, type: .info, newCommunitySlug)
            }
            
            UserManager.shared.deepLinkCommunitySlug = nil
            UserManager.shared.deepLinkCommunityUserID = nil
            UserManager.shared.deepLinkURLString = nil
          }
        }
        
        NotificationCenter.default.post(name: .didLogin, object: nil)
        AnalyticsManager.shared.log(event: .login)
        Defaults[DefaultsKeys.onboardingDone] = true
        
        // NOTE: this code is duplicated from App Delegate ... it needs to be factored
        
        guard let user = UserManager.shared.user else {
          os_log("We're logged in but somehow don't have a user record??", log: OSLog.signIn, type: .error)
          return
        }
        
        if !user.hasDecidedNotifications {
          Router.shared.route(
            to: Route.notificationPermission,
            from: self!,
            presentationType: PresentationType.root(embedInNav: false)
          )
        }
        else if !user.hasValidatedEmail {
          Router.shared.route(
            to: Route.emailValidation,
            from: self!,
            presentationType: PresentationType.root(embedInNav: false)
          )
        }
        else {
          Router.shared.route(
            to: Route.mainNav,
            from: self!,
            presentationType: PresentationType.root(embedInNav: false)
          )
        }
      }
    }
  }
  
  func keyboardWrapper(_ wrapper: KeyboardWrapper, didChangeKeyboardInfo info: KeyboardInfo) {
    if info.state == .willHide || info.state == .hidden {
      topConstraint.update(offset: 60)
      imageMarginConstraint.update(offset: 50)
    }
    else {
      topConstraint.update(offset: -100)
      imageMarginConstraint.update(offset: 100)
    }
    
    UIView.animate(withDuration: info.animationDuration, delay: 0, options: info.animationOptions, animations: {
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    }, completion: { _ in })
  }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension LoginViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors, let images = community.images else {
      return
    }
    
    view.backgroundColor = colors.background
    container.backgroundColor = colors.background
    instructionLabel.backgroundColor = colors.background
    instructionLabel.textColor = colors.text
    
    emailField.textField.attributedPlaceholder = PlaceholderText.email.withTextColor(colors.placeholderText)
    passwordField.textField.attributedPlaceholder = PlaceholderText.password.withTextColor(colors.placeholderText)

    actionButton.setDarkeningBackgroundColor(color: colors.primary)
    actionButton.buttonTitleColor = colors.whiteText
    actionButton.spinnerColor = colors.text
    
    let forgotPasswordButtonAttributedText = Text.forgotPasswordButtonText.localized().withAttributes([
      Attribute.font(Layout.contentFont),
      Attribute.textColor(colors.primary),
      Attribute.underlineStyle(NSUnderlineStyle.single),
      Attribute.underlineColor(colors.primary)
    ])
    forgotPasswordButton.setAttributedTitle(forgotPasswordButtonAttributedText, for: .normal)

    let signUpButtonAttributedStaticText = Text.signUpButtonStaticText.localized().withAttributes([
      Attribute.font(Layout.contentFont),
      Attribute.textColor(colors.text)
    ])
    
    let signUpButtonAttributedLinkText = Text.signUpButtonLinkText.withAttributes([
      Attribute.font(Layout.contentFont),
      Attribute.textColor(colors.primary),
      Attribute.underlineStyle(NSUnderlineStyle.single),
      Attribute.underlineColor(colors.primary)
    ])
    signUpButton.setAttributedTitle(signUpButtonAttributedStaticText + signUpButtonAttributedLinkText, for: .normal)

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

    self.view.setNeedsUpdateConstraints()
  }
}
