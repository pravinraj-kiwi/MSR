//
//  JoinCommunityViewController.swift
//  Contributor
//
//  Created by John Martin on 7/1/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import UserNotifications
import SnapKit

protocol customPopDelegate: class {
    func dismissSettingScreen()
}

extension customPopDelegate {
    func dismissSettingScreen() {}
}

class JoinCommunityViewController: UIViewController {
  struct Layout {
    static var contentInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
    static let containerInset: CGFloat = 30
    static let containerHeight: CGFloat = 390
    static let communityLogoWidth: CGFloat = 200
    static let actionButtonBottomMargin: CGFloat = 15
    static let actionButtonWidth: CGFloat = 150
    static let actionButtonHeight: CGFloat = 44
    static let lineSpacing: CGFloat = 1.2
    static let formStackSpacing: CGFloat = 30
    static let resultStackSpacing: CGFloat = 10
    static var contentFont = Font.regular.of(size: 16)
    static var headerFont = Font.bold.of(size: 16)
  }
  
  var communitySlug: String!
  var communityUserID: String?
  var joinURLString: String?
  var community: Community?
  var popupType: PopUpType = .communityType
  weak var popupDelegate: customPopDelegate?
  var ctrl: JoinCommunityViewController?
    
  let container: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    view.layer.cornerRadius = 10
    return view
  }()
  
  let formContainer = UIView()
  let resultContainer = UIView()
  
  let formStackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.distribution = .fill
    stack.spacing = Layout.formStackSpacing
    return stack
  }()
  
  let logoImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.backgroundColor = Constants.backgroundColor
    return iv
  }()
  
  let headerLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.headerFont
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.textColor = Color.text.value
    label.textAlignment = .left
    return label
  }()

  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.textColor = Color.text.value
    label.textAlignment = .left
    return label
  }()
    
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.textColor = Color.text.value
    label.textAlignment = .left
    return label
  }()
  
  let bulletLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.contentFont
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.textColor = Color.text.value
    label.textAlignment = .left
    return label
  }()
  
  let actionButton: UIButton = {
    let button = UIButton(type: .custom)
    button.layer.cornerRadius = Constants.buttonCornerRadius
    button.backgroundColor = Constants.backgroundColor
    return button
  }()

  let cancelButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.font = Layout.contentFont
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
    label.text = JoinCommunity.title.localized()
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

init(communitySlug: String, communityUserID: String? = nil, joinURLString: String? = nil, popupType: PopUpType) {
    self.communitySlug = communitySlug
    self.communityUserID = communityUserID
    self.joinURLString = joinURLString
    self.popupType = popupType
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    if popupType == .communityType {
        updateUI()
        setupViews()
        updatePopWithCommunity()
    } else if popupType == .deleteAccount {
        updateUIWithText()
        setUpCustomPopUpView()
    }
  }
    
  func updateUI() {
    actionButton.setTitle(JoinCommunity.joinCommunityConfirmTitle.localized(), for: .normal)
     cancelButton.setTitle(JoinCommunity.joinCommunityCancelTitle.localized(), for: .normal)
     actionButton.titleLabel?.font = Layout.contentFont
     cancelButton.layer.cornerRadius = Constants.buttonCornerRadius
  }
    
  func updatePopWithCommunity() {
    if let existingCommunity = UserManager.shared.user?.getCommunityForSlug(slug: communitySlug) {
      community = existingCommunity
      showAlreadyJoined()
      dismissSelfAfterDelay()
    } else {
      NetworkManager.shared.getCommunity(communitySlug: communitySlug) {
        [weak self] (community, error) in
        if let error = error {
          // need to do something here
          os_log("Error getting community for join: %{public}@", log: OSLog.community, type: .error, error.localizedDescription)
        } else {
            if #available(iOS 13.0, *) {
               self?.community = community
               self?.showCommunityBits()
           } else {
              self?.ctrl?.community = community
              self?.ctrl?.showCommunityBits()
           }
        }
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func setupViews() {
    view.addSubview(container)
    container.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.centerY.equalTo(view)
      make.width.equalToSuperview().inset(Layout.containerInset)
      make.height.equalTo(Layout.containerHeight)
    }
    
    container.addSubview(formContainer)
    formContainer.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    // stack view up top
    
    formContainer.addSubview(formStackView)
    formStackView.snp.makeConstraints { make in
      make.top.left.right.equalToSuperview().inset(Layout.contentInset)
    }
    
    formStackView.addArrangedSubview(logoImageView)
    formStackView.addArrangedSubview(detailLabel)
    
    // buttons stuck to bottom
    
    formContainer.addSubview(cancelButton)
    cancelButton.snp.makeConstraints { make in
      make.bottom.width.equalToSuperview().inset(Layout.contentInset)
      make.height.equalTo(Layout.actionButtonHeight)
      make.centerX.equalTo(formContainer)
    }
    cancelButton.addTarget(self, action: #selector(dissmissJoinView), for: .touchUpInside)

    formContainer.addSubview(actionButton)
    actionButton.snp.makeConstraints { make in
      make.width.equalToSuperview().inset(Layout.contentInset)
      make.bottom.equalTo(cancelButton.snp.top).offset(-Layout.actionButtonBottomMargin)
      make.height.equalTo(Layout.actionButtonHeight)
      make.centerX.equalTo(formContainer)
    }
    actionButton.addTarget(self, action: #selector(join), for: .touchUpInside)

    // result UI
    
    resultContainer.addSubview(resultStackView)
    resultStackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.lessThanOrEqualToSuperview()
    }
    
    resultStackView.addArrangedSubview(loadingActivityIndicator)
    resultStackView.addArrangedSubview(resultImageView)
    resultStackView.addArrangedSubview(resultLabel)
    
    loadingActivityIndicator.isHidden = true
    resultImageView.isHidden = true
    resultLabel.isHidden = true
    
    applyCommunityTheme()
  }
  
  func switchToResultContainer() {
    formContainer.removeFromSuperview()
    
    container.addSubview(resultContainer)
    resultContainer.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(Layout.contentInset)
    }
  }
  
  func showCommunityBits() {
    guard let community = community, let images = community.images else {
      return
    }

    logoImageView.setImageWithAssetOrURL(with: images.logo)
    
    if images.logo.starts(with: "http") {
      // special handling to wait for the image to load so we know the size
      logoImageView.kf.setImage(with: URL(string: images.logo)) {
        result in
        
        switch result {
        case .success(let value):
          self.logoImageView.snp.makeConstraints { make in
            make.width.equalTo(Layout.communityLogoWidth)
            make.height.equalTo(Layout.communityLogoWidth / value.image.size.width * value.image.size.height)
          }
        default:
          os_log("Error when loading the community logo in the join modal. Not sure how to proceed.", log: OSLog.community, type: .error)
        }
      }
    }
    
    let name = community.name ?? "This community"
    detailLabel.attributedText = "\(name) has partnered with Measure to bring you data jobs on your mobile device.".lineSpacedAndCentered(Layout.lineSpacing)
  }
  
  func showLoading() {
    switchToResultContainer()

    loadingActivityIndicator.startAnimating()
    loadingActivityIndicator.isHidden = false

    resultImageView.isHidden = true

    resultLabel.attributedText = JoinCommunity.title.localized().lineSpacedAndCentered(Layout.lineSpacing)
    resultLabel.isHidden = false

    view.setNeedsUpdateConstraints()
  }
  
  func showSuccess() {
    loadingActivityIndicator.isHidden = true
    loadingActivityIndicator.stopAnimating()

    resultImageView.image = Image.validationSuccess.value
    resultImageView.isHidden = false
    
    let communityName = community?.name ?? "new"
    let prefix = "\(JoinCommunity.joinedSuccessfully.localized()) \(communityName)"
    let sufix = "\(JoinCommunity.community.localized())"
    resultLabel.attributedText = (prefix + sufix).lineSpacedAndCentered(Layout.lineSpacing)
    
    view.setNeedsUpdateConstraints()
  }

  func showError() {
    loadingActivityIndicator.isHidden = true
    loadingActivityIndicator.stopAnimating()
    
    resultImageView.image = Image.validationFailure.value
    resultImageView.isHidden = false

    resultLabel.attributedText = JoinCommunity.error.localized().lineSpacedAndCentered(Layout.lineSpacing)
    
    view.setNeedsUpdateConstraints()
  }

  func showAlreadyJoined() {
    switchToResultContainer()
    
    resultImageView.image = Image.validationSuccess.value
    resultImageView.isHidden = false
    
    let communityName = community?.name ?? "new"
    resultLabel.attributedText = "\(JoinCommunity.alreadyMember.localized()) \(communityName) \(JoinCommunity.community.localized())".lineSpacedAndCentered(Layout.lineSpacing)
    resultLabel.isHidden = false
    
    view.setNeedsUpdateConstraints()
  }
  
  func dismissSelfAfterDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    if #available(iOS 13.0, *) {
        self.dismissSelf()
    } else {
        self.view.removeFromSuperview()
      }
    }
  }
    
  @objc func dissmissJoinView() {
    if #available(iOS 13.0, *) {
        self.dismissSelf()
    } else {
       self.view.removeFromSuperview()
    }
  }
  
  @objc func join() {
    showLoading()
    
    let params = JoinCommunityParams(
      communitySlug: communitySlug,
      communityUserID: communityUserID,
      joinURLString: joinURLString
    )
    
    NetworkManager.shared.joinCommunity(params) {
      [weak self] error in
      guard let this = self else {
        return
      }

      if let error = error {
        os_log("Error joining community: %{public}@", log: OSLog.community, type: .error, error.localizedDescription)

        this.showError()
        this.dismissSelfAfterDelay()
      } else {
        os_log("Joined community: %{public}@", log: OSLog.community, type: .info, this.communitySlug)
        
        this.showSuccess()
        this.dismissSelfAfterDelay()
      }
    }
  }
}

extension JoinCommunityViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    actionButton.setTitleColor(colors.whiteText, for: .normal)
    actionButton.setDarkeningBackgroundColor(color: colors.primary)
    cancelButton.setTitleColor(colors.text, for: .normal)
    cancelButton.setDarkeningBackgroundColor(color: colors.veryLightBorder)
  }
}
