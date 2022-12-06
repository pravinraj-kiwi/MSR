//
//  SurveyPageViewController.swift
//  Contributor
//
//  Created by arvindh on 30/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import ScrollingStackViewController
import UIKit
import os
import Foundation
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults

class SurveyPageViewController: ScrollingStackViewController, SurveyLoadable, SpinnerDisplayable, StaticViewDisplayable {
    var spinnerViewController: SpinnerViewController = SpinnerViewController()
    var staticMessageViewController: FullScreenMessageViewController?
    fileprivate var markAsExistBackgroundTaskRunner: BackgroundTaskRunner!
    
    var surveyManager: SurveyManager
    var selectedOffer: OfferItem?
    var blockContainerViewControllersByBlock: [SurveyBlock: BlockContainerViewController] = [:]
    
    let nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(Text.next.localized(), for: .normal)
        button.titleLabel?.font = Font.regular.of(size: 18)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        return button
    }()
    
    var index: Int = 0
    var task: DispatchWorkItem?
    var errorCountByBlockID: [String:Int] = [:]
    
    init(surveyManager: SurveyManager, offer: OfferItem? = nil) {
        self.surveyManager = surveyManager
        self.selectedOffer = offer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView()
        view.backgroundColor = Constants.backgroundColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prevent downward swiping to dismiss
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        registerForSurveyLoadNotifications()
        
        self.index = surveyManager.currentIndex ?? 0
        
        hideBackButtonTitle()
        setupViews()
        updateUIForSurvey()
    }
    
    func addSurveyObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(moveToNext), name: NSNotification.Name.initialSurveyStart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveToBack), name: NSNotification.Name.moveBackwardSurveyPage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissSurvey), name: NSNotification.Name.dismissSurveyPage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exitFeedJob), name: NSNotification.Name.exitJobFeed, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        surveyManager.goToPage(index, {_ in })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSurveyObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.moveBackwardSurveyPage, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.initialSurveyStart, object: nil)
    }
    
    func updateUIForSurvey() {
        guard let _ = surveyManager.survey else {
            showSpinner()
            return
        }
        
        setupPage()
        setupQuestions()
    }
    
    func willFetchSurvey() {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: self)
            return
        }
        showSpinner()
    }
    
    func didFetchSurvey() {
        hideSpinner()
        updateUIForSurvey()
    }
    
    func didFailToFetchSurvey(_ notification: Notification) {
        hideSpinner()
        let message = MessageHolder(message: Message.genericFetchError)
        show(staticMessage: message)
    }
    
    override func setupViews() {
        scrollView.alwaysBounceVertical = true
        
        nextButton.addTarget(self, action: #selector(self.nextButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        enableOrDisableNextButton()
        
        applyCommunityTheme()
    }
    
    func setupPage() {
        if let _ = surveyManager.survey?.usePageTitles {
            let selectedLanguage = AppLanguageManager.shared.getLanguage()
            if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
                setTitle(surveyManager.currentPage?.titlePt)
                
            } else {
                setTitle(surveyManager.currentPage?.title)
            }
        } else {
            let selectedLanguage = AppLanguageManager.shared.getLanguage()
            if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
                setTitle(surveyManager.survey?.titlePt)
                
            } else {
                setTitle(surveyManager.survey?.title)
            }
        }
    }
    
    func setupQuestions() {
        guard let _ = surveyManager.survey, let currentPage = surveyManager.currentPage else {
            return
        }
        
        for block in currentPage.blocks {
            let blockVC = BlockContainerViewController(block: block)
            blockContainerViewControllersByBlock[block] = blockVC
            blockVC.delegate = self
            if block.blockID != nil {
                blockVC.value = surveyManager.value(forBlock: block)
            }
            
            add(
                viewController: blockVC,
                edgeInsets: UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
            )
            
            // special case code to force a re-validation of postal codes upon loading
            if let blockId = block.blockID, ProfileItemRefs.postalCodeStrings.contains(blockId) {
                blockVC.value = surveyManager.value(forBlock: block)
            }
        }
        
        let buttonWrapperVC = wrapNextButton()
        add(
            viewController: buttonWrapperVC,
            edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        )
    }
    
    func wrapNextButton() -> UIViewController {
        let buttonContainer = UIView()
        buttonContainer.backgroundColor = Constants.backgroundColor
        buttonContainer.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.top.equalTo(buttonContainer)
            make.width.equalTo(190)
            make.height.equalTo(44)
            make.bottom.equalTo(buttonContainer)
            make.centerX.equalTo(buttonContainer)
        }
        
        let wrapper = WrapperViewController(view: buttonContainer)
        return wrapper
    }
    
    func navigateToNextPage() {
        surveyManager.nextPage(offerItem: selectedOffer) { (error) in
            if let error = error {
                switch error {
                case .endReached:
                    self.finish()
                default:
                    break
                }
            } else {
                goToNextPage()
            }
        }
    }
    
    @objc func nextButtonTapped(_ sender: UIButton) {
        navigateToNextPage()
    }
    
    func goToNextPage() {
        if let currentBlock = surveyManager.currentPage?.blocks.filter({$0.blockType == BlockPageType.screenCapture.rawValue}),
           currentBlock.isEmpty == false {
            Router.shared.route(
                to: Route.externalSurveyPage(offerItem: selectedOffer!,
                                             nativeOfferBlock: currentBlock[0],
                                             delegate: self, surveyManager: surveyManager),
                from: self,
                presentationType: .push(surveyToolBarNeeded: true)
            )
        } else {
            Router.shared.route(
                to: Route.surveyPage(surveyManager: surveyManager, offerItem: selectedOffer),
                from: self,
                presentationType: .push(surveyToolBarNeeded: true)
            )
        }
    }
    
    func finish() {
        switch surveyManager.surveyType {
        case .category(category: _):
            Router.shared.route(
                to: Route.surveyCompletion(surveyType: surveyManager.surveyType, surveyStatus: .completed,
                                           delegate: self, surveyManager: surveyManager),
                from: self,
                presentationType: .push(surveyToolBarNeeded: false)
            )
        default:
            handlingNavigationForProfileSurvey()
        }
    }
    func handlingNavigationForProfileSurvey(){
        SurveyCallbackManager.shared.callback(surveyType: surveyManager.surveyType,
                                              callbackType: .completed,
                                              manager: surveyManager,
                                              videoUrl: "", false) { [self] (response, surveyCompletion, error)  in
            if let status = surveyCompletion {
                debugPrint("Survey Result is -- ", status.1, status.0)
                self.navigateToCompleteScreen(externalSurveyCompletion: status.1)
            }
        }
    }
    
    func navigateToCompleteScreen(externalSurveyCompletion: ExternalSurveyCompletion) {
        Router.shared.route(
            to: Route.surveyCompletion(surveyType: surveyManager.surveyType, surveyStatus: .completed,
                                       delegate: self, surveyManager: surveyManager, externalSurveyMessage: externalSurveyCompletion),
            from: self,
            presentationType: PresentationType.push()
        )
    }
}

extension SurveyPageViewController: BlockContainerDelegate {
  func didUpdateValue(_ value: BlockResponseComponent?, forBlock block: SurveyBlock) {
    
    // special case code for validation of postal codes
    if let blockID = block.blockID, ProfileItemRefs.postalCodeStrings.contains(blockID),
       let blockController = blockContainerViewControllersByBlock[block]?.blockViewController as? SingleLineTextBlockViewController {
      
      surveyManager.removeValue(forBlock: block)
      
      if let task = task {
        task.cancel()
      }
      
      var countryUID: String?
      
      // try to get the country UID from the survey
      if let countryUIDFromSurvey = surveyManager.temporaryValues[ProfileItemRefs.country]?.jsonValue as? String {
        countryUID = countryUIDFromSurvey
      } else {
        // if not, fall back to the country in the profile store
        if let profileStore = UserManager.shared.profileStore, let countryUIDFromProfile = profileStore[ProfileItemRefs.country] as? String {
          countryUID = countryUIDFromProfile
        }
      }

      if let countryUID = countryUID, let postalCode = value?.jsonValue as? String {
        
        task = DispatchWorkItem {
          blockController.textField.clearError()
          blockController.textField.showLoading()
            
          if ConnectivityUtils.isConnectedToNetwork() == false {
              Helper.showNoNetworkAlert(controller: self)
              return
          }
                    
          NetworkManager.shared.resolvePostalCode(countryUID: countryUID, postalCode: postalCode) {
            [weak self] profileItemResolutionResponse, error in
            guard let this = self else {
              return
            }
          
            let existingErrorCount = this.errorCountByBlockID[blockID] ?? 0
            let postalCodeLength = postalCode.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").count
            let meetsMinLength = postalCodeLength >= ProfileItemRefs.minPostalCodeLengthByCountryUID[countryUID] ?? 0

            blockController.textField.hideLoading()
            
            if let _ = error {
              os_log("Unknown error resolving postal code", log: OSLog.surveys, type: .error)
                blockController.textField.error = MSRTextfieldValidationError.invalidValue
              if meetsMinLength {
                this.errorCountByBlockID[blockID] = existingErrorCount + 1
              }
            } else {
              
              if let p = profileItemResolutionResponse, !p.found {
                os_log("Entered postal code does not resolve, showing error", log: OSLog.surveys, type: .error)
                blockController.textField.error = MSRTextfieldValidationError.invalidValue
                if meetsMinLength {
                  this.errorCountByBlockID[blockID] = existingErrorCount + 1
                }
              } else {
                // we just take the validation for now, we'll populate the other items later
                this.surveyManager.setTemporaryValue(value, forBlock: block)
                blockController.textField.showValidationCheck()
              }
            }
            
            if !this.surveyManager.canGoToNextPage, let errorCount = this.errorCountByBlockID[blockID], errorCount > 2 {
              this.forceEnableNextButton()
            } else {
              this.enableOrDisableNextButton()
            }
          }
        }
        
        // execute task in 1 second
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task!)
      }
    } else {
        if block.isProfile == false {
            surveyManager.setNonProfileTemporaryValue(value, forBlock: block)
        } else {
            surveyManager.setTemporaryValue(value, forBlock: block)
        }
    }
    enableOrDisableNextButton()
  }
  
  func enableOrDisableNextButton() {
    let canEnable = surveyManager.canGoToNextPage
    nextButton.isEnabled = canEnable
    
    let alpha = canEnable ? 1 : Constants.buttonDisabledAlpha
    nextButton.alpha = alpha
    
    if canEnable {
        nextButton.setTitle(Text.next.localized(), for: .normal)
    }
  }
  
  func forceEnableNextButton() {
    nextButton.isEnabled = true
    nextButton.alpha = 1
    nextButton.setTitle(Text.skipNext.localized(), for: .normal)
  }
}

extension SurveyPageViewController: ExternalSurveyDelegate {
  func externalSurveyDidDismiss() {}
}

extension SurveyPageViewController {

@objc func moveToNext() {
 navigateToNextPage()
}

@objc func moveToBack() {
 self.navigationController?.popViewController(animated: true)
}

@objc func dismissSurvey() {
  if let _ = self.selectedOffer {
    Router.shared.route(
        to: Route.jobExitView(offerType: .internalOffer),
      from: self,
      presentationType: .modal(presentationStyle: .pageSheet, transitionStyle: .coverVertical)
    )
  } else {
    exitCategorySurvey()
  }
}

@objc func exitFeedJob(_ notification: Notification) {
 if let offerItem = self.selectedOffer {
   if let url = offerItem.userTerminatedCallbackURLString {
    if let request = notification.object as? ExitRequestModel {
       self.runExistApi(offerItem: offerItem, url, request: request)
     }
   }
   self.removeNonProfileStore(offerItem)
   let offerInfo: [String: Int] = ["offerID": offerItem.offerID]
   NotificationCenter.default.post(name: NSNotification.Name.surveyFinishedRefreshFeed, object: nil, userInfo: offerInfo)
   self.dismissSelf()
    Defaults.remove(.retroVideoFileSize)
    Defaults.remove(.retroVideoApproxUploadSpeed)
  }
}
    
func exitCategorySurvey() {
 let alerter = Alerter(viewController: self)
    alerter.alert(
        title: Text.exitJob.localized(),
        message: Constants.jobSurveyAlert.localized(),
        confirmButtonTitle: Text.ok.localized(),
        cancelButtonTitle: Text.cancel.localized(),
    onConfirm: {
       self.dismissSelf()
      },
    onCancel: nil
  )
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.profileCategoryExitScreen)
}

func removeNonProfileStore(_ offerItem: OfferItem) {
  if offerItem.sampleRequestType == SampleRequestType.workShopSurvey {
  if let userId = UserManager.shared.user?.userID {
      UserDefaults.standard.removeObject(forKey: "nonProfileStore-\(userId)")
      UserDefaults.standard.removeObject(forKey: Constants.nonProfileTempKey)
    if let profileStore = surveyManager.networkManager.userManager?.profileStore {
        profileStore.removeNonProfileValue(forKey: profileStore.nonProfileKey)
    }
    }
  }
}
    
func getParameters(_ offerItem: OfferItem,
                   _ request: ExitRequestModel) -> [String: Any] {
    
    let modelName = UIDevice.modelName
    let iosVersion = UIDevice.current.systemVersion
    var parameters: [String: Any] = [:]
    if request.reasonType != "other" {
        parameters = ["srid": offerItem.sampleRequestID! as Any,
            "cid": UserManager.shared.user!.userID! as Any,
            "user_termination_reason": request.reasonType]
    } else {
        parameters = ["srid": offerItem.sampleRequestID! as Any,
            "cid": UserManager.shared.user!.userID! as Any,
            "user_termination_reason": request.reasonType,
            "user_termination_other_details": request.reasonStr]
    }
    parameters.updateValue("\(modelName) OS Version : \(iosVersion)", forKey: "device_model")
    parameters.updateValue("iOS", forKey: "device_type")
    if request.retroVideoSize.isEmpty == false {
        parameters.updateValue(request.retroVideoSize,
                               forKey: "retro_file_size_mb")
    }
    if request.approxUploadSpeed.isEmpty == false {
        parameters.updateValue(request.approxUploadSpeed,
                               forKey: "approx_upload_speed_mbps")
    }
    return parameters
}

func runExistApi(offerItem: OfferItem, _ url: String, request: ExitRequestModel) {
    self.markAsExistBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
    self.markAsExistBackgroundTaskRunner.startTask {
       if ConnectivityUtils.isConnectedToNetwork() == false {
           Helper.showNoNetworkAlert(controller: self)
           return
       }
      Alamofire.request(url, method: .post,
                        parameters: getParameters(offerItem, request),
                        encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
            switch response.result {
            case .failure(_): break
            default:
              break
          }
         self.markAsExistBackgroundTaskRunner.endTask()
        }
     }
  }
}

extension SurveyPageViewController: MessageViewControllerDelegate {
  func didTapActionButton() {
    hideStaticMessage()
    surveyManager.fetchSurveyAndStart({ _ in })
  }
}

extension SurveyPageViewController: SurveyCompletionDelegate {
  func didCompleteSurvey(_ surveyManager: SurveyManager?) {
    NotificationCenter.default.post(name: NSNotification.Name.balanceChanged, object: nil)
    if surveyManager?.survey?.category != nil {
        NotificationCenter.default.post(name: NSNotification.Name.animateCategory,
                                        object: surveyManager?.survey?.category)
     }
    NotificationCenter.default.post(name: NSNotification.Name.updateAttributeSection, object: nil)
  }
}

extension SurveyPageViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity,
          let colors = community.colors else {
      return
    }
    
    nextButton.setDarkeningBackgroundColor(color: colors.primary)
    nextButton.setTitleColor(colors.whiteText, for: .normal)
  }
}
