//
//  Router.swift
//  Contributor
//
//  Created by arvindh on 12/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import Photos

enum SurveyScreenType {
  case myData
  case myFeed
}

enum OfferTypes {
  case internalOffer
  case externalOffer
}

enum Route {
  case onboarding(templateData: [OnboardingMessage])
  case login
  case signUpOrLogin
  case mainNav
  case signup
  case signupDemographics(surveyManager: SurveyManager)
  case surveyStart(surveyManager: SurveyManager, screenType: SurveyScreenType)
  case surveyPage(surveyManager: SurveyManager, offerItem: OfferItem? = nil)
  case surveyCompletion(surveyType: SurveyType, surveyStatus: SurveyStatus,
                        delegate: SurveyCompletionDelegate, surveyManager: SurveyManager? = nil,
                        videoUrl: String? = nil, externalSurveyMessage: ExternalSurveyCompletion? = nil,
                        hasSkipContentValidation: Bool = false,
                        twitterDetail: [String: Any]? = nil
)
  case externalSurveyPage(offerItem: OfferItem, nativeOfferBlock: SurveyBlock? = nil,
                          delegate: ExternalSurveyDelegate, surveyManager: SurveyManager)
  case cameramanPage(offerItem: OfferItem, nativeOfferBlock: SurveyBlock?,
                     surveyManager: SurveyManager?, uploadURL: URL? = nil,
                     asset: PHAsset? = nil, image: UIImage? = nil, date: Date? = nil, twitterDetail: [String: Any]? = nil)
  case cameramanUploadPage(videoData: MediaUploadResponse, selectedUrl: URL,
                           surveyManager: SurveyManager?, offerItem: OfferItem,
                           screenCaptureType: ScreenCaptureType, hasSkipContentValidation: Bool)
  case datePicker(date: Date?, datePickerMode: UIDatePicker.Mode, delegate: DatePickerDelegate)
  case notificationPermission
  case emailValidation
  case phoneNumberValidation
  case otpValidation(phoneNumber: String, delegate: OtpValidationDelegate)
  case confirmation
  case ageRequirementNotMet
  case myData
  case showGiftCards(option: PaymentType)
  case feed
  case wallet
  case settings
  case dynataDetail(_ connectAppData: ConnectedAppData?)
  case dataType(dataType: ConnectedDataType, connectAppData: [ConnectedAppData])
  case connect(appType: ConnectedApp,
               connectAppData: ConnectedAppData? = nil,
               offerItem: OfferItem? = nil)
  case connectionSuccess(appType: ConnectedApp)
  case connectionFailure(appType: ConnectedApp)
  case redeemGiftCard(redemptionType: PaymentType ,
                        paypalEmail: String? = nil,
                        option: GiftCardRedemptionOption,
                        delegate: RedeemCompletionDelegate)
  case passwordReset
  case customPopUp(communitySlug: String? = nil, communityUserID: String? = nil,
                   type: PopUpType, delegate: customPopDelegate)
  case redeemGenericReward(balance: Balance)
  case walletDetail(_ connectAppData: ConnectedApp? = nil, _ transaction: WalletTransaction? = nil,
                    _ transId: Int? = nil, isFromNotif: Bool? = false)
  case personalEdit
  case changePassword
  case support(isFromWallet: Bool? = false, _ transactionId: String? = "")
  case referView(inviteCode: String)
  case giftWalletDetail(_ connectAppData: ConnectedApp? = nil, _ transaction: WalletTransaction? = nil)
  case referWalletDetail(_ connectAppData: ConnectedApp? = nil, _ transaction: WalletTransaction? = nil)
  case profileAttributeList
  case jobExitView(offerType: OfferTypes)
  case retroValidationTest(testModel: CameraTestModel)
  case retroValidationTestDetail(testModel: CameramanTestModel)
  case changeLanguage
}

enum PresentationType {
  case root(embedInNav: Bool) //when changing the rootViewController of the app
  case push(surveyToolBarNeeded: Bool = false, needOnlyExitButton: Bool = false, fromTabBar: Bool = false)
  case pop
  case modal(presentationStyle: UIModalPresentationStyle, transitionStyle: UIModalTransitionStyle)
  case custom(presenterType: Presenter.Type)
}

class Router: NSObject {
  static let shared: Router = {
    let router = Router()
    return router
  }()
      
  func route(
    to route: Route,
    from viewController: UIViewController,
    presentationType: PresentationType = .push()
  ) {
    let destinationViewController = self.destinationViewController(for: route)

    switch presentationType {
    case .push(let surveyToolBarNeeded, let needOnlyExitButton, let fromTabBar):
        if surveyToolBarNeeded {
            setupNavbar(controller: destinationViewController, needOnlyExitButton: needOnlyExitButton)
        }
        if fromTabBar {
            viewController.navigationController?.pushViewController(destinationViewController, animated: true)
        } else {
            viewController.navigationController?.pushViewController(destinationViewController, animated: true)
        }
    case .pop:
      let nav = viewController.navigationController
      
      guard let vc = nav?.viewControllers.last(where: { (vc) -> Bool in
        return type(of: vc) == type(of: destinationViewController)
      }) else {
        return
      }
      
      nav?.popToViewController(vc, animated: true)
    case .modal(let presentationStyle, let transitionStyle):
      let nav = NavigationViewController(rootViewController: destinationViewController)
      nav.modalPresentationStyle = presentationStyle
      nav.modalTransitionStyle = transitionStyle
      viewController.present(nav, animated: true, completion: nil)
    case .root(let embedInNav):
      let viewControllerToPresent = embedInNav ? NavigationViewController(rootViewController: destinationViewController) : destinationViewController
      viewController.rootViewController?.viewController = viewControllerToPresent
    case .custom(let presenterType):
      let presenter = presenterType.init(presentingViewController: viewController, presentedViewController: destinationViewController)
      presenter.present()
    }
  }
    
func setupNavbar(controller: UIViewController, needOnlyExitButton: Bool) {
      let backButton = UIBarButtonItem(image: UIImage(named: "backward"),
                                       style: UIBarButtonItem.Style.plain, target: self,
                                       action: #selector(moveToBack))
      let forwardButton = UIBarButtonItem(image: UIImage(named: "forward"),
                                          style: UIBarButtonItem.Style.plain,
                                          target: self, action: #selector(moveToForward))
    controller.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Exit".localized(),
                                                                     style: UIBarButtonItem.Style.plain,
                                                                     target: self, action: #selector(close))
      if needOnlyExitButton {
        controller.navigationItem.rightBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 17),
                                                                             for: .normal)
        controller.navigationItem.leftBarButtonItems = [UIBarButtonItem(title: nil,
                                                                        style: UIBarButtonItem.Style.plain,
                                                                        target: nil, action: nil)]
      } else {
        controller.navigationItem.rightBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 17),
                                                                             for: .normal)
        controller.navigationItem.leftBarButtonItems = [backButton, forwardButton]
    }
    if controller is SurveyPageViewController {
        if (controller as? SurveyPageViewController)?.surveyManager.currentIndex == 0 {
            backButton.isEnabled = false
        } else {
            backButton.isEnabled = true
        }
    }
    forwardButton.isEnabled = false
   }
      
   @objc func close() {
    NotificationCenter.default.post(name: NSNotification.Name.dismissSurveyPage, object: nil)
   }
      
   @objc func moveToForward() {
    NotificationCenter.default.post(name: NSNotification.Name.initialSurveyStart, object: nil)
   }
      
   @objc func moveToBack() {
    NotificationCenter.default.post(name: NSNotification.Name.moveBackwardSurveyPage, object: nil)
   }
    
   private func getControllerFromStoryBoard(_ storyBoardName: String,
                                            _ storyBoardIdentifier: String) -> UIViewController {
     let storyboard = UIStoryboard.init(name: storyBoardName, bundle: Bundle.main)
     let viewController = storyboard.instantiateViewController(withIdentifier: storyBoardIdentifier)
     return viewController
  }
  
  func destinationViewController(for route: Route) -> UIViewController {
    var viewController: UIViewController!
    switch route {
    case .onboarding(let templateDataArray):
      var viewControllers: [OnboardingViewController] = []
      for (index, item) in templateDataArray.enumerated() {
         viewControllers.append(OnboardingViewController(item: item,
                                                         index: index+1))
      }
      let pageViewController = PageViewController(viewControllers: viewControllers)
      viewController = pageViewController
    case .login:
      let loginVC = LoginViewController()
      viewController = loginVC
    case .signUpOrLogin:
      let signUpOrLoginVC = SignUpOrLoginViewController()
      viewController = signUpOrLoginVC
    case .mainNav:
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            viewController = appDelegate.loggedInViewController()
        }
    case .myData:
      viewController = MyDataViewController()
    case .feed:
      viewController = FeedViewController()
    case .wallet:
      let walletViewController = getControllerFromStoryBoard(Storyboard.walletViewStoryboard.rawValue, StoryBoardIdentifier.walletListViewController.rawValue) as? WalletListViewController
      viewController = walletViewController
    case .settings:
        let settingViewController = getControllerFromStoryBoard(Storyboard.settingViewStoryboard.rawValue, StoryBoardIdentifier.settingViewController.rawValue) as? SettingViewController
        viewController = settingViewController
    case .signup:
        let accountViewController = getControllerFromStoryBoard(Storyboard.signUpViewStoryboard.rawValue, StoryBoardIdentifier.createAccountViewController.rawValue) as? CreateAccountViewController
        viewController = accountViewController
    case .signupDemographics(let surveyManager):
      let surveyPageViewController = SurveyPageViewController(surveyManager: surveyManager, offer: nil)
      viewController = surveyPageViewController
    case .surveyStart(let surveyManager, let surveyScreenType):
        let surveyIntroViewController = SurveyIntroViewController(surveyManager: surveyManager,
                                                                  screenType: surveyScreenType)
      let scrollContainer = ScrollViewController(contentViewController: surveyIntroViewController)
      scrollContainer.scrollView.backgroundColor = Color.lightBackground.value
      viewController = scrollContainer
    case .surveyPage(let surveyManager, let offer):
      let surveyViewController = SurveyPageViewController(surveyManager: surveyManager, offer: offer)
      viewController = surveyViewController
    case .surveyCompletion(let surveyType, let surveyStatus, let delegate,
                           let manager, let videoURL, let externalSurveyMessage,
                           let skipContentValidation, let twitterDetail):
      let completionViewController = SurveyCompletionViewController(surveyType: surveyType, surveyStatus: surveyStatus,
                                                                    surveyManager: manager, videoUrl: videoURL)
      completionViewController.delegate = delegate
      completionViewController.hasSkipContentValidation = skipContentValidation
      completionViewController.externalSurvey = externalSurveyMessage
        completionViewController.twitterDetail = twitterDetail

      let scrollContainer = ScrollViewController(contentViewController: completionViewController)
      viewController = scrollContainer
    case .externalSurveyPage(let offerItem, let nativeOfferBlock, let delegate, let surveyManager):
      let surveyViewController = ExternalSurveyViewController(offerItem: offerItem,
                                                              nativeSurveyBlock: nativeOfferBlock,
                                                              surveyManager: surveyManager)
      surveyViewController.delegate = delegate
      viewController = surveyViewController
    case .cameramanPage(let offerItem, let nativeOfferBlock,
                        let surveyManager, let fileUrl,
                        let photoAsset, let image, let date, let twitterDetail):
        let cameramanViewController = getControllerFromStoryBoard(Storyboard.cameramanSurveyStoryboard.rawValue, StoryBoardIdentifier.cameramanViewController.rawValue) as? CameramanViewController
        cameramanViewController?.offerItem = offerItem
        cameramanViewController?.surveyBlock = nativeOfferBlock
        cameramanViewController?.surveyManager = surveyManager
        cameramanViewController?.fileUrl = fileUrl
        cameramanViewController?.createdDateOfVideo = date
        cameramanViewController?.photoAsset = photoAsset
        cameramanViewController?.selectedImage = image
        cameramanViewController?.twitterDetail = twitterDetail
        viewController = cameramanViewController
    case .cameramanUploadPage(let videoData, let selectedURL, let surveyManager,
                              let offerItem, let screenCaptureType, let skipContent):
        let uploadCompletionViewController = getControllerFromStoryBoard(Storyboard.cameramanSurveyStoryboard.rawValue, StoryBoardIdentifier.uploadCompletionViewController.rawValue) as? UploadCompletionViewController
        uploadCompletionViewController?.selectedVideo = videoData
        uploadCompletionViewController?.videoUrl = selectedURL
        uploadCompletionViewController?.hasSkipContentValidation = skipContent
        uploadCompletionViewController?.surveyManager = surveyManager
        uploadCompletionViewController?.selectedOffer = offerItem
        uploadCompletionViewController?.captureType = screenCaptureType
        viewController = uploadCompletionViewController
    case .datePicker(let date, let datePickerMode, let delegate):
      let datePicker = DatePickerViewController()
      datePicker.datePickerMode = datePickerMode
      datePicker.delegate = delegate
      datePicker.date = date
      viewController = datePicker
    case .notificationPermission:
      let permissionsViewController = NotificationPermissionViewController()
      viewController = permissionsViewController
    case .emailValidation:
      let emailValidationViewController = EmailValidationViewController()
      viewController = emailValidationViewController
    case .phoneNumberValidation:
        viewController = getControllerFromStoryBoard(Storyboard.phoneNumberStoryboard.rawValue,
                                                     Storyboard.phoneNumberStoryboard.rawValue)
    case .otpValidation(let phoneNumber, let delegate):
        let otpController = getControllerFromStoryBoard(Storyboard.phoneNumberStoryboard.rawValue,
                                                        Storyboard.otpValidationStoryboard.rawValue) as? OtpValidationViewController
        otpController?.otpValidationDelegate = delegate
        otpController?.phoneNumber = phoneNumber
        viewController = otpController
    case .dynataDetail(let connectedDynataApp):
        let DynataDetailController = getControllerFromStoryBoard(Storyboard.connectedAppStoryboard.rawValue, StoryBoardIdentifier.dynataDetailController.rawValue) as? ConnectedDynataDetailController
        DynataDetailController?.dynataData = connectedDynataApp
        viewController = DynataDetailController
    case .dataType(let dataType, let connectedAppData):
         let ConnectionDataTypeController = getControllerFromStoryBoard(Storyboard.connectedAppStoryboard.rawValue, StoryBoardIdentifier.connectionDataType.rawValue) as? ConnectionDataTypeController
         ConnectionDataTypeController?.dataType = dataType
         ConnectionDataTypeController?.connectedAppData = connectedAppData
         viewController = ConnectionDataTypeController
    case .connect(let appType, let connectedAppData, let offerItem):
         let connectedAppController = getControllerFromStoryBoard(Storyboard.connectedAppStoryboard.rawValue, StoryBoardIdentifier.connectedAppDetailConnection.rawValue) as? ConnectedAppDetailController
         connectedAppController?.appType = appType
         connectedAppController?.offerItem = offerItem
         connectedAppController?.connectedAppData = connectedAppData
         viewController = connectedAppController
    case .connectionSuccess(let appType):
        let connectionSuccessController = getControllerFromStoryBoard(Storyboard.connectedAppStoryboard.rawValue, StoryBoardIdentifier.connectedAppSuccess.rawValue) as? ConnectedAppSuccessController
        connectionSuccessController?.appType = appType
        viewController = connectionSuccessController
    case .connectionFailure(let appType):
        let connectionFailureController = getControllerFromStoryBoard(Storyboard.connectedAppStoryboard.rawValue, StoryBoardIdentifier.connectedAppFailure.rawValue) as? ConnectedAppFailureController
        connectionFailureController?.appType = appType
        viewController = connectionFailureController
    case .confirmation:
        let confirmController = getControllerFromStoryBoard(Storyboard.phoneNumberStoryboard.rawValue,
                                                            Storyboard.confirmationStoryboard.rawValue) as? ConfirmationViewController
        viewController = confirmController
    case .walletDetail(let connectedApp, let transactionDetail, let transactionId, let isFromNotif):
        let walletDetailController = getControllerFromStoryBoard(Storyboard.walletViewStoryboard.rawValue, StoryBoardIdentifier.walletDetailViewController.rawValue) as? WalletDetailViewController
        walletDetailController?.walletTransactions = transactionDetail
        walletDetailController?.appType = connectedApp
        walletDetailController?.isFromNotification = isFromNotif
        walletDetailController?.transactionId = transactionId
        viewController = walletDetailController
    case .ageRequirementNotMet:
      let ageRequirementNotMetViewController = AgeRequirementNotMetViewController()
      viewController = ageRequirementNotMetViewController
    case .showGiftCards(let option):
      let controller = GiftCardsViewController()
        controller.paymentType = option
      viewController = controller
    case .redeemGiftCard(let type, let paypalEmail, let option, let delegate):
      let identifier = StoryBoardIdentifier.referFriendSuccessController.rawValue
      let controller = getControllerFromStoryBoard(Storyboard.referFriendStoryboard.rawValue,
                                                                identifier) as? ReferFriendSuccessController
        controller?.delegate = delegate
        controller?.redeemOption = option
        controller?.redemptionType = type
        controller?.payPalEmail = paypalEmail
        viewController = controller
    case .passwordReset:
      let controller = PasswordResetViewController()
      viewController = controller
    case .customPopUp(let communitySlug, let communityUserID, let popUpType, let delegate):
        let joinCommunityViewController = JoinCommunityViewController(communitySlug: communitySlug ?? "",
                                                                      communityUserID: communityUserID, popupType: popUpType)
        joinCommunityViewController.popupDelegate = delegate
      viewController = joinCommunityViewController
    case .redeemGenericReward(let balance):
      let redeemGenericRewardViewController = RedeemGenericRewardViewController(balance: balance)
      viewController = redeemGenericRewardViewController
    case .personalEdit:
      let identifier = StoryBoardIdentifier.personalEditViewController.rawValue
      let editViewController = getControllerFromStoryBoard(Storyboard.settingViewStoryboard.rawValue,
                                                              identifier) as? PersonalEditViewController
      viewController = editViewController
    case .changePassword:
        let identifier = StoryBoardIdentifier.changePasswordViewController.rawValue
        let changePasswordController = getControllerFromStoryBoard(Storyboard.settingViewStoryboard.rawValue,
                                                                identifier) as? ChangePasswordViewController
        viewController = changePasswordController
    case .support(let isFromWallet, let transactionId):
        let identifier = StoryBoardIdentifier.supportViewController.rawValue
        let supportController = getControllerFromStoryBoard(Storyboard.settingViewStoryboard.rawValue,
                                                                identifier) as? SupportViewController
        supportController?.isFromWalletDetail = isFromWallet ?? false
        supportController?.transactionId = transactionId
        viewController = supportController
    case .referView(let inviteCode):
        let identifier = StoryBoardIdentifier.referFriendViewController.rawValue
        let referController = getControllerFromStoryBoard(Storyboard.referFriendStoryboard.rawValue,
                                                                identifier) as? ReferViewController
        referController?.inviteCode = inviteCode
        viewController = referController
    case .giftWalletDetail(_, let transactionDetail):
        let identifier = StoryBoardIdentifier.giftWalletDetailController.rawValue
        let giftDetailController = getControllerFromStoryBoard(Storyboard.walletViewStoryboard.rawValue,
                                                               identifier) as? GiftWalletDetailController
        giftDetailController?.walletTransactions = transactionDetail
        viewController = giftDetailController
    case .referWalletDetail(_, _):
        let identifier = StoryBoardIdentifier.referWalletDetailController.rawValue
        let referWalletController = getControllerFromStoryBoard(Storyboard.walletViewStoryboard.rawValue,
                                                               identifier) as? ReferWalletDetailController
        viewController = referWalletController
    case .profileAttributeList:
        let identifier = StoryBoardIdentifier.myAttributeController.rawValue
        let attributeController = getControllerFromStoryBoard(Storyboard.myAttributeStoryboard.rawValue,
                                                               identifier) as? MyAttributeController
        viewController = attributeController
    case .jobExitView(let offerType):
        let identifier = StoryBoardIdentifier.exitJobViewController.rawValue
        let exitJobController = getControllerFromStoryBoard(Storyboard.jobStoryboard.rawValue,
                                                               identifier) as? ExitJobViewController
        exitJobController?.types = offerType
        viewController = exitJobController
    case .retroValidationTest(let validationTestModel):
        let identifier = StoryBoardIdentifier.cameramanTestController.rawValue
        let retroValidationController = getControllerFromStoryBoard(Storyboard.cameramanSurveyStoryboard.rawValue,
                                                               identifier) as? CameramanTestController
        retroValidationController?.testModelData = validationTestModel
        viewController = retroValidationController
    case .retroValidationTestDetail(let validationTestModel):
        let identifier = StoryBoardIdentifier.cameramanDetailTestController.rawValue
        let retroValidationDetailController = getControllerFromStoryBoard(Storyboard.cameramanSurveyStoryboard.rawValue,
                                                               identifier) as? CameramanDetailTestController
        retroValidationDetailController?.testModel = validationTestModel
        viewController = retroValidationDetailController
    case .changeLanguage:
        let identifier = StoryBoardIdentifier.changeLanguageViewController.rawValue
        let supportController = getControllerFromStoryBoard(Storyboard.settingViewStoryboard.rawValue,
                                                                identifier) as? ChangeLanguageViewController
        viewController = supportController
    }
    return viewController
  }
}
