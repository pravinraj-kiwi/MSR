//
//  UploadCompletionViewController.swift
//  Contributor
//
//  Created by KiwiTech on 7/7/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore
import AVFoundation
import SwiftyUserDefaults

extension Date {
    func toMillis() -> Int64 {
         return Int64(self.timeIntervalSince1970 * 1000)
    }
}
enum UploadingTimeType: String {
    case start
    case end
}
struct FileModel {
    var fileName: String
    var uploadingTimeType: UploadingTimeType
    var progress: Float
    var time : Int64
    init(name: String,
         type: UploadingTimeType,
         progressValue: Float,
         currentTime: Int64) {
        self.fileName = name
        self.uploadingTimeType = type
        self.progress = progressValue
        self.time = currentTime
    }
}
class UploadCompletionViewController: UIViewController {
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subHeaderLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var progressView: UIView!
    
    var selectedVideo: MediaUploadResponse?
    var surveyManager: SurveyManager?
    var videoUrl: URL?
    var hasSkipContentValidation: Bool = false
    var selectedOffer: OfferItem?
    var captureType: ScreenCaptureType?
    var urlStr: String? = ""
    var uploadingLogArray: [FileModel] = []
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
        resetUI()
        uploadVideoToS3()
        applyCommunityTheme()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSurveyObserver()
    }
    func addSurveyObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(dismissSurvey), name: NSNotification.Name.dismissSurveyPage, object: nil)
        
    }
    func getUploadCompleteMessage() -> (String, String) {
        switch captureType {
        case .image: return (ImageUpload.subHeaderText.localized(), ImageUpload.errorSubHeaderText.localized())
        case .video: return (VideoUpload.subHeaderText.localized(), VideoUpload.errorSubHeaderText.localized())
        case .file: return (FileUpload.subHeaderText.localized(), FileUpload.errorSubHeaderText.localized())
        default: break
        }
        return ("", "")
    }
    
    func updateUI(_ headerText: String, _ subHeaderText: String, color: UIColor) {
        headerLabel.font = Font.bold.of(size: 20)
        subHeaderLabel.font = Font.regular.of(size: 16)
        headerLabel.textColor = color
        headerLabel.text = headerText
        subHeaderLabel.text = subHeaderText
    }
    
    func resetUI() {
        let textColor = Utilities.getRgbColor(17, 17, 17)
        tryAgainButton.isHidden = true
        progressView.isHidden = false
        updateUI(Cameraman.headerText.localized(), getUploadCompleteMessage().0, color: textColor)
        progress.progress = 0.0
        uploadingLogArray = []
        Defaults[.retroVideoApproxUploadSpeed] = ""
        debugPrint("Reset UI Called>>>>>")
    }
    
    func updateErrorUI() {
        activityIndicator.updateIndicatorView(self, hidden: true)
        let textColor = Utilities.getRgbColor(251, 72, 72)
        updateUI(Cameraman.uploadHeaderText.localized(), getUploadCompleteMessage().1, color: textColor)
        tryAgainButton.isHidden = false
        progressView.isHidden = true
    }
    
    func uploadVideoToS3() {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: self)
            return
        }
        activityIndicator.updateIndicatorView(self, hidden: false)
        var folderName = ""
        var bucketName = ""
        var fileName = ""
        if let mediaURl = selectedVideo?.url, let url = URL(string: mediaURl) {
            folderName = url.deletingLastPathComponent().absoluteString
        }
        progress.progress = 0.1
        if let name = selectedVideo?.awsBucket {
            bucketName = name
        }
        if let name = selectedVideo?.fileName {
            fileName = name
        }
        let uploadType = captureType?.rawValue ?? ""
        let startTimeStamp = FileModel(name: fileName,
                                       type: .start,
                                       progressValue: 0.0,
                                       currentTime: Date().toMillis())
        uploadingLogArray.append(startTimeStamp)
        
        AWSS3Manager.shared.uploadS3Data(bucketName: bucketName, videoUrl: self.videoUrl!,
                                         fileName: fileName, s3FolderName: folderName,
                                         contenType: uploadType,
                                         progress: { [weak self] (progress, transferState) in
                                            guard let this = self else { return }
                                            if transferState.status == .unknown
                                                || transferState.status == .error
                                                || transferState.status == .cancelled {
                                                this.updateErrorUI()
                                                transferState.cancel()
                                                let endTimeStamp = FileModel(name: fileName,
                                                                             type: .end,
                                                                             progressValue: Float(progress),
                                                                             currentTime: Date().toMillis())
                                                this.uploadingLogArray.append(endTimeStamp)
                                                let approxSpeed =  this.calculateApproxUploadSpeed()
                                                debugPrint("Approx Speed after cancel is ", approxSpeed) // roundoff to 2 places
                                                
                                                Defaults[.retroVideoApproxUploadSpeed] = approxSpeed
                                                return
                                            }
                                            debugPrint("Uploading progress is ", Float(progress))
                                            
                                            let endTimeStamp = FileModel(name: fileName,
                                                                         type: .end,
                                                                         progressValue: Float(progress),
                                                                         currentTime: Date().toMillis())
                                            this.uploadingLogArray.append(endTimeStamp)
                                            
                                            this.progress.progress = Float(progress)}) { [weak self] (uploadingTask, error) in
            guard let this = self else { return }
            let approxSpeed =  this.calculateApproxUploadSpeed()
            debugPrint("Approx Speed after complete is ", approxSpeed)
            Defaults[.retroVideoApproxUploadSpeed] = approxSpeed
            this.activityIndicator.updateIndicatorView(this, hidden: true)
            this.updateAWSBlock(error, uploadingTask, folderName, fileName, uploadType, this.videoUrl!)
        }
    }
    @objc func dismissSurvey() {
        AWSS3Manager.shared.cancelUpload()
        let approxSpeed =  self.calculateApproxUploadSpeed()
        debugPrint("Approx Speed after cancel is ", approxSpeed)
        Defaults[.retroVideoApproxUploadSpeed] = approxSpeed
    }
    func calculateApproxUploadSpeed() -> String {
        guard let startTime = self.uploadingLogArray.filter({$0.uploadingTimeType == .start}).first?.time else {return ""}
        guard let endTime = self.uploadingLogArray.filter({$0.uploadingTimeType == .end}).last?.time else {return ""}
        guard let url = self.videoUrl else {return ""}
        let fileSize = Float(url.filesize ?? 0 / 1048576)
        
        let totalTime = Float(endTime - startTime)
        let speed = (fileSize / totalTime) / 1000
        debugPrint("Speed is ",speed, String(format: "%.2f", Float(speed)))
        return String(format: "%.2f", Float(speed))
        
    }
    func updateAWSBlock(_ error: Error?, _ uploadingTask: Any?,
                        _ s3FolderName: String, _ fileName: String,
                        _ uploadType: String, _ videoUrl: URL) {
        if error != nil {
            updateErrorUI()
            return
        }
        if let task = uploadingTask as? AWSS3TransferUtilityMultiPartUploadTask {
            if task.status == .unknown
                || task.status == .error
                || task.status == .cancelled {
                updateErrorUI()
                return
            }
            if task.status == .completed {
                urlStr = s3FolderName + fileName
                callMediaUploadedAPI(videoUrl, uploadType)
            }
        }
    }
    
    func showError() {
        let alerter = Alerter(viewController: self)
        alerter.alert(title: "", message: SignUpViewText.requestError.localized(),
                      confirmButtonTitle: Text.ok.localized(),
                      cancelButtonTitle: Text.cancel.localized(),
                      confirmButtonStyle: .default, onConfirm: {
                        self.navigationController?.popViewController(animated: true)
                      }, onCancel: nil)
    }
    
    func callMediaUploadedAPI(_ url: URL, _ uploadType: String) {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: self, position: .bottom)
            return
        }
        activityIndicator.updateIndicatorView(self, hidden: false)
        let param = MediaParam(videoFileName: url.lastPathComponent,
                               mediaType: uploadType,
                               uploadStatus: UploadStatus.uploaded)
        NetworkManager.shared.uploadMedia(param) { [weak self] (response, error) in
            guard let this = self else { return }
            this.activityIndicator.updateIndicatorView(this, hidden: true)
            if error != nil {
                this.updateErrorUI()
                return
            }
            if let _ = response {
                this.clearAllExtractedMediaURL()
                Utilities.clearAllDataFrom(folderName: Constants.compressedPath)
                this.navigateToNextPage()
            } else {
                this.updateErrorUI()
            }
        }
    }
    
    func clearAllExtractedMediaURL() {
        let fm = FileManager.default
        do {
            let tmpDirURL = URL(string: NSTemporaryDirectory())!
            let tmpFiles = try fm.contentsOfDirectory(at: tmpDirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for path in tmpFiles {
                if path.pathExtension == MediaType.videoExtension
                    || path.pathExtension == MediaType.imageExtension {
                    try fm.removeItem(at: path)
                }
            }
        } catch { }
    }
    
    @IBAction func clickTryUploadAgain(_ sender: Any) {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: self, position: .top)
            return
        }
        resetUI()
        uploadVideoToS3()
    }
    
    func navigateToNextPage() {
        guard let selectedOffer = selectedOffer else { return }
        guard let manager = surveyManager else { return }
        manager.nextPage(offerItem: selectedOffer) { (error) in
            if let error = error {
                switch error {
                case .endReached:
                    self.finish()
                default: break
                }
            } else {
                Router.shared.route(
                    to: Route.surveyPage(surveyManager: manager, offerItem: selectedOffer),
                    from: self,
                    presentationType: .push(surveyToolBarNeeded: true)
                )
            }
        }
    }
    
    func finish() {
        guard let surveyType = surveyManager?.surveyType else { return }
        SurveyCallbackManager.shared.callback(surveyType: surveyType,
                                              callbackType: .completed,
                                              manager: surveyManager,
                                              videoUrl: urlStr, hasSkipContentValidation) { (response, surveyCompletion, error)  in
            debugPrint("Survey Result is ", response)
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
    func navigateToSurveyCompletion(surveyStatus: SurveyStatus) {
        guard let surveyType = surveyManager?.surveyType else { return }
        Router.shared.route(
            to: Route.surveyCompletion(surveyType: surveyType,
                                       surveyStatus: surveyStatus,
                                       delegate: self,
                                       surveyManager: surveyManager,
                                       videoUrl: urlStr,
                                       hasSkipContentValidation: hasSkipContentValidation),
            from: self,
            presentationType: .push(surveyToolBarNeeded: false)
        )
    }
}

extension UploadCompletionViewController: SurveyCompletionDelegate {
    func didCompleteSurvey(_ surveyManager: SurveyManager?) {
        NotificationCenter.default.post(name: NSNotification.Name.balanceChanged, object: nil)
    }
}

extension UploadCompletionViewController: CommunityThemeConfigurable {
    @objc func applyCommunityTheme() {
        guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
            return
        }
        activityIndicator.color = colors.primary
        progress.tintColor = colors.primary
        tryAgainButton.setBackgroundColor(color: colors.primary, forState: .normal)
    }
}
