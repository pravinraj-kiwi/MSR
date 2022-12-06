//
//  ExternalSurveyViewController.swift
//  Contributor
//
//  Created by arvindh on 28/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import WebKit
import Alamofire
import SwiftyJSON
import Photos
import PhotosUI
import SwiftyUserDefaults
import JavaScriptCore
import Foundation

protocol ExternalSurveyDelegate: class {
    func externalSurveyDidDismiss()
}

enum WebviewMessage: String {
    case htmlLoaded
}

class ExternalSurveyViewController: WebContentViewController {
    weak var delegate: ExternalSurveyDelegate?
    var offerItem: OfferItem
    var surveyBlock: SurveyBlock?
    var surveyManager: SurveyManager?
    var externalSurveyManager: ExternalSurveyManager
    fileprivate var markAsExternalExistBackgroundTaskRunner: BackgroundTaskRunner!
    let gallery = GalleryPicker()
    var surveyStatus: [SurveyStatus: ExternalSurveyCompletion] = [:] {
        didSet {
            didSetSurveyStatus(surveyStatus.keys.first ?? .inProgress, eventMessages: surveyStatus.values.first)
        }
    }
    
    init(offerItem: OfferItem, nativeSurveyBlock: SurveyBlock?, surveyManager: SurveyManager?) {
        self.offerItem = offerItem
        self.surveyBlock = nativeSurveyBlock
        self.surveyManager = surveyManager
        self.externalSurveyManager = ExternalSurveyManager(offerItem: offerItem)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var surveyMonitorResponse = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prevent downward swiping to dismiss
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        setTitle(Text.survey.localized())
        hideBackButtonTitle()
        loadSurvey()
        NotificationCenter.default.addObserver(self, selector: #selector(callExitApi),
                                               name: NSNotification.Name.exitExternalSurvey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openWalletDetail),
                                               name: NSNotification.Name.paymentDetail, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uploadAgain),
                                               name: NSNotification.Name.uploadFailed, object: nil)
          if offerItem.javaScriptSurveyMonitorEnabled {
              self.loadGFKUrl()
          }
    }
    
    @objc func openWalletDetail(_ notification: Notification) {
        guard let transactionID = notification.userInfo?["transactionID"] as? Int else {
            return
        }
        Router.shared.route(
            to: Route.walletDetail(nil, nil, transactionID, isFromNotif: true),
            from: self,
            presentationType: .modal(presentationStyle: .formSheet, transitionStyle: .coverVertical)
        )
    }
    
    override func setupWebview() {
        let config = WKWebViewConfiguration()
        
        do {
            let scriptURL = Bundle.main.url(forResource: "externalSurvey", withExtension: "js")
            let jsScript = try String(contentsOf: scriptURL!, encoding: String.Encoding.utf8)
            
            let userScript = WKUserScript(source: jsScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            config.userContentController.addUserScript(userScript)
            config.userContentController.add(self, name: WebviewMessage.htmlLoaded.rawValue)
        }
        catch {
            os_log("Error configuring user scrips for web view.", log: OSLog.surveys, type: .error)
        }
        
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.externalSurveyDidDismiss()
        UserManager.shared.currentlyTakingExternalSurvey = false
    }
    
    func loadSurvey() {
        let profileStore = UserManager.shared.profileStore!
        
        guard var c = URLComponents(string: offerItem.urlString) else {
            os_log("Problem creating URL for the offer", log: OSLog.surveys, type: .error)
            return
        }
        
        var countryCode = ""
        if let countryUID = profileStore[ProfileItemRefs.country] as? String {
            countryCode = CountryCodeLookup[countryUID] ?? ""
        }
        
        if c.queryItems == nil {
            c.queryItems = []
        }
        
        if offerItem.appendIdentifiers {
            c.queryItems!.append(contentsOf: [
                URLQueryItem(name: "cid", value: String(UserManager.shared.user!.userID!)),
                URLQueryItem(name: "srid", value: String(offerItem.sampleRequestID!)),
            ])
        }
        
        if offerItem.appendProfileItems {
            
            // postal code
            if let countryUID = profileStore[ProfileItemRefs.country] as? String {
                if let r = ProfileItemRefs.postalCodeStringRefByCountryUID[countryUID], let p = profileStore[r] as? String {
                    c.queryItems!.append(URLQueryItem(name: "postal_code", value: p))
                }
            }
            
            let updatedAge = profileStore.updateAgeFromDOB()
            c.queryItems!.append(contentsOf: [
                URLQueryItem(name: "income_us", value: profileStore[ProfileItemRefs.incomeUS] as? String),
                URLQueryItem(name: "income_uk", value: profileStore[ProfileItemRefs.incomeUK] as? String),
                URLQueryItem(name: "income_ca", value: profileStore[ProfileItemRefs.incomeCA] as? String),
                URLQueryItem(name: "income_au", value: profileStore[ProfileItemRefs.incomeAU] as? String),
                URLQueryItem(name: "gender", value: profileStore[ProfileItemRefs.gender] as? String),
                URLQueryItem(name: "age", value: updatedAge != nil ? updatedAge!.description : nil),
                URLQueryItem(name: "dob", value: profileStore[ProfileItemRefs.dob] as? String),
                URLQueryItem(name: "education", value: profileStore[ProfileItemRefs.education] as? String),
                URLQueryItem(name: "country", value: countryCode),
                URLQueryItem(name: "employment", value: profileStore[ProfileItemRefs.employment] as? String),
            ])
        }
        
        // special purpose hack to pass the correctly mapped demos for R4G surveys
        if offerItem.urlString.contains("r4g=1") {
            
            if let countryUID = profileStore[ProfileItemRefs.country] as? String {
                
                // country
                c.queryItems!.append(URLQueryItem(name: "country", value: countryCode))
                
                // postal code
                if let r = ProfileItemRefs.postalCodeStringRefByCountryUID[countryUID], let p = profileStore[r] as? String {
                    c.queryItems!.append(URLQueryItem(name: "postalCode", value: p))
                }
            }
            
            // gender
            let genderLookup = [
                "female": "f",
                "male": "m",
                "non_binary": "n",
                "other": "o"
            ]
            
            if let v = profileStore[ProfileItemRefs.gender] as? String, let g = genderLookup[v] {
                c.queryItems!.append(URLQueryItem(name: "gender", value: g))
            }
            
            // DOB
            if let d = profileStore[ProfileItemRefs.dob] as? String {
                c.queryItems!.append(URLQueryItem(name: "birthday", value: d))
            }
        }
        if offerItem.sampleRequestType == SampleRequestType.workShopSurvey {
            let selectedLanguage = AppLanguageManager.shared.getLanguage()
            if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
                if let urlString = surveyBlock?.screenCaptureBlock?.instructionsPt {
                    goToUrl(urlString: urlString)
                } else {
                    if let urlString = surveyBlock?.screenCaptureBlock?.instructions {
                        goToUrl(urlString: urlString)
                    }
                }
            } else {
                if let urlString = surveyBlock?.screenCaptureBlock?.instructions {
                    goToUrl(urlString: urlString)
                }
            }
        } else {
            goToUrl(url: c.url!)
        }
    }
    
    func didSetSurveyStatus(_ status: SurveyStatus,
                            eventMessages: ExternalSurveyCompletion?) {
        switch status {
        case .completed, .disqualified, .overQuota, .inReview:
            Router.shared.route(
                to: Route.surveyCompletion(surveyType: .externalOffer(offerItem: offerItem),
                                           surveyStatus: status, delegate: self, externalSurveyMessage: eventMessages),
                from: self,
                presentationType: PresentationType.push()
            )
            
        case .cancelled:
            NotificationCenter.default.post(name: NSNotification.Name.exitExternalSurvey, object: nil)
        default:
            break
        }
    }
    
    @objc func uploadAgain() {
        webView.evaluateJavaScript("sendMeasureMessage('uncheckFinishedCheckbox','{};')", completionHandler: nil)
    }
    
    @objc func callExitApi(_ notification: Notification) {
        if let url = offerItem.userTerminatedCallbackURLString {
            if let request = notification.object as? ExitRequestModel {
                self.runExistApi(offerItem: offerItem, url, request: request)
            }
        }
        self.removeNonProfileStore(offerItem)
        let offerInfo: [String: Int] = ["offerID": offerItem.offerID]
        NotificationCenter.default.post(name: NSNotification.Name.surveyFinishedRefreshFeed,
                                        object: nil, userInfo: offerInfo)
        self.dismissSelf()
        Defaults.remove(.retroVideoFileSize)
        Defaults.remove(.retroVideoApproxUploadSpeed)
    }
    
    func removeNonProfileStore(_ offerItem: OfferItem) {
        if offerItem.sampleRequestType == SampleRequestType.workShopSurvey {
            if let userId = UserManager.shared.user?.userID {
                UserDefaults.standard.removeObject(forKey: "nonProfileStore-\(userId)")
                UserDefaults.standard.removeObject(forKey: Constants.nonProfileTempKey)
                if let profileStore = surveyManager?.networkManager.userManager?.profileStore {
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
        self.markAsExternalExistBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
        self.markAsExternalExistBackgroundTaskRunner.startTask {
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
                    self.markAsExternalExistBackgroundTaskRunner.endTask()
                }
        }
    }
}

extension ExternalSurveyViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if #available(iOS 13, *) {
            webView.evaluateJavaScript("sendMeasureMessage('uncheckFinishedCheckbox','{};')", completionHandler: nil)
        }
    }
}

extension ExternalSurveyViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == WebviewMessage.htmlLoaded.rawValue {
            guard let html = message.body as? String else {
                return
            }
            let retriveData = externalSurveyManager.checkSurveyStatus(html: html)
            surveyStatus = [retriveData.0: retriveData.1]
        }
    }
    
    func moveToUploadVideo(_ uploadURL: URL? = nil, asset: PHAsset? = nil,
                           image: UIImage? = nil, _ creationDate: Date? = nil) {
        activityIndicator.updateIndicatorView(self, hidden: true)
        var showExitButtonOnly = true
        if let index = surveyManager?.currentIndex, index > 0,
           let currentBlock = surveyManager?.currentPage?.blocks.filter({$0.blockType == BlockPageType.screenCapture.rawValue}),
           currentBlock.isEmpty == false {
            showExitButtonOnly = false
        }
        Router.shared.route(
            to: Route.cameramanPage(offerItem: offerItem, nativeOfferBlock: surveyBlock,
                                    surveyManager: surveyManager, uploadURL: uploadURL,
                                    asset: asset, image: image, date: creationDate),
            from: self,
            presentationType: .push(surveyToolBarNeeded: true, needOnlyExitButton: showExitButtonOnly)
        )
    }
    
    func getNoUploadError() -> String {
        switch surveyBlock?.screenCaptureBlock?.dataFormat {
        case .image:
            return ImageUpload.noImagesSaved.localized()
        case .video:
            return VideoUpload.noRecordingSaved.localized()
        case .file:
            return FileUpload.noFileSaved.localized()
        default: break
        }
        return ""
    }
    
    func openFileApp() {
        let documentsPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentsPicker.delegate = self
        documentsPicker.allowsMultipleSelection = false
        present(documentsPicker, animated: true, completion: nil)
    }
}

extension ExternalSurveyViewController {
    func showLimitedPhotoAlert() {
        let alerter = Alerter(viewController: self)
        alerter.alert(title: PhotoPermissionAlertText.title.localized(), message: PhotoPermissionAlertText.message.localized(),
                      confirmButtonTitle: PhotoPermissionAlertText.settings.localized(),
                      cancelButtonTitle: Text.cancel.localized(),
                      confirmButtonStyle: .default, onConfirm: {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                      }, onCancel: {
                        self.webView.evaluateJavaScript("sendMeasureMessage('uncheckFinishedCheckbox','{};')", completionHandler: nil)
                      })
    }
}

extension ExternalSurveyViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        moveToUploadVideo(urls[0])
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("URL: \(url)")
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        webView.evaluateJavaScript("sendMeasureMessage('uncheckFinishedCheckbox','{};')", completionHandler: nil)
    }
}

extension ExternalSurveyViewController: WKUIDelegate {
    
    override func webView(_ webView: WKWebView,
                          decidePolicyFor navigationAction: WKNavigationAction,
                          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let clickedUrl = navigationAction.request.url?.absoluteString,
           clickedUrl == Constants.finishRecordingButtonUrl {
            guard let captureType = surveyBlock?.screenCaptureBlock?.dataFormat else { return }
            switch captureType {
            case .video:
                PHPhotoLibrary.execute(controller: self, onAccessHasBeenGranted: {
                    self.gallery.openGallery(captureType: .video, ctrl: self)
                }, onAccessHasBeenLimited: {self.showLimitedPhotoAlert()})
            case .image:
                PHPhotoLibrary.execute(controller: self, onAccessHasBeenGranted: {
                    self.gallery.openGallery(captureType: .image, ctrl: self)
                }, onAccessHasBeenLimited: {self.showLimitedPhotoAlert()})
            case .file:
                openFileApp()
            }
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        if let clickedUrl = navigationAction.request.url?.absoluteString,
           clickedUrl == Constants.twitterButtonUrl {
            self.twitterLogin()
           // return
        }
        guard let url = navigationAction.request.url else {
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        let status = externalSurveyManager.checkSurveyStatus(url: url).0
        let message = externalSurveyManager.checkSurveyStatus(url: url).1
        if [.completed, .disqualified, .overQuota, .cancelled, .inReview].contains(status) {
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
        else if status == .inProgress {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
        
        surveyStatus = [status: message]
    }
    func twitterLogin() {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: self)
            self.activityIndicator.updateIndicatorView(self, hidden: true)
            self.webView.evaluateJavaScript("sendMeasureMessage('showUpload','{};')", completionHandler: nil)
            return
        }
          TRTwitterHelper().twitterLoginRequest(viewcontroller: self) { [weak self] (twitterLoginStatus)  in
              switch twitterLoginStatus {
              case .success(let user):
                var param = [String: Any]()
                  param["user_access_token"] = user.authToken ?? ""
                  param["user_secret_key"] =  user.authTokenSecret ?? ""
                param["twitter_user_id"] = user.userID ?? ""
                self?.moveToUploadingPage(param: param)
              case .cancelled:
                  debugPrint("user cancelled twitter login>>>")
                self?.webView.evaluateJavaScript("sendMeasureMessage('showUpload','{};')", completionHandler: nil)
                self?.moveToUploadingPage()
              case .error:
                debugPrint("twitter error>>>")
                self?.webView.evaluateJavaScript("sendMeasureMessage('showUpload','{};')", completionHandler: nil)
                self?.moveToUploadingPage()
              }
          }
    }
    func moveToUploadingPage(param: [String: Any]? = nil) {
        activityIndicator.updateIndicatorView(self, hidden: true)
        Router.shared.route(
            to: Route.cameramanPage(offerItem: offerItem,
                                    nativeOfferBlock: surveyBlock,
                                    surveyManager: surveyManager,
                                    uploadURL: nil,
                                    asset: nil,
                                    image: nil,
                                    date: nil,
                                    twitterDetail: param),
            from: self,
            presentationType: .push(surveyToolBarNeeded: true, needOnlyExitButton: true)
        )
    }
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let currentBlock = surveyManager?.currentPage?.blocks.filter({$0.blockType == BlockPageType.screenCapture.rawValue}),
           currentBlock.isEmpty == false, let index = surveyManager?.currentIndex, index > 0 {
            self.navigationItem.leftBarButtonItems?[0].isEnabled = true
        } else {
            if webView.canGoBack {
                self.navigationItem.leftBarButtonItems?[0].isEnabled = true
            } else {
                self.navigationItem.leftBarButtonItems?[0].isEnabled = false
            }
        }
        if offerItem.javaScriptSurveyMonitorEnabled {
            self.injectScript(str: self.surveyMonitorResponse)
        }
        activityIndicator.updateIndicatorView(self, hidden: true)
      
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame,
           frame.isMainFrame {
            return nil
        }
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return nil
    }
}

extension ExternalSurveyViewController: SurveyCompletionDelegate {
    func didCompleteSurvey(_ surveyManager: SurveyManager?) {
        NotificationCenter.default.post(name: NSNotification.Name.balanceChanged, object: nil)
    }
}

extension ExternalSurveyViewController {
    
    override func moveToBack() {
        if let currentBlock = surveyManager?.currentPage?.blocks.filter({$0.blockType == BlockPageType.screenCapture.rawValue}),
           currentBlock.isEmpty == false {
            self.navigationController?.popViewController(animated: true)
        } else {
            if webView.canGoBack {
                webView.goBack()
            }
        }
    }
    func loadGFKUrl() {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: self)
            return
        }
        guard let url = offerItem.javaScriptMonitorURL else {return}
        Alamofire.request(url).responseString { (response) in
            switch response.result {
            case .failure(let error):
                debugPrint("Failure>>>", error.localizedDescription)
            case . success(let response):
                debugPrint("Success")
                self.surveyMonitorResponse = response
            }
        }
    }
    func injectScript(str: String) {
        let utf8EncodeData = str.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let base64String = utf8EncodeData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: UInt(0))) ?? ""
        let script = """
                            var script = document.createElement('script');\
                            script.type = 'text/javascript';\
                            script.innerHTML = window.atob('\(base64String)');\
                            document.getElementsByTagName('head')[0].appendChild(script);
                            """
        debugPrint("Script is >>>>", script)
        
        webView.evaluateJavaScript(script) { (response, error) in
            if error != nil {
                debugPrint("Error is ", error ?? "")
            }
            self.callScriptFunction()
        }
    }
    func callScriptFunction() {
        let param = "(\(offerItem.sampleRequestID!), \(UserManager.shared.user!.userID!));"
        let funcStr = "\(String(describing: offerItem.javaScriptSurveyMonitorJavaScriptFunction ?? ""))" + param
        debugPrint("Function called is >>>>", funcStr)
        webView.evaluateJavaScript(funcStr) { (response, error) in
            
            if let resp = response as? [String: Any] {
                debugPrint("Response is >>>>", resp)
                if resp.keys.count > 0 {
                    let requestDict = self.getParams(dict: resp)
                    self.submitGFKScriptResponseAPI(parameters: requestDict)
                }
            }
            if error != nil {
                debugPrint("Error is ", error ?? "")
            }
        }
    }
    func getParams(dict: Parameters) -> Parameters {
        var responseDict : Parameters = [:]
        for (key, value) in dict {
            print("Dictionary key \(key) - Dictionary value \(value)")
            responseDict[key] = value
        }
        return responseDict
    }
    func submitGFKScriptResponseAPI(parameters: Parameters) {
        guard let guid = offerItem.offerGUID else {return}
        let path = "/v1/offers/\(guid)/javascript-props"
        let url = Constants.baseContributorAPIURL.appendingPathComponent(path)
        Alamofire.request(url, method: .post, parameters: parameters,
                          encoding: JSONEncoding.default, headers: Helper.getRequestHeader())
            .validate()
            .responseJSON {  [weak self] response in
                guard let _ = self else {return}
                switch response.result {
                case .failure(let error):
                    debugPrint("Failure>>>", error)
                case . success(let response):
                    debugPrint("Success", response)
                }
                
            }
    }
}

