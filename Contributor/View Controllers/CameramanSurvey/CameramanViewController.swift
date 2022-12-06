//
//  CameramanViewController.swift
//  Contributor
//
//  Created by KiwiTech on 7/7/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Photos
import SwiftyAttributes
import SwiftyUserDefaults
import AWSS3

class CameramanViewController: UIViewController {
    weak var timer: Timer?
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var surveyImageView: UIImageView!
    @IBOutlet weak var recentVideoView: UIView!
    @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet weak var confirmUploadButton: UIButton!
    @IBOutlet weak var recentVideoImageView: UIImageView!
    @IBOutlet weak var recentVideoTitle: UILabel!
    @IBOutlet weak var recentVideoDate: UILabel!
    @IBOutlet weak var recentVideoSize: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorHeaderLabel: UILabel!
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var twitterInfoView: UIView!
    @IBOutlet weak var twitterDetailTitle: UILabel!
    @IBOutlet weak var twitterDetailSubTitle: UILabel!
    
    
    var offerItem: OfferItem?
    var surveyBlock: SurveyBlock?
    var surveyManager: SurveyManager?
    var testModel: CameraTestModel?
    var retroValidationArray = [CameramanTestModel]()
    var selectedVideoURL: URL?
    let imagePicker = UIImagePickerController()
    var selectedDateTime: Date?
    var createdDateOfVideo: Date?
    var fileUrl: URL?
    var photoAsset: PHAsset?
    var selectedImage: UIImage?
    let gallery = GalleryPicker()
    var hasSkipContentValidation = false
    let serverDateFormat = DateFormatType.serverDateFormat.rawValue
    let shortDateFormat = DateFormatType.shortDateFormat.rawValue
    let shortStyleFormat = DateFormatType.shortStyleFormat.rawValue
    let initialSurveyNotif = NSNotification.Name.initialSurveyStart
    let backwardSurveyNotif = NSNotification.Name.moveBackwardSurveyPage
    var twitterDetail: [String: Any]?
    var surveyStatus: [SurveyStatus: ExternalSurveyCompletion] = [:] {
        didSet {
            didSetSurveyStatus(surveyStatus.keys.first ?? .inProgress, eventMessages: surveyStatus.values.first)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        updateInitialUI()
    }
    
    func addSurveyObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(moveToNext),
                                               name: initialSurveyNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveToBack),
                                               name: backwardSurveyNotif, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSurveyObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: backwardSurveyNotif, object: nil)
        NotificationCenter.default.removeObserver(self, name: initialSurveyNotif, object: nil)
    }
    
    func updateInitialUI() {
        errorHeaderLabel.text = Text.oopsText.localized()
        self.baseView.isHidden = true
        applyCommunityTheme()
        if let surveyLogoUrl = surveyBlock?.screenCaptureBlock?.dataTypeLogoUrl {
            surveyImageView.setImageWithAssetOrURL(with: surveyLogoUrl)
        }
        if let currentBlock = surveyManager?.currentPage?.blocks.filter({$0.blockType == BlockPageType.oAuthCapture.rawValue}),
           currentBlock.isEmpty == false {
           // twitterInfoView.viewShadow(color: .clear)
            activityIndicator.updateIndicatorView(self, hidden: true)
            self.baseView.isHidden = false
            recentVideoView.isHidden = true
            uploadPhotoButton.isHidden = true
            confirmUploadButton.isHidden = false
            errorView.isHidden = true
            setTwitterInfo()
            return
        }
        recentVideoView.isHidden = false
        errorView.isHidden = false
        recentVideoView.viewShadow(color: .black)
        activityIndicator.updateIndicatorView(self, hidden: false)
        switch surveyBlock?.screenCaptureBlock?.dataFormat {
        case .image: getLatestMedia(.image)
        case .video: getLatestMedia(.video)
        case .file: getLatestMedia(.file)
        default: break
        }
        guard let type = surveyBlock?.screenCaptureBlock?.dataFormat else { return }
        updateErrorView(shouldShowError: false, captureType: type)
    }
    func setTwitterInfo() {
        if let _ = self.twitterDetail {
            twitterDetailTitle.text = Text.twitterAuthorized.localized()
            twitterDetailSubTitle.text = Text.twitterInfo.localized()
            confirmUploadButton.setTitle(Text.finishText.localized(), for: .normal)
            
        } else {
            twitterDetailTitle.text = Text.twitterFail.localized()
            twitterDetailSubTitle.text = Text.twitterInstruction.localized()
            twitterDetailTitle.textColor = Utilities.hexStringToUIColor(hex: "#ff3b30")
            confirmUploadButton.setTitle(Cameraman.uploadTryAgain.localized(), for: .normal)
        }
    }

    func getLatestMedia(_ screenCaptureType: ScreenCaptureType) {
        self.activityIndicator.updateIndicatorView(self, hidden: true)
        self.baseView.isHidden = false
        switch screenCaptureType {
        case .image:
            self.updateUI(.image, asset: photoAsset, uploadURL: fileUrl,
                          date: photoAsset?.creationDate, image: selectedImage)
        case .video:
            self.updateUI(.video, asset: photoAsset,
                          uploadURL: fileUrl, date: createdDateOfVideo)
        default:
            guard let attributes = try? fileUrl?.resourceValues(forKeys: [.contentModificationDateKey, .nameKey])
            else { return }
            self.updateUI(screenCaptureType, uploadURL: fileUrl, date: attributes.contentModificationDate,
                          fileName: attributes.name ?? fileUrl?.lastPathComponent ?? "")
        }
    }
    
    func configureAWS(_ response: MediaUploadResponse) {
        if let accessKey = response.awsKeyId, let secretKey = response.awsSecret {
            let acceleratedKey = Constants.transferUtilityAcceleratedKey
            let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey,
                                                                   secretKey: secretKey)
            if let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1,
                                                           credentialsProvider: credentialsProvider) {
                AWSServiceManager.default().defaultServiceConfiguration = configuration
                let transferConfiguration = AWSS3TransferUtilityConfiguration()
                transferConfiguration.isAccelerateModeEnabled = true
                AWSS3TransferUtility.register(with: configuration,
                                              transferUtilityConfiguration: transferConfiguration,
                                              forKey: acceleratedKey)
            }
        }
    }
    
    func openFileApp() {
        let documentsPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentsPicker.delegate = self
        documentsPicker.allowsMultipleSelection = false
        present(documentsPicker, animated: true, completion: nil)
    }
    
    func showLimitedPhotoAlert() {
        let alerter = Alerter(viewController: self)
        alerter.alert(title: PhotoPermissionAlertText.title.localized(),
                      message: PhotoPermissionAlertText.message.localized(),
                      confirmButtonTitle: PhotoPermissionAlertText.settings.localized(),
                      cancelButtonTitle: Text.cancel.localized(),
                      confirmButtonStyle: .default, onConfirm: {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                      }, onCancel: nil)
    }
    
    @IBAction func clickToOpenPhotoGallery(_ sender: Any) {
        switch surveyBlock?.screenCaptureBlock?.dataFormat {
        case .image:
            PHPhotoLibrary.execute(controller: self) {
                self.gallery.openGallery(captureType: .image, ctrl: self)
            } onAccessHasBeenLimited: {
                self.showLimitedPhotoAlert()
            }
        case .video:
            PHPhotoLibrary.execute(controller: self) {
                self.gallery.openGallery(captureType: .video, ctrl: self)
            } onAccessHasBeenLimited: {
                self.showLimitedPhotoAlert()
            }
        case .file: openFileApp()
        default: break
        }
    }
    func finish() {
        guard let surveyType = surveyManager?.surveyType else { return }
        SurveyCallbackManager.shared.callback(surveyType: surveyType,
                                              callbackType: .completed,
                                              manager: surveyManager,
                                              twitterDetails: twitterDetail) { (response, surveyCompletion, error)  in
            debugPrint("Survey Result is ", response)
            self.confirmUploadButton.isEnabled = true
            if let status = surveyCompletion {
                self.surveyStatus = [status.0: status.1]
            } else {
                self.navigateToSurveyCompletion(surveyStatus: .completed)
            }
        }
    }
    func didSetSurveyStatus(_ status: SurveyStatus,
                            eventMessages: ExternalSurveyCompletion?) {
        guard let surveyType = surveyManager?.surveyType else { return }
        switch status {
        case .completed, .disqualified, .overQuota, .inReview:
            Router.shared.route(
                to: Route.surveyCompletion(surveyType: surveyType,
                                           surveyStatus: status,
                                           delegate: self,
                                           externalSurveyMessage: eventMessages),
                from: self,
                presentationType: PresentationType.push()
            )
            
        case .cancelled:
            self.navigateToSurveyCompletion(surveyStatus: status)
        default:
            break
        }
    }
    func navigateToSurveyCompletionWithStatus(status: SurveyStatus,
                                              eventMessages: ExternalSurveyCompletion?,
                                              surveyType: SurveyType) {
        switch status {
        case .completed, .disqualified, .overQuota, .inReview:
            Router.shared.route(
                to: Route.surveyCompletion(surveyType: surveyType,
                                           surveyStatus: status,
                                           delegate: self,
                                           externalSurveyMessage: eventMessages),
                from: self,
                presentationType: PresentationType.push()
            )
            
        case .cancelled:
            self.navigateToSurveyCompletion(surveyStatus: status)
        default:
            break
        }
    }
    func navigateToSurveyCompletion(surveyStatus: SurveyStatus) {
        guard let surveyType = surveyManager?.surveyType else { return }
        Router.shared.route(
            to: Route.surveyCompletion(surveyType: surveyType,
                                       surveyStatus: surveyStatus,
                                       delegate: self,
                                       surveyManager: surveyManager,
                                       videoUrl: nil,
                                       hasSkipContentValidation: false,
                                       twitterDetail: twitterDetail),
            from: self,
            presentationType: .push(surveyToolBarNeeded: false)
        )
    }
    @IBAction func clickToUploadVideo(_ sender: Any) {
        confirmUploadButton.isEnabled = false
        if confirmUploadButton.currentTitle == Cameraman.uploadTryAgain.localized() {
            self.navigationController?.popViewController(animated: true)
            if let currentBlock = surveyManager?.currentPage?.blocks.filter({$0.blockType == BlockPageType.oAuthCapture.rawValue}),
               currentBlock.isEmpty == false {
                self.confirmUploadButton.isEnabled = true

                return
            }
            NotificationCenter.default.post(name: .uploadFailed, object: nil, userInfo: nil)
            self.confirmUploadButton.isEnabled = true
            return
        }
        if let currentBlock = surveyManager?.currentPage?.blocks.filter({$0.blockType == BlockPageType.oAuthCapture.rawValue}),
           currentBlock.isEmpty == false {
            self.finish()
            return
        }
        self.confirmUploadButton.isEnabled = true
        guard let url = selectedVideoURL else { return }
        switch surveyBlock?.screenCaptureBlock?.dataFormat {
        case .image:
            if isRecentFile() == false {
                return
            }
            var size = url.filesize ?? 0
            if let asset = photoAsset {
                size = Int(getImageSize(asset))
            }
            if isVideoFileSizeCorrect(fileSize: size) == false {
                return
            }
            callMediaUploadingAPI(url)
        case .file:
            if isRecentFile() == false {
                return
            }
            if let size = url.filesize,
               isVideoFileSizeCorrect(fileSize: size) == false {
                return
            }
            callMediaUploadingAPI(url)
        case .video:
            if isRecentFile() == false {
                return
            }
            if let size = url.filesize,
               isVideoFileSizeCorrect(fileSize: size) == false {
                return
            }
            isVideoContainedText { (hasText, hasNegativeMarkers) in
                if (hasText && (hasNegativeMarkers == false)) {
                    if UserManager.shared.user?.isTestUser == true {
                        self.updateUIIfTestPassed()
                        return
                    }
                    self.callMediaUploadingAPI(url)
                }
            }
        default: break
        }
    }
    
    func updateUIIfTestPassed() {
        errorView.isHidden = false
        errorHeaderLabel.isHidden = true
        errorImageView.isHidden = true
        let message = Cameraman.testPassed.localized()
        let attributedText = message.withFont(Font.italic.of(size: 15))
        let linkFontAttributes = [
            Attribute.textColor(.blue),
            Attribute.underlineColor(.blue),
            Attribute.underlineStyle(.single)
        ]
        attributedText.addAttributesToTerms(linkFontAttributes,
                                            to: [Text.seeResult.localized(), Text.here.localized()])
        errorLabel.attributedText = attributedText
        addTapGestureOnLabel()
    }
    
    func addTapGestureOnLabel() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(clickToMoveToUpload(tap:)))
        errorLabel.addGestureRecognizer(tap)
        errorLabel.isUserInteractionEnabled = true
    }
    
    func uploadNonCompressedVideo() {
        hasSkipContentValidation = true
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: self)
            return
        }
        guard let url = selectedVideoURL else {
            showErrorIfMediaResponseFail()
            return
        }
        if UserManager.shared.user?.isTestUser == true {
            Utilities.clearAllDataFrom(folderName: Constants.framePath)
        }
        callMediaUploadingAPI(url)
    }
    
    @objc func clickToMoveToUpload(tap: UITapGestureRecognizer) {
        if let range = errorLabel.text?.range(of: Text.here.localized())?.nsRange {
            if tap.didTapAttributedTextInLabel(label: errorLabel,
                                               inRange: range) {
                uploadNonCompressedVideo()
            }
        }
        if let range = errorLabel.text?.range(of: Text.seeResult.localized())?.nsRange {
            if tap.didTapAttributedTextInLabel(label: errorLabel,
                                               inRange: range) {
                if let testModel = testModel,
                   testModel.testModelArray.isEmpty == false {
                    Router.shared.route(
                        to: Route.retroValidationTest(testModel: testModel),
                        from: self,
                        presentationType: .push(surveyToolBarNeeded: false)
                    )
                }
            }
        }
        if let range = errorLabel.text?.range(of: Text.compressed.localized())?.nsRange {
            if tap.didTapAttributedTextInLabel(label: errorLabel,
                                               inRange: range) {
                uploadCompressedVideo()
            }
        }
        if let range = errorLabel.text?.range(of: Text.noncompressed.localized())?.nsRange {
            if tap.didTapAttributedTextInLabel(label: errorLabel,
                                               inRange: range) {
                uploadNonCompressedVideo()
            }
        }
    }
}

extension CameramanViewController: CommunityThemeConfigurable {
    @objc func applyCommunityTheme() {
        guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
            return
        }
        confirmUploadButton.setBackgroundColor(color: colors.primary, forState: .normal)
        if let currentBlock = surveyManager?.currentPage?.blocks.filter({$0.blockType == BlockPageType.oAuthCapture.rawValue}),
           currentBlock.isEmpty == false {
            confirmUploadButton.setTitle("Finish", for: .normal)
            return
        }
        var buttonText = ""
        switch surveyBlock?.screenCaptureBlock?.dataFormat {
        case .image, .video: buttonText = Cameraman.uploadFromPhoto.localized()
        case .file: buttonText = Cameraman.uploadFromFile.localized()
        default: break
        }
        let uploadPhotoAttributedText = buttonText.withAttributes([
            Attribute.font(Font.regular.of(size: 15)),
            Attribute.textColor(colors.primary),
            Attribute.underlineStyle(NSUnderlineStyle.single),
            Attribute.underlineColor(colors.primary)
        ])
        uploadPhotoButton.setAttributedTitle(uploadPhotoAttributedText, for: .normal)
    }
}

extension CameramanViewController {
    
    @objc func moveToNext() {
    }
    
    @objc func moveToBack() {
        self.navigationController?.popViewController(animated: true)
        Defaults.remove(.retroVideoFileSize)
        Defaults.remove(.retroVideoApproxUploadSpeed)
        NotificationCenter.default.post(name: NSNotification.Name.refreshWebview, object: nil, userInfo: nil)
    }
}
extension CameramanViewController: SurveyCompletionDelegate {
    func didCompleteSurvey(_ surveyManager: SurveyManager?) {
    }
}
