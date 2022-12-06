//
//  SurveyIntroViewController.swift
//  Contributor
//
//  Created by arvindh on 14/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import Alamofire
import SwiftyAttributes
import FirebaseRemoteConfig
import WebKit

class SurveyIntroViewController: UIViewController, SurveyLoadable, SpinnerDisplayable, StaticViewDisplayable {
  struct Layout {
    static let categoryIconViewWidth: CGFloat = 54
    static let categoryIconViewHeight: CGFloat = 54
    static let titleTopMargin: CGFloat = 20
    static let titleBottomMargin: CGFloat = 20
    static let detailBottomMargin: CGFloat = 30
    static let actionButtonBottomMargin: CGFloat = 10
    static let actionButtonWidth: CGFloat = 130
    static let actionButtonWidthForPT: CGFloat = 200
    static let actionButtonHeight: CGFloat = 44
    static let containerInset: CGFloat = 20
    static var borderHeight: CGFloat = 1
    static var privacyImageWidth: CGFloat = 20
    static var privacyImageHeight: CGFloat = 20
    static var jobTypeImageWidth: CGFloat = 20
    static var jobTypeImageHeight: CGFloat = 20
  }
  
  private enum CommunityLink {
    case privacyPolicy
    case termsOfService
    case accessibility
    case contact
  }
  
  var surveyManager: SurveyManager
  var offer: OfferItem?
  var spinnerViewController: SpinnerViewController = SpinnerViewController()
  var staticMessageViewController: FullScreenMessageViewController?
  fileprivate var markAsDeclinedBackgroundTaskRunner: BackgroundTaskRunner!
  let generator = UIImpactFeedbackGenerator(style: .light)
  var screenType: SurveyScreenType? = .myFeed
    
  let outerContainer: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    return view
  }()
  
  let topBorder: UIView = UIView()
  let container = UIView()

  let imageContainerView: UIView = {
    let view = UIView()
    view.layer.masksToBounds = true
    return view
  }()
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    return iv
  }()
  
  let gradientView = LayerContainerView()
  
  func updateGradientColors(color1: UIColor, color2: UIColor) {
    gradientView.color1 = color1
    gradientView.color2 = color2
  }

  let cardHeaderContainer = UIView()
  
  let jobTypeLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 16)
    label.textColor = Color.lightText.value
    label.numberOfLines = 1
    return label
  }()
  
  let msrPillView: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBackground.value
    view.layer.cornerRadius = 3
    return view
  }()
  
  let msrLabel: UILabel = {
    let label = UILabel()
    label.font = Font.bold.of(size: 16)
    label.numberOfLines = 1
    label.textColor = Color.text.value
    return label
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.bold.of(size: 22)
    label.numberOfLines = 0
    return label
  }()
  
  let detailLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 16)
    label.numberOfLines = 0
    return label
  }()
  
  let timeLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 16)
    label.textColor = Color.lightText.value
    label.numberOfLines = 1
    return label
  }()
  
  let expiryLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 16)
    label.textColor = Color.lightText.value
    label.numberOfLines = 1
    return label
  }()
  
  let actionContainer = UIView()

  let actionButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle(Text.startJob.localized(), for: .normal)
    button.titleLabel?.font = Font.regular.of(size: 18)
    button.layer.cornerRadius = Constants.buttonCornerRadius
    return button
  }()
  
  let orLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 18)
    label.numberOfLines = 1
    label.text = Text.or.localized()
    return label
  }()
  
  let declineButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.textAlignment = .left
    button.titleLabel?.font = Font.regular.of(size: 18)
    let text = SurveyText.declineOffer.localized().withAttributes([
      Attribute.font(Font.regular.of(size: 18)),
      Attribute.textColor(UIColor.red),
      Attribute.underlineStyle(UnderlineStyle.single),
      Attribute.underlineColor(UIColor.red)
    ])
    button.setAttributedTitle(text, for: .normal)
    return button
  }()

  let stackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 10
    return stack
  }()
  
  let border2: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
    return view
  }()
  
  let bottomContainer: UIView = {
    let view = UIView()
    return view
  }()

  let bottomContentContainer: UIView = {
    let view = UIView()
    return view
  }()
    
  let webStackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.addBackground(color: .clear)
    stack.spacing = 0
    return stack
  }()
    
  let disclaimerWebView: WKWebView = {
    var disclaimerWebView = WKWebView()
    let config = WKWebViewConfiguration()
    disclaimerWebView = WKWebView(frame: CGRect.zero, configuration: config)
    disclaimerWebView.contentMode = .scaleAspectFit
    return disclaimerWebView
  }()
    
  let activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.tintColor = .gray
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
  }()

  let jobTypeImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.image = Image.survey.value
    return iv
  }()
  
  let jobTypeHeadingLabel: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 16)
    label.textColor = Color.text.value
    label.text = SurveyText.profileSurvey.localized()
    return label
  }()

  let jobTypeContentLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 16)
    label.numberOfLines = 0
    label.textColor = Color.lightText.value
    return label
  }()

  let privacyImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.image = Image.privacy.value
    return iv
  }()
  
  let privacyHeadingLabel: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 16)
    label.textColor = Color.text.value
    label.text = SurveyText.dataPrivacy.localized()
    return label
  }()
  
  let privacyContentLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 16)
    label.numberOfLines = 0
    label.textColor = Color.lightText.value
    return label
  }()
  
  let communityLinksStackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 5
    return stack
  }()
  
  let communityPrivacyPolicyButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.textAlignment = .left
    return button
  }()

  let communityTermsOfServiceButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.textAlignment = .left
    return button
  }()
  
  let communityAccessibilityButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.textAlignment = .left
    return button
  }()
  
  let communityContactButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.textAlignment = .left
    return button
  }()
  
  init(surveyManager: SurveyManager, screenType: SurveyScreenType) {
    self.surveyManager = surveyManager
    self.screenType = screenType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerForSurveyLoadNotifications()
    setTitle(Text.startJob.localized())
    setupViews()
    setupNavbar()
    updateUIForSurvey()
    hideBackButtonTitle()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // force a rotation if there was an exit from the survey and it was in landscape
    UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: Constants.orientation)
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.startJobScreen)
  }

  override func setupViews() {
    view.addSubview(topBorder)
    topBorder.snp.makeConstraints { (make) in
      make.top.left.right.equalToSuperview()
      make.height.equalTo(Layout.borderHeight)
    }

    view.addSubview(outerContainer)
    outerContainer.snp.makeConstraints { (make) in
      make.top.equalTo(topBorder.snp.bottom)
      make.left.right.equalToSuperview()
    }
    
    outerContainer.addSubview(imageContainerView)
    imageContainerView.addSubview(gradientView)
    gradientView.snp.makeConstraints { (make) in
      make.edges.equalTo(imageContainerView)
    }
    imageContainerView.addSubview(imageView)

    outerContainer.addSubview(container)
    container.snp.makeConstraints { (make) in
      make.top.equalTo(imageContainerView.snp.bottom)
      make.left.equalTo(outerContainer).offset(Layout.containerInset)
      make.right.equalTo(outerContainer).offset(-Layout.containerInset)
      make.bottom.equalTo(outerContainer)
    }

    container.addSubview(stackView)
    stackView.snp.makeConstraints { (make) in
      make.top.equalTo(imageContainerView.snp.bottom).offset(15)
      make.left.equalTo(container)
      make.right.equalTo(container)
      make.bottom.equalTo(container).offset(-38).priority(999)
    }
    
    stackView.addArrangedSubview(cardHeaderContainer)
    stackView.setCustomSpacing(25, after: cardHeaderContainer)
    
    // note: margins for all of these are set in setStackViewMargins based on content
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(detailLabel)
    stackView.addArrangedSubview(timeLabel)
    stackView.addArrangedSubview(expiryLabel)
    stackView.addArrangedSubview(actionContainer)
    actionButton.addTarget(self, action: #selector(self.startSurvey), for: .touchUpInside)
    declineButton.addTarget(self, action: #selector(self.declineSurvey), for: .touchUpInside)

    cardHeaderContainer.snp.makeConstraints { (make) in
      make.height.equalTo(26)
      make.width.equalToSuperview()
    }
    
    cardHeaderContainer.addSubview(jobTypeLabel)
    jobTypeLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(cardHeaderContainer)
      make.left.equalTo(cardHeaderContainer)
      make.height.equalTo(26)
    }
    
    msrPillView.addSubview(msrLabel)
    msrLabel.snp.makeConstraints { (make) in
      make.top.bottom.equalToSuperview()
      make.left.equalToSuperview().offset(5)
      make.right.equalToSuperview().offset(-5)
    }
    
    cardHeaderContainer.addSubview(msrPillView)
    msrPillView.snp.makeConstraints { (make) in
      make.centerY.equalTo(jobTypeLabel)
      make.height.equalTo(26)
      make.right.equalTo(cardHeaderContainer)
    }

    actionContainer.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
    }
    
    actionContainer.addSubview(actionButton)
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        actionButton.snp.makeConstraints { (make) in
          make.top.equalTo(actionContainer)
          make.left.equalTo(actionContainer)
          make.width.equalTo(Layout.actionButtonWidthForPT)
          make.height.equalTo(Layout.actionButtonHeight)
          make.bottom.equalTo(actionContainer)
        }
    } else {
        actionButton.snp.makeConstraints { (make) in
          make.top.equalTo(actionContainer)
          make.left.equalTo(actionContainer)
          make.width.equalTo(Layout.actionButtonWidth)
          make.height.equalTo(Layout.actionButtonHeight)
          make.bottom.equalTo(actionContainer)
        }
    }
    view.addSubview(border2)
    border2.snp.makeConstraints { (make) in
      make.top.equalTo(outerContainer.snp.bottom)
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.height.equalTo(Layout.borderHeight)
    }
    
    view.addSubview(bottomContainer)
    bottomContainer.snp.makeConstraints { (make) in
      make.top.equalTo(border2.snp.bottom)
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(view)
    }
    
    if screenType == .myFeed
        && UserManager.shared.user?.isAcceptingOffers == true {
        updateDisclaimerPageFromFeed()
    } else {
        updateDisclaimerPageFromMyData()
    }
    applyCommunityTheme()
  }
  
  @objc func showCommunityPrivacyPolicy() {
    showCommunityLink(.privacyPolicy)
  }

  @objc func showCommunityTermsOfService() {
    showCommunityLink(.termsOfService)
  }

  @objc func showCommunityAccessibility() {
    showCommunityLink(.accessibility)
  }

  @objc func showCommunityContact() {
    showCommunityLink(.contact)
  }

  private func showCommunityLink(_ linkType: CommunityLink) {
    switch surveyManager.surveyType {
    case .externalOffer(let offerItem):
      var community: Community?
      if let slug = offerItem.communitySlug {
        community = UserManager.shared.user?.getCommunityForSlug(slug: slug)
      } else {
        if UserManager.shared.user?.communities.count == 1 && !UserManager.shared.isDefaultCommunity {
          community = UserManager.shared.currentCommunity
        }
      }
      
      if let community = community {
        var url: URL?
        switch linkType {
        case .privacyPolicy:
          url = community.text.privacyPolicyURL
        case .termsOfService:
          url = community.text.termsOfServiceURL
        case .accessibility:
          url = community.text.accessibilityURL
        case .contact:
          url = community.text.contactURL
        }
        
        if let url = url {
          let webContentViewController = WebContentViewController()
          webContentViewController.startURL = url
          show(webContentViewController, sender: self)
        }
      }
    default:
      break
    }
  }

  func updateUIForSurvey() {
    defer {
      updateContent()
    }
    
    var shouldContinue: Bool = true
    switch surveyManager.surveyType {
    case .externalOffer:
      shouldContinue = false
    default:
      break
    }
    
    if !shouldContinue {
      return
    }
    
    guard let _ = surveyManager.survey else {
      showSpinner()
      return
    }
  }
  
  func willFetchSurvey() {
    showSpinner()
  }
  
  func didFetchSurvey() {
    let shouldFetchProfile = RemoteConfig.remoteConfig().configValue(forKey: FirebaseRemoteConfigKey.shouldFetchProfileOnSurveyStart.rawValue).boolValue
    
    let finish = {
      [weak self] in
      self?.hideSpinner()
      self?.updateUIForSurvey()
    }
    
    if shouldFetchProfile {
      UserManager.shared.profileStore?.fetchProfile({ (profile, error) in
        if error == nil {
             //Updating previous saved values
              if let updatedValue = profile?.json {
                self.surveyManager.store(newValues: updatedValue)
                self.surveyManager.loadInitialValues()
              }
        }
        finish()
      })
    }
    else {
      finish()
    }
  }
  
  func didFailToFetchSurvey(_ notification: Notification) {
    hideSpinner()
    let message = MessageHolder(message: Message.genericFetchError)
    show(staticMessage: message)
  }

 func setStackViewMargins() {
    // figure out where to put the big margin above the button row
    if !expiryLabel.isHidden {
      stackView.setCustomSpacing(34, after: expiryLabel)
    } else if !timeLabel.isHidden {
      stackView.setCustomSpacing(34, after: timeLabel)
    } else if !detailLabel.isHidden {
      stackView.setCustomSpacing(34, after: detailLabel)
    } else if !titleLabel.isHidden {
      stackView.setCustomSpacing(34, after: titleLabel)
    }
    
    // small margin between time and expiry if both are visible
    if !timeLabel.isHidden && !expiryLabel.isHidden {
      stackView.setCustomSpacing(5, after: timeLabel)
    }

    // medium margin below detail/title if time or expiry visible
    if !timeLabel.isHidden || !expiryLabel.isHidden {
      if !detailLabel.isHidden {
        stackView.setCustomSpacing(25, after: detailLabel)
      } else if !titleLabel.isHidden {
        stackView.setCustomSpacing(25, after: titleLabel)
      }
    }
  }
  
  func showImage(widthRatio: CGFloat, heightRatio: CGFloat) {
    imageContainerView.snp.makeConstraints() { (make) in
      make.top.equalTo(outerContainer)
      make.left.right.equalTo(outerContainer).priority(750)
      make.height.equalTo(view.frame.width * heightRatio / widthRatio)
    }
    
    imageView.snp.remakeConstraints { (make) in
      make.edges.equalTo(imageContainerView)
    }
    
    // hide the top border when there is an image
    topBorder.backgroundColor = Color.whiteText.value

    outerContainer.setNeedsUpdateConstraints()
  }
  
  func hideImage() {
    imageContainerView.snp.makeConstraints { (make) in
      make.top.equalTo(outerContainer)
      make.left.right.equalTo(outerContainer).priority(750)
      make.height.width.equalTo(0)
    }

    // make the top border visible when no image
    topBorder.backgroundColor = Color.lightBorder.value
    
    outerContainer.setNeedsUpdateConstraints()
  }
  
  func showCategoryImage() {
    imageContainerView.snp.makeConstraints() { (make) in
      make.top.equalTo(outerContainer)
      make.left.equalTo(outerContainer)
      make.right.equalTo(outerContainer)
      make.height.equalTo(140)
    }

    imageView.snp.remakeConstraints { (make) in
      make.centerX.equalTo(imageContainerView)
      make.centerY.equalTo(imageContainerView)
      make.width.equalTo(Layout.categoryIconViewWidth)
      make.height.equalTo(Layout.categoryIconViewHeight)
    }
    outerContainer.setNeedsUpdateConstraints()
  }
  
  func hideMSRPill() {
    msrPillView.snp.removeConstraints()
    msrLabel.snp.removeConstraints()
    msrPillView.removeFromSuperview()
    cardHeaderContainer.setNeedsUpdateConstraints()
  }
  
  func showDeclineButton() {
    actionContainer.addSubview(orLabel)
    orLabel.snp.makeConstraints { (make) in
      make.left.equalTo(actionButton.snp.right).offset(8)
      make.centerY.equalTo(actionButton)
    }
    
    actionContainer.addSubview(declineButton)
    declineButton.snp.makeConstraints { (make) in
      make.left.equalTo(orLabel.snp.right).offset(8)
      make.centerY.equalTo(orLabel)
    }
    
    actionContainer.setNeedsUpdateConstraints()
  }
  
  func showExpiryLabel() {
    expiryLabel.isHidden = false
  }

  func hideExpiryLabel() {
    expiryLabel.isHidden = true
  }

  func setupNavbar() {
    if let _ = self.presentingViewController {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: Text.close.localized(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(close))
      navigationItem.leftBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 17), for: .normal)
    }
  }
  
  @objc func startSurvey() {
    let surveyType = surveyManager.surveyType
    
    switch surveyType {
    case .welcome:
      UserManager.shared.currentlyTakingInternalSurvey = true
      
      Router.shared.route(
        to: Route.surveyPage(surveyManager: surveyManager),
        from: self,
        presentationType: .push(surveyToolBarNeeded: true)
      )

    case .category(_):
      AnalyticsManager.shared.log(
        event: .selfProfileJobStarted,
        params: [
          "ref": surveyType.categoryRef
        ]
      )
      
      UserManager.shared.currentlyTakingInternalSurvey = true
      
      Router.shared.route(
        to: Route.surveyPage(surveyManager: surveyManager),
        from: self,
        presentationType: .push(surveyToolBarNeeded: true)
      )

    case .categoryOffer(let offerItem, _):
      AnalyticsManager.shared.log(
        event: .makeWorkProfileJobStarted,
        params: [
          "survey_id": offerItem.offerIDForAnalytics
        ]
      )
      
      if ConnectivityUtils.isConnectedToNetwork() == false {
          Helper.showNoNetworkAlert(controller: self)
          return
      }
      if let minutes = offerItem.minutesUntilExpiry, minutes == 0 {
        close()
        return
      }
        SurveyCallbackManager.shared.callback(surveyType: surveyType, callbackType: .started, completion: { (response, _,  error) in
            if let response = response {
                if (response.nextAction == JobCompletionStaus.terminate.lowercased()) {
                    debugPrint("Navigate to Terminate Screen ")
                    self.navigateToCompletionScreenOnClosedSurvey(surveyType: surveyType)
                } else {
                    UserManager.shared.currentlyTakingInternalSurvey = true
                    Router.shared.route(
                        to: Route.surveyPage(surveyManager: self.surveyManager, offerItem: offerItem),
                        from: self,
                        presentationType: .push(surveyToolBarNeeded: true)
                    )
                }
            } else {
                if let error = error {
                    debugPrint("Error is ", error)
                    let toaster = Toaster(view: self.view)
                    toaster.toast(message: "Something went wrong", position: .bottom)
                }
            }
        })
    case .embeddedOffer(let offerItem, _):
      AnalyticsManager.shared.log(
        event: .selfProfileMaintenanceJobStarted,
        params: [
          "survey_id": offerItem.offerIDForAnalytics
        ]
      )
      
      if ConnectivityUtils.isConnectedToNetwork() == false {
          Helper.showNoNetworkAlert(controller: self)
          return
      }
      if let minutes = offerItem.minutesUntilExpiry, minutes == 0 {
        close()
        return
      }
        SurveyCallbackManager.shared.callback(surveyType: surveyType, callbackType: .started, completion: { (response, _, error) in
            debugPrint("Survey Result is ", response)
            if let response = response {
                if (response.nextAction == JobCompletionStaus.terminate.lowercased()) {
                    debugPrint("Navigate to Terminate Screen ")
                    self.navigateToCompletionScreenOnClosedSurvey(surveyType: surveyType)
                } else {
                    UserManager.shared.currentlyTakingInternalSurvey = true

                    Router.shared.route(
                        to: Route.surveyPage(surveyManager: self.surveyManager),
                      from: self,
                      presentationType: .push(surveyToolBarNeeded: true)
                    )
                }
            } else {
                UserManager.shared.currentlyTakingInternalSurvey = true

                Router.shared.route(
                    to: Route.surveyPage(surveyManager: self.surveyManager),
                  from: self,
                  presentationType: .push(surveyToolBarNeeded: true)
                )
            }
        })
      

    case .externalOffer(let offerItem):
      AnalyticsManager.shared.log(
        event: .paidSurveyJobStarted,
        params: [
          "survey_id": offerItem.offerIDForAnalytics
        ]
      )
      
      if ConnectivityUtils.isConnectedToNetwork() == false {
          Helper.showNoNetworkAlert(controller: self)
          return
      }
      if let minutes = offerItem.minutesUntilExpiry, minutes == 0 {
        close()
        return
      }
        SurveyCallbackManager.shared.callback(surveyType: surveyType, callbackType: .started, completion: { (response,_, error) in
            if let response = response {
                if (response.nextAction == JobCompletionStaus.terminate.lowercased()) {
                    debugPrint("Navigate to Terminate Screen ")
                    self.navigateToCompletionScreenOnClosedSurvey(surveyType: surveyType)
                } else {
                    UserManager.shared.currentlyTakingExternalSurvey = true
                    if offerItem.sampleRequestType == SampleRequestType.workShopSurvey {
                      NetworkManager.shared.getOfferNativeSurvey(workShopURL: offerItem.urlString) { [weak self] (survey, error) in
                          guard let this = self else {
                              return
                          }
                          if let _ = error {
                          } else {
                              DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                  this.updateNavigationFlow(offerItem, survey)
                              }
                          }
                      }
                    } else {
                        Router.shared.route(
                            to: Route.externalSurveyPage(offerItem: offerItem, delegate: self, surveyManager: self.surveyManager),
                          from: self,
                          presentationType: .push(surveyToolBarNeeded: true)
                        )
                    }
                }
            } else {
                if let error = error {
                    debugPrint("Error is ", error)
                    let toaster = Toaster(view: self.view)
                    toaster.toast(message: "Something went wrong", position: .bottom)
                }
            }
        })
    
    }
  }
    func navigateToCompletionScreenOnClosedSurvey(surveyType:SurveyType){
        Router.shared.route(
           to: Route.surveyCompletion(surveyType: surveyType,
                                      surveyStatus: .closed,
                                      delegate: self
           ),
           from: self,
           presentationType: .push(surveyToolBarNeeded: false)
         )
    }
func updateNavigationFlow(_ offerItem: OfferItem, _ workShopSurvey: NativeOfferSurvey?) {
    if let currentBlock = surveyManager.currentPage?.blocks.filter({$0.blockType == BlockPageType.screenCapture.rawValue || $0.blockType == BlockPageType.oAuthCapture.rawValue}),
        currentBlock.isEmpty == false {
        Router.shared.route(
            to: Route.externalSurveyPage(offerItem: offerItem,
                                         nativeOfferBlock: currentBlock[0],
                                         delegate: self, surveyManager: surveyManager),
          from: self,
          presentationType: .push(surveyToolBarNeeded: true, needOnlyExitButton: true)
        )
    } else {
        Router.shared.route(
          to: Route.surveyPage(surveyManager: surveyManager, offerItem: offerItem),
          from: self,
          presentationType: .push(surveyToolBarNeeded: true)
        )
    }
}

  @objc func declineSurvey() {
    let surveyType = surveyManager.surveyType

    switch surveyType {
    case .categoryOffer(let offerItem, _), .externalOffer(let offerItem), .embeddedOffer(let offerItem, _):
        SurveyCallbackManager.shared.callback(surveyType: surveyType, callbackType: .terminated, completion: { (response,_, error) in
            if let response = response {
                if (response.nextAction == JobCompletionStaus.terminate.lowercased()) {
                    debugPrint("Navigate to Terminate Screen ")
                    
                } else {
                    self.markAsDeclinedBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
                    self.markAsDeclinedBackgroundTaskRunner.startTask {
                      NetworkManager.shared.markOfferItemsAsDeclined(items: [offerItem]) {
                        [weak self] error in

                        if let _ = error {
                          os_log("markOfferItemsAsDeclined failed", log: OSLog.feed, type: .error)
                        }
                          let parameters = [
                               "srid": offerItem.sampleRequestID! as Any,
                               "cid": UserManager.shared.user!.userID! as Any,
                               "survey-user-terminated reason": "declined"
                           ]
                          if let url = offerItem.userTerminatedCallbackURLString {
                              Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                                    .validate()
                                    .responseJSON { response in
                                    switch response.result {
                                    case .failure(_): break
                                    default:
                                      break
                                }
                          }
                         self?.markAsDeclinedBackgroundTaskRunner.endTask()
                        }
                      }
                    }
                    let offerInfo: [String: Int] = ["offerID": offerItem.offerID]
                    NotificationCenter.default.post(name: NSNotification.Name.offerDeclined, object: nil, userInfo: offerInfo)                }
            } else {
                if let error = error {
                    debugPrint("Error is ", error)
                }
            }
        })
    default:
      break
    }
    
    close()
  }
  
  @objc func close() {
    // bzzzz
    generator.impactOccurred()
    dismissSelf()
  }
}

extension SurveyIntroViewController: MessageViewControllerDelegate {
  func didTapActionButton() {
    hideStaticMessage()
    surveyManager.fetchSurveyAndStart({ _ in })
  }
}

extension SurveyIntroViewController: ExternalSurveyDelegate {
  func externalSurveyDidDismiss() {
    NotificationCenter.default.post(name: NSNotification.Name.externalSurveyFinished, object: nil)
  }
}

extension SurveyIntroViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors, let images = community.images else {
      return
    }

    actionButton.setDarkeningBackgroundColor(color: colors.primary)
    actionButton.setTitleColor(colors.background, for: .normal)
    
    communityPrivacyPolicyButton.setAttributedTitle(
        Text.privacyText.localized().withAttributes([
        Attribute.font(Font.regular.of(size: 16)),
        Attribute.textColor(colors.primary),
        Attribute.underlineStyle(.single),
        Attribute.underlineColor(colors.primary)
      ]), for: .normal)

    communityTermsOfServiceButton.setAttributedTitle(
        Text.termOfService.localized().withAttributes([
        Attribute.font(Font.regular.of(size: 16)),
        Attribute.textColor(colors.primary),
        Attribute.underlineStyle(.single),
        Attribute.underlineColor(colors.primary)
      ]), for: .normal)

    communityAccessibilityButton.setAttributedTitle(
        Text.accessibility.localized().withAttributes([
        Attribute.font(Font.regular.of(size: 16)),
        Attribute.textColor(colors.primary),
        Attribute.underlineStyle(.single),
        Attribute.underlineColor(colors.primary)
      ]), for: .normal)

    communityContactButton.setAttributedTitle(
        Text.contact.localized().withAttributes([
        Attribute.font(Font.regular.of(size: 16)),
        Attribute.textColor(colors.primary),
        Attribute.underlineStyle(.single),
        Attribute.underlineColor(colors.primary)
      ]), for: .normal)
  }
}
extension SurveyIntroViewController: SurveyCompletionDelegate {
  func didCompleteSurvey(_ surveyManager: SurveyManager?) {
  }
}
