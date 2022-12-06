//
//  OnboardingItemCollectionViewCell.swift
//  Contributor
//
//  Created by John Martin on 5/14/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import CoreMotion
import Kingfisher
import SwiftyAttributes

protocol OnboardingItemCollectionViewCellDelegate: class {
  func didTapStartBasicProfileSurveyButton()
  func didTapStartPhoneNumberSurveyButton()
  func didTapStartLocationValidationButton()
  func didTapContactSupportButton()
}

class OnboardingItemCollectionViewCell: CardCollectionViewCell {
  struct Layout {
    static var cardContentInset = UIEdgeInsets(top: 15, left: 20, bottom: 5, right: 20)
    static var cardHeaderBottomMargin: CGFloat = 20
    static var cardHeaderHeight: CGFloat = 26
    static var jobTypeFont = Font.regular.of(size: 16)
    static var msrFont = Font.bold.of(size: 16)
    static var titleFont = Font.bold.of(size: 22)
    static var detailFont = Font.regular.of(size: 16)
    static var validationTextFont = Font.regular.of(size: 16)
    static var validationButtonFont = Font.semiBold.of(size: 14)
    static var lineSpacing = Constants.defaultLineSpacing
    static var defaultStackSpacing: CGFloat = 10
    static var msrPillViewHeight: CGFloat = 26
    static var msrPillInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    static var detailLabelBottomMargin: CGFloat = 25
    static var timeLabelBottomMargin: CGFloat = 5
    static var borderHeight: CGFloat = 1
    static var validationRowHeight: CGFloat = 34
    static var validationImageWidth: CGFloat = 24
    static var imageWidthRatio: CGFloat = 3
    static var imageHeightRatio: CGFloat = 1
    static var validationButtonHeight: CGFloat = 30
    static var validationButtonWidth: CGFloat = 70
    static var validationButtonWidthForPT: CGFloat = 100

    static var validationButtonCornerRadius: CGFloat = validationButtonHeight / 2
    static var listNumberWidth: CGFloat = 20
    static var errorMessageMargin: CGFloat = 5
  }
  
  weak var onboardingItemDelegate: OnboardingItemCollectionViewCellDelegate?
  weak var resizingDelegate: ListItemNeedsResizingDelegate?

  let generator = UIImpactFeedbackGenerator(style: .light)
  
  var currentHasFilledBasicDemos = false
  var currentHasValidatedPhoneNumber = false
  var currentHasValidatedLocation = false
  var currentHasLocationValidationError = false
  var currentHasPhoneValidationError = false
  var showBasicSurveyValidationCheckAnimation = false
  var showPhoneValidationCheckAnimation = false
  var showLocationValidationCheckAnimation = false
  var hasProcessedOnboardingFinished = false
  
  let imageView: UIImageView = {
    let imgv = UIImageView()
    imgv.contentMode = .scaleAspectFill
    imgv.clipsToBounds = true
    return imgv
  }()
  
  let cardHeaderContainer = UIView()
  
  let jobTypeLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.jobTypeFont
    label.numberOfLines = 0
    return label
  }()
  
  let msrPillView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 3
    view.backgroundColor = Color.lightBackground.value
    return view
  }()
  
  let msrLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.msrFont
    label.numberOfLines = 1
    label.textColor = Color.text.value
    return label
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.titleFont
    label.numberOfLines = 0
    return label
  }()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.detailFont
    label.numberOfLines = 0
    return label
  }()
  
  // email validation survey controls
  
  let emailValidationContainer = UIView()

    let emailValidationLabel: UILabel = {
        let label = UILabel()
        label.font = Layout.validationTextFont
        label.numberOfLines = 0
        return label
    }()
    
    let emailValidationImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    //Phone Validation survey controls
    
    let phoneValidationContainer = UIView()

    let phoneValidationLabel: UILabel = {
        let label = UILabel()
        label.font = Layout.validationTextFont
        label.numberOfLines = 0
        return label
    }()
    
    let phoneValidationImageView: UIImageView = {
        let phoneValidation = UIImageView()
        phoneValidation.contentMode = .scaleAspectFit
        phoneValidation.clipsToBounds = true
        return phoneValidation
    }()
    
    let startBasicPhoneNumberSurveyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Color.lightBackground.value
        button.setTitle(Text.startButtonTitleText.localized(), for: .normal)
        button.titleLabel?.font = Layout.validationButtonFont
        button.layer.cornerRadius = Layout.validationButtonCornerRadius
        button.setBackgroundColor(color: Color.border.value, forState: .highlighted)
        return button
    }()
    
  // basic profile survey controls

  let basicProfileSurveyValidationContainer = UIView()

  let basicProfileSurveyValidationLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.validationTextFont
    label.numberOfLines = 0
    return label
  }()

  let basicProfileSurveyValidationImageView: UIImageView = {
    let basicValidation = UIImageView()
    basicValidation.contentMode = .scaleAspectFit
    basicValidation.clipsToBounds = true
    return basicValidation
  }()
      
  let startBasicProfileSurveyButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = Color.lightBackground.value
    button.setTitle(Text.startButtonTitleText.localized(), for: .normal)
    button.titleLabel?.font = Layout.validationButtonFont
    button.layer.cornerRadius = Layout.validationButtonCornerRadius
    button.setBackgroundColor(color: Color.border.value, forState: .highlighted)
    return button
  }()
    
  //Phone Number Error Handling
    
  let phoneNumberValidationErrorContainer = UIView()

  let phoneNumberValidationErrorLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = Layout.lineSpacing
   
    let messageText = Text.phoneNumberValidationErrorText.localized().withAttributes([
      Attribute.font(Layout.validationTextFont),
      Attribute.textColor(Color.error.value),
      Attribute.paragraphStyle(paragraphStyle)
    ])
   
    label.attributedText = messageText
    return label
  }()

  let phoneNumberValidationSupportButton: UIButton = {
    let button = UIButton(type: .custom)
    let linkText = Text.phoneNumberValidationSupportButtonText.localized().withAttributes([
      Attribute.font(Layout.validationTextFont),
      Attribute.textColor(Color.error.value),
      Attribute.underlineStyle(.single),
      Attribute.underlineColor(Color.error.value)
    ])
    button.setAttributedTitle(linkText, for: .normal)
    return button
  }()

  // location validation controls
  
  let locationValidationContainer = UIView()
  
  let locationValidationLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.validationTextFont
    label.numberOfLines = 0
    return label
  }()
  
  let locationValidationImageView: UIImageView = {
    let location = UIImageView()
    location.contentMode = .scaleAspectFit
    location.clipsToBounds = true
    return location
  }()

  let startLocationValidationButton: UIButton = {
    let button = UIButton(type: UIButton.ButtonType.custom)
    button.backgroundColor = Color.lightBackground.value
    button.setTitle(Text.startButtonTitleText.localized(), for: .normal)
    button.titleLabel?.font = Layout.validationButtonFont
    button.layer.cornerRadius = Layout.validationButtonCornerRadius
    button.setBackgroundColor(color: Color.border.value, forState: .highlighted)
    return button
  }()
  
  let locationValidationActivityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: CGRect.zero)
    indicator.color = Color.text.value
    indicator.hidesWhenStopped = true
    return indicator
  }()

  let locationValidationErrorContainer = UIView()

  let locationValidationErrorLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = Layout.lineSpacing
    
    let messageText = Text.locationValidationErrorText.localized().withAttributes([
      Attribute.font(Layout.validationTextFont),
      Attribute.textColor(Color.error.value),
      Attribute.paragraphStyle(paragraphStyle)
    ])
    
    label.attributedText = messageText

    return label
  }()

  let locationValidationSupportButton: UIButton = {
    let button = UIButton(type: .custom)
    let linkText = Text.locationValidationSupportButtonText.localized().withAttributes([
      Attribute.font(Layout.validationTextFont),
      Attribute.textColor(Color.error.value),
      Attribute.underlineStyle(.single),
      Attribute.underlineColor(Color.error.value)
    ])
    button.setAttributedTitle(linkText, for: .normal)
    return button
  }()
  
  let border1: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
    return view
  }()
  
  let border2: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
    return view
  }()
    
  let border3: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
    return view
   }()
  
  let number1Label: UILabel = {
    let label = UILabel()
    label.font = Layout.validationTextFont
    label.numberOfLines = 0
    label.text = Text.firstTitleText.localized()
    return label
  }()
  
  let number2Label: UILabel = {
    let label = UILabel()
    label.font = Layout.validationTextFont
    label.numberOfLines = 0
    label.text = Text.secondTitleText.localized()
    return label
  }()
  
  let number3Label: UILabel = {
    let label = UILabel()
    label.font = Layout.validationTextFont
    label.numberOfLines = 0
    label.text = Text.thirdTitleText.localized()
    return label
  }()

  let number4Label: UILabel = {
    let label = UILabel()
    label.font = Layout.validationTextFont
    label.numberOfLines = 0
    label.text = Text.forthTitleText.localized()
    return label
  }()
  
  let stackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = Layout.defaultStackSpacing
    return stack
  }()
  
  static func calculateHeightForWidth(item: OnboardingItem, width: CGFloat) -> CGFloat {
    let cardWidth = width - CardLayout.cardInset.left - CardLayout.cardInset.right

    // the image is a static 2x1 resource
    let imageHeight = calculateImageHeight(width: cardWidth, widthRatio: 3, heightRatio: 1)
    
    let contentWidth = cardWidth - Layout.cardContentInset.left - Layout.cardContentInset.right

    let titleLabelHeight = TextSize.calculateHeight(Text.title.localized(),
                                                    font: Layout.titleFont,
                                                    width: contentWidth,
                                                    lineSpacing: Layout.lineSpacing)
    let titleLabelBottomMargin = Layout.defaultStackSpacing
    
    let detailLabelHeight = TextSize.calculateHeight(Text.detail.localized(),
                                                     font: Layout.detailFont,
                                                     width: contentWidth,
                                                     lineSpacing: Layout.lineSpacing)
    let detailLabelBottomMargin = Layout.detailLabelBottomMargin

    let validationRowsHeight = (Layout.validationRowHeight + Layout.defaultStackSpacing) * 4
    let validationBordersHeight = (Layout.borderHeight + Layout.defaultStackSpacing) * 4

    //Increasing the height of phone number validation error
    var phoneValidationErrorHeight: CGFloat = 0
    if let user = UserManager.shared.user, !user.hasFilledBasicDemos,
       !user.hasValidatedPhoneNumber,
       user.hasPhoneValidationError {
      let phoneValidationErrorContentWidth = contentWidth - Layout.listNumberWidth - Layout.validationImageWidth
      let phoneValidationErrorLabelHeight = TextSize.calculateHeight(Text.phoneNumberValidationErrorText.localized(),
                                                                     font: Layout.validationTextFont,
                                                                     width: phoneValidationErrorContentWidth,
                                                                     lineSpacing: Layout.lineSpacing)
      let phoneValidationErrorSupportButtonHeight = TextSize.calculateHeight(Text.phoneNumberValidationSupportButtonText.localized(),
                                                                             font: Layout.validationTextFont,
                                                                             width: phoneValidationErrorContentWidth,
                                                                             lineSpacing: Layout.lineSpacing)
      
      phoneValidationErrorHeight = phoneValidationErrorLabelHeight + phoneValidationErrorSupportButtonHeight + 20
    }
    
    // note: this is a little janky because the card can be updated after it's created
    var locationValidationErrorHeight: CGFloat = 0
    if let user = UserManager.shared.user, user.hasFilledBasicDemos,
       !user.hasValidatedLocation,
       user.hasLocationValidationError {
      let locationValidationErrorContentWidth = contentWidth - Layout.listNumberWidth - Layout.validationImageWidth
      let locationValidationErrorLabelHeight = TextSize.calculateHeight(Text.locationValidationErrorText,
                                                                        font: Layout.validationTextFont,
                                                                        width: locationValidationErrorContentWidth,
                                                                        lineSpacing: Layout.lineSpacing)
      let locationValidationErrorSupportButtonHeight = TextSize.calculateHeight(Text.locationValidationSupportButtonText.localized(),
                                                                                font: Layout.validationTextFont,
                                                                                width: locationValidationErrorContentWidth,
                                                                                lineSpacing: Layout.lineSpacing)
      
      locationValidationErrorHeight = locationValidationErrorLabelHeight + locationValidationErrorSupportButtonHeight + 20
    }
    
    var height: CGFloat = CardLayout.cardInset.top
      + imageHeight
      + Layout.cardContentInset.top
      + Layout.cardHeaderHeight
      + Layout.cardHeaderBottomMargin
    
    height += titleLabelHeight
      + titleLabelBottomMargin
      + detailLabelHeight
      + detailLabelBottomMargin

    height += validationRowsHeight
      + validationBordersHeight
      + phoneValidationErrorHeight
      + locationValidationErrorHeight
        
    height += Layout.cardContentInset.bottom
      + CardLayout.cardInset.bottom
    
    return height
  }
  
  var cardWidth: CGFloat {
    return contentView.frame.width - CardLayout.cardInset.left - CardLayout.cardInset.right
  }
  
  static func calculateImageHeight(width: CGFloat, widthRatio: CGFloat, heightRatio: CGFloat) -> CGFloat {
    return width * heightRatio / widthRatio
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    addListeners()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addListeners() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.onUserChanged),
                                           name: .userChanged, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.onFeedDidAppear),
                                           name: .feedDidAppear, object: nil)
  }
  
  func setupViews() {
    cardView.addSubview(imageView)
    let imageHeight = OnboardingItemCollectionViewCell.calculateImageHeight(width: cardWidth,
                                                                            widthRatio: 3, heightRatio: 1)
    imageView.snp.remakeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.width.equalTo(cardWidth)
      make.height.equalTo(imageHeight)
    }
    cardView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(Layout.cardContentInset.top)
      make.left.equalToSuperview().inset(Layout.cardContentInset)
      make.right.equalToSuperview().inset(Layout.cardContentInset)
    }
    
    stackView.addArrangedSubview(cardHeaderContainer)
    stackView.setCustomSpacing(Layout.cardHeaderBottomMargin, after: cardHeaderContainer)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(detailLabel)
    stackView.setCustomSpacing(Layout.detailLabelBottomMargin, after: detailLabel)
    stackView.addArrangedSubview(emailValidationContainer)
    stackView.addArrangedSubview(border1)
    stackView.addArrangedSubview(phoneValidationContainer)
    stackView.addArrangedSubview(border2)
    stackView.addArrangedSubview(basicProfileSurveyValidationContainer)
    stackView.addArrangedSubview(border3)
    stackView.addArrangedSubview(locationValidationContainer)
    stackView.addArrangedSubview(phoneNumberValidationErrorContainer)
    stackView.addArrangedSubview(locationValidationErrorContainer)
    stackView.setCustomSpacing(5, after: locationValidationContainer)

    border1.snp.makeConstraints { make in
      make.height.equalTo(Layout.borderHeight)
      make.width.equalToSuperview()
    }
    
    border2.snp.makeConstraints { make in
      make.height.equalTo(Layout.borderHeight)
      make.width.equalToSuperview()
    }
    
    border3.snp.makeConstraints { make in
      make.height.equalTo(Layout.borderHeight)
      make.width.equalToSuperview()
    }

    // email validation
    
    emailValidationContainer.snp.makeConstraints { make in
      make.height.equalTo(Layout.validationRowHeight)
      make.width.equalToSuperview()
    }

    emailValidationContainer.addSubview(number1Label)
    number1Label.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview()
      make.width.equalTo(Layout.listNumberWidth)
    }

    emailValidationContainer.addSubview(emailValidationLabel)
    emailValidationLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalTo(number1Label.snp.right)
    }

    emailValidationContainer.addSubview(emailValidationImageView)
    emailValidationImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview()
      make.width.height.equalTo(Layout.validationImageWidth)
    }
    
    //phone Validation
    
    phoneValidationContainer.snp.makeConstraints { make in
      make.height.equalTo(Layout.validationRowHeight)
      make.width.equalToSuperview()
    }

    phoneValidationContainer.addSubview(number2Label)
    number2Label.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview()
      make.width.equalTo(Layout.listNumberWidth)
    }

    phoneValidationContainer.addSubview(phoneValidationLabel)
    phoneValidationLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalTo(number2Label.snp.right)
    }

    phoneValidationContainer.addSubview(phoneValidationImageView)
    phoneValidationImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview()
      make.width.height.equalTo(Layout.validationImageWidth)
    }

    phoneValidationContainer.addSubview(startBasicPhoneNumberSurveyButton)
    startBasicPhoneNumberSurveyButton.addTarget(self, action: #selector(startPhoneNumberSurvey), for: .touchUpInside)
    
    phoneNumberValidationErrorContainer.snp.makeConstraints { make in
      make.width.equalToSuperview()
    }
    
    phoneNumberValidationErrorContainer.addSubview(phoneNumberValidationErrorLabel)
    phoneNumberValidationErrorLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview().offset(Layout.listNumberWidth)
      make.right.equalToSuperview().offset(-Layout.validationImageWidth)
    }
    
    phoneNumberValidationErrorContainer.addSubview(phoneNumberValidationSupportButton)
    phoneNumberValidationSupportButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.top.equalTo(phoneNumberValidationErrorLabel.snp.bottom).offset(5)
      make.left.equalTo(phoneNumberValidationErrorLabel)
    }
    phoneNumberValidationSupportButton.addTarget(self,
                                                 action: #selector(contactSupportButtonTapped),
                                                 for: .touchUpInside)

    // basic profile survey validation

    basicProfileSurveyValidationContainer.snp.makeConstraints { make in
      make.height.equalTo(Layout.validationRowHeight)
      make.width.equalToSuperview()
    }
    
    basicProfileSurveyValidationContainer.addSubview(number3Label)
    number3Label.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview()
      make.width.equalTo(Layout.listNumberWidth)
    }

    basicProfileSurveyValidationContainer.addSubview(basicProfileSurveyValidationLabel)
    basicProfileSurveyValidationLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalTo(number3Label.snp.right)
    }
    
    // constraints for these are set dynamically
    basicProfileSurveyValidationContainer.addSubview(basicProfileSurveyValidationImageView)
    basicProfileSurveyValidationContainer.addSubview(startBasicProfileSurveyButton)
    startBasicProfileSurveyButton.addTarget(self, action: #selector(startBasicProfileSurvey), for: .touchUpInside)

    // location validation
    
    locationValidationContainer.snp.makeConstraints { make in
      make.height.equalTo(Layout.validationRowHeight)
      make.width.equalToSuperview()
    }
    
    locationValidationContainer.addSubview(number4Label)
    number4Label.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview()
      make.width.equalTo(Layout.listNumberWidth)
    }
    
    locationValidationContainer.addSubview(locationValidationLabel)
    locationValidationLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalTo(number4Label.snp.right)
    }
    
    // constraints for these are set dynamically
    locationValidationContainer.addSubview(locationValidationImageView)
    locationValidationContainer.addSubview(startLocationValidationButton)
    startLocationValidationButton.addTarget(self, action: #selector(startLocationValidation), for: .touchUpInside)
    
    locationValidationContainer.addSubview(locationValidationActivityIndicator)
    locationValidationActivityIndicator.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview()
      make.width.height.equalTo(Layout.validationImageWidth)
    }
    
    locationValidationErrorContainer.snp.makeConstraints { make in
      make.width.equalToSuperview()
    }
    
    locationValidationErrorContainer.addSubview(locationValidationErrorLabel)
    locationValidationErrorLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview().offset(Layout.listNumberWidth)
      make.right.equalToSuperview().offset(-Layout.validationImageWidth)
    }
    
    locationValidationErrorContainer.addSubview(locationValidationSupportButton)
    locationValidationSupportButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.top.equalTo(locationValidationErrorLabel.snp.bottom).offset(5)
      make.left.equalTo(locationValidationErrorLabel)
    }
    locationValidationSupportButton.addTarget(self, action: #selector(contactSupportButtonTapped), for: .touchUpInside)
    
    // card header

    cardHeaderContainer.snp.makeConstraints { make in
      make.height.equalTo(Layout.cardHeaderHeight)
      make.width.equalToSuperview()
    }
    
    cardHeaderContainer.addSubview(jobTypeLabel)
    jobTypeLabel.snp.makeConstraints { make in
      make.centerY.equalTo(cardHeaderContainer)
      make.left.equalTo(cardHeaderContainer)
      make.height.equalTo(Layout.cardHeaderHeight)
    }

    if let validationRewardMSR = UserManager.shared.user?.validationRewardMSR, validationRewardMSR > 0 {
      msrLabel.text = validationRewardMSR.formattedMSRString
      
      msrPillView.addSubview(msrLabel)
      msrLabel.snp.makeConstraints { make in
        make.edges.equalToSuperview().inset(Layout.msrPillInset)
      }
      
      cardHeaderContainer.addSubview(msrPillView)
      msrPillView.snp.makeConstraints { make in
        make.centerY.equalTo(jobTypeLabel)
        make.height.equalTo(Layout.msrPillViewHeight)
        make.right.equalTo(cardHeaderContainer)
      }
    }
    
    let backgroundColor = Constants.backgroundColor
    let foregroundColor = Color.text.value
    let foregroundLightColor = Color.lightText.value
    
    jobTypeLabel.textColor = foregroundLightColor
    titleLabel.textColor = foregroundColor
    detailLabel.textColor = foregroundColor
    cardView.backgroundColor = backgroundColor
    
    jobTypeLabel.text = Text.jobType.localized()
    titleLabel.attributedText = Text.title.localized().lineSpaced(Layout.lineSpacing)
    detailLabel.attributedText = Text.detail.localized().lineSpaced(Layout.lineSpacing)
    
    emailValidationLabel.text = Text.emailValidationText.localized()
    phoneValidationLabel.text = Text.phoneNumberValidationText.localized()
    locationValidationLabel.text = Text.locationValidationText.localized()
    basicProfileSurveyValidationLabel.text = Text.basicProfileSurveyValidationText.localized()
    
    applyCommunityTheme()
  }
  
  func configure(with item: OnboardingItem) {
    updateProgress(initialDisplay: true)
  }
  
  func updateProgress(initialDisplay: Bool = false) {
    guard let user = UserManager.shared.user else {
      return
    }

    // initialize the cached current values
    if initialDisplay {
      currentHasFilledBasicDemos = user.hasFilledBasicDemos
      currentHasValidatedPhoneNumber = user.hasValidatedPhoneNumber
      currentHasValidatedLocation = user.hasValidatedLocation
      currentHasPhoneValidationError = user.hasPhoneValidationError
      currentHasLocationValidationError = user.hasLocationValidationError
    }
    
    let success = Image.validationSuccess.value
    let failure = Image.validationFailure.value
    let empty = Image.validationEmpty.value

    emailValidationImageView.image = user.hasValidatedEmail ? success : failure

    //PhoneNumber validation Logic
    phoneNumberValidationErrorContainer.isHidden = true
    if !showPhoneValidationCheckAnimation {
      phoneValidationContainer.alpha = 1.0
      if user.hasValidatedPhoneNumber && !currentHasValidatedPhoneNumber {
        // transition from grey circle to checked
        showPhoneNumberSurveyValidationImage()
        phoneValidationImageView.image = empty
        showPhoneValidationCheckAnimation = true
      } else {
        if user.hasValidatedPhoneNumber {
          showPhoneNumberSurveyValidationImage()
          phoneValidationImageView.image = success
        } else {
          if user.hasPhoneValidationError {
            showPhoneNumberSurveyValidationImage()
            phoneValidationImageView.image = failure
            phoneNumberValidationErrorContainer.isHidden = false
            self.updateConstraints()
          } else {
            showPhoneNumberSurveyStartButton()
            startBasicPhoneNumberSurveyButton.isEnabled = true
          }
        }
      }
    }
    
    // if the animation flag is set, then we're in a holding pattern until it's cleared
    if !showBasicSurveyValidationCheckAnimation {
        basicProfileSurveyValidationContainer.alpha = 1.0
      if user.hasFilledBasicDemos && !currentHasFilledBasicDemos {
        // transition from grey circle to checked
        showBasicProfileSurveyValidationImage()
        basicProfileSurveyValidationImageView.image = empty
        showBasicSurveyValidationCheckAnimation = true
      } else {
        if user.hasFilledBasicDemos && user.hasValidatedPhoneNumber {
          showBasicProfileSurveyValidationImage()
          basicProfileSurveyValidationImageView.image = success
        } else {
          if user.hasValidatedPhoneNumber && !user.hasPhoneValidationError {
            showBasicProfileSurveyStartButton()
            startBasicProfileSurveyButton.isEnabled = true
            basicProfileSurveyValidationContainer.alpha = 1.0
          } else {
            showBasicProfileSurveyStartButton()
            startBasicProfileSurveyButton.isEnabled = false
            basicProfileSurveyValidationContainer.alpha = 0.3
          }
        }
      }
    }

    // if the animation flag is set, then we're in a holding pattern until it's cleared
    locationValidationErrorContainer.isHidden = true
    if !showLocationValidationCheckAnimation {
        locationValidationContainer.alpha = 1.0
      if user.hasFilledBasicDemos && user.hasValidatedPhoneNumber {
        if user.hasValidatedLocation && !currentHasValidatedLocation {
          // transition from grey circle to checked
          showLocationValidationImage()
          locationValidationImageView.image = empty
          showLocationValidationCheckAnimation = true
        } else {
          if user.hasValidatedLocation {
            showLocationValidationImage()
            locationValidationImageView.image = success
          } else {
            if user.hasLocationValidationError {
              showLocationValidationImage()
              locationValidationImageView.image = failure
              locationValidationErrorContainer.isHidden = false
              resizingDelegate?.needsResizing()
            } else {
              showLocationValidationStartButton()
              startLocationValidationButton.isEnabled = true
            }
          }
        }
      } else {
        showLocationValidationStartButton()
        startLocationValidationButton.isEnabled = false
        locationValidationContainer.alpha = 0.3
      }
    }
    
    contentView.setNeedsUpdateConstraints()
    
    currentHasFilledBasicDemos = user.hasFilledBasicDemos
    currentHasValidatedPhoneNumber = user.hasValidatedPhoneNumber
    currentHasValidatedLocation = user.hasValidatedLocation

    // in case this cell is already in view, run the animation after a delay
    if showBasicSurveyValidationCheckAnimation || showPhoneValidationCheckAnimation || showLocationValidationCheckAnimation {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.runAnimationsIfNeeded()
      }
    }
  }
  
  func showPhoneNumberSurveyValidationImage() {
    phoneValidationImageView.snp.remakeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview()
      make.width.height.equalTo(Layout.validationImageWidth)
    }
    
    startBasicPhoneNumberSurveyButton.snp.remakeConstraints { make in
      make.height.width.equalTo(0)
    }
  }

  func showBasicProfileSurveyValidationImage() {
    basicProfileSurveyValidationImageView.snp.remakeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview()
      make.width.height.equalTo(Layout.validationImageWidth)
    }
    
    startBasicProfileSurveyButton.snp.remakeConstraints { make in
      make.height.width.equalTo(0)
    }
  }

    func showPhoneNumberSurveyStartButton() {
        phoneValidationImageView.snp.remakeConstraints { make in
            make.height.width.equalTo(0)
        }
        let selectedLanguage = AppLanguageManager.shared.getLanguage()
        if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
            startBasicPhoneNumberSurveyButton.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview()
                make.width.equalTo(Layout.validationButtonWidthForPT)
                make.height.equalTo(Layout.validationButtonHeight)
            }
        } else {
            startBasicPhoneNumberSurveyButton.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview()
                make.width.equalTo(Layout.validationButtonWidth)
                make.height.equalTo(Layout.validationButtonHeight)
            }
        }
        
    }

  func showBasicProfileSurveyStartButton() {
    basicProfileSurveyValidationImageView.snp.remakeConstraints { make in
      make.height.width.equalTo(0)
    }
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        startBasicProfileSurveyButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(Layout.validationButtonWidthForPT)
            make.height.equalTo(Layout.validationButtonHeight)
        }
    } else {
        startBasicProfileSurveyButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(Layout.validationButtonWidth)
            make.height.equalTo(Layout.validationButtonHeight)
        }
    }
//    startBasicProfileSurveyButton.snp.remakeConstraints { make in
//      make.centerY.equalToSuperview()
//      make.right.equalToSuperview()
//      make.width.equalTo(Layout.validationButtonWidth)
//      make.height.equalTo(Layout.validationButtonHeight)
//    }
  }

  func showLocationValidationImage() {
    locationValidationActivityIndicator.stopAnimating()

    locationValidationImageView.snp.remakeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview()
      make.width.height.equalTo(Layout.validationImageWidth)
    }
    
    startLocationValidationButton.snp.remakeConstraints { make in
      make.height.width.equalTo(0)
    }
  }
  
  func showLocationValidationStartButton() {
    locationValidationActivityIndicator.stopAnimating()

    locationValidationImageView.snp.remakeConstraints { make in
      make.height.width.equalTo(0)
    }
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        startLocationValidationButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(Layout.validationButtonWidthForPT)
            make.height.equalTo(Layout.validationButtonHeight)
        }
    } else {
        startLocationValidationButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(Layout.validationButtonWidth)
            make.height.equalTo(Layout.validationButtonHeight)
        }
    }
//    startLocationValidationButton.snp.remakeConstraints { make in
//      make.centerY.equalToSuperview()
//      make.right.equalToSuperview()
//      make.width.equalTo(Layout.validationButtonWidth)
//      make.height.equalTo(Layout.validationButtonHeight)
//    }
  }
  
  func showLocationValidationSpinner() {
    locationValidationImageView.snp.remakeConstraints { make in
      make.height.width.equalTo(0)
    }

    startLocationValidationButton.snp.remakeConstraints { make in
      make.height.width.equalTo(0)
    }
    
    locationValidationActivityIndicator.startAnimating()
  }

  @objc func startPhoneNumberSurvey() {
    startBasicPhoneNumberSurveyButton.bounceBriefly()
    onboardingItemDelegate?.didTapStartPhoneNumberSurveyButton()
    AnalyticsManager.shared.logOnce(event: .startPhoneValidationTapped)
  }

  @objc func startBasicProfileSurvey() {
    startBasicProfileSurveyButton.bounceBriefly()
    onboardingItemDelegate?.didTapStartBasicProfileSurveyButton()
    AnalyticsManager.shared.logOnce(event: .startBasicProfileTapped)
  }

  @objc func startLocationValidation() {
    startLocationValidationButton.bounceBriefly()

    // bzzzz
    generator.impactOccurred()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      self.showLocationValidationSpinner()
    }

    // fake delay to make it seem like something more complicated is happening
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      self.onboardingItemDelegate?.didTapStartLocationValidationButton()
    }

    AnalyticsManager.shared.logOnce(event: .startLocationValidationTapped)
  }
  
  func runAnimationsIfNeeded() {
    var delay = 0.5
    
    if showPhoneValidationCheckAnimation {
      showPhoneValidationCheckAnimation = false
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        self.phoneValidationImageView.image = Image.validationSuccess.value
        
        // bzzzz
        self.generator.impactOccurred()
      }
      delay += 0.5
    }
    
    if showBasicSurveyValidationCheckAnimation {
      showBasicSurveyValidationCheckAnimation = false
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        self.basicProfileSurveyValidationImageView.image = Image.validationSuccess.value
        
        // bzzzz
        self.generator.impactOccurred()
      }
      
      delay += 0.5
    }

    if showLocationValidationCheckAnimation {
      showLocationValidationCheckAnimation = false
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        self.locationValidationImageView.image = Image.validationSuccess.value
        self.generator.impactOccurred()
      }
    }

    runFinishIfNecessary(delay: delay + 2.0)
  }

  @objc func onUserChanged() {
    updateProgress()
  }

  @objc func onFeedDidAppear() {
    runAnimationsIfNeeded()
  }
  
  @objc func contactSupportButtonTapped() {
    /*let email = "support@measureprotocol.com"
    let url = URL(string: "mailto:\(email)?subject=Help%20with%20location%20validation")
    UIApplication.shared.open(url!)*/
    onboardingItemDelegate?.didTapContactSupportButton()
  }
  
  func runFinishIfNecessary(delay: Double = 1.0) {
    guard let user = UserManager.shared.user else {
      return
    }
    if user.hasValidatedEmail == true && user.hasValidatedPhoneNumber == true
        && user.hasFilledBasicDemos == true && user.hasValidatedLocation == true {
        NotificationCenter.default.post(name: .onboardingFinished, object: nil, userInfo: nil)
    }

    if !hasProcessedOnboardingFinished {
      AnalyticsManager.shared.logOnce(event: .finishedValidation)
      hasProcessedOnboardingFinished = true
    }
  }
}

extension OnboardingItemCollectionViewCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity,
          let colors = community.colors, let images = community.images else {
      return
    }
    
    imageView.setImageWithAssetOrURL(with: images.welcomeCard)
    startBasicProfileSurveyButton.setTitleColor(colors.primary, for: .normal)
    startBasicPhoneNumberSurveyButton.setTitleColor(colors.primary, for: .normal)
    startLocationValidationButton.setTitleColor(colors.primary, for: .normal)
  }
}
