//
//  Cameraman+VideoValidation.swift
//  Contributor
//
//  Created by KiwiTech on 9/14/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

extension CameramanViewController {
    func isVideoContainedText(completion: @escaping (Bool, Bool) -> Void) {
        guard let url = selectedVideoURL else {
            completion(false, false)
            return
        }
        let videoValidationContent = getValidationType()
        switch videoValidationContent {
        case .mediaFileContentv4:
            handleNewFileContentsForV4(url: url, videoValidationContent) { (hasFound, hasNegativeMarkers) in
                completion(hasFound, hasNegativeMarkers)
                return
            }
        case .mediaFileContentv3, .mediaFileContentv2:
            handleNewFileContents(url: url, videoValidationContent) { (hasFound) in
                completion(hasFound, false)
                return
            }
        case .mediaFileContent:
            handleFileContent(url: url) { (hasFound) in
                completion(hasFound, false)
                return
            }
        case .none:
            self.callMediaUploadingAPI(url)
        }
    }
    
    func getValidationType() -> VideoValidationType {
        if let validationType = surveyBlock?.screenCaptureBlock?.validation.map({$0.type}) {
            if validationType.contains(CameramanValidation.mediaFileContentv4) {
                return .mediaFileContentv4
            }
            if validationType.contains(CameramanValidation.mediaFileContentv3) {
                return .mediaFileContentv3
            }
            if validationType.contains(CameramanValidation.mediaFileContentv2) {
                return .mediaFileContentv2
            }
            if validationType.contains(CameramanValidation.mediaFileContent) {
                return .mediaFileContent
            }
        }
        return .none
    }
    func handleNewFileContentsForV4(url: URL, _ validationType: VideoValidationType, completion: @escaping (Bool, Bool) -> Void) {
        let fileContentType = validationType.rawValue
        if let contentData = surveyBlock?.screenCaptureBlock?.validation.filter({$0.type == fileContentType})[0],
           let timeOut = contentData.timeOut, let markers = contentData.markers, let mode = contentData.mode, let negativeMarkers = contentData.negativeMarkers {
            let algo = contentData.algorithm ?? ""
            var negativeMarkerErrorMsg = ""
            let selectedLanguage = AppLanguageManager.shared.getLanguage()
            if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
                if let msg = contentData.negativeMarkers?.messagePt {
                    negativeMarkerErrorMsg = msg
                } else {
                    negativeMarkerErrorMsg = contentData.negativeMarkers?.messageEn ?? ""
                }
            } else {
                negativeMarkerErrorMsg = contentData.negativeMarkers?.messageEn ?? ""
            }
            initiateNewVideoValidationForV4(fileContentType,
                                            mode,
                                            url,
                                            timeOut: timeOut,
                                            markers: markers,
                                            algo,
                                            negativeMarkers: negativeMarkers) { [weak self] (containedText, isNegativeMarkerFound) in
                guard let this = self else { return }
                DispatchQueue.main.async {
                    this.activityIndicator.updateIndicatorView(this, hidden: true)
                    if containedText {
                        if isNegativeMarkerFound {
                            this.updateErrorView(shouldShowError: true,
                                                 validationType: .mediaContent,
                                                 captureType: .video,
                                                 isNegativeMarkersFound: isNegativeMarkerFound,
                                                 negativeMarkerMsg: negativeMarkerErrorMsg )
                            completion(false, isNegativeMarkerFound)
                        } else {
                            this.updateErrorView(shouldShowError: false, captureType: .video)
                            completion(true, isNegativeMarkerFound)

                        }
                       // this.updateErrorView(shouldShowError: false, captureType: .video)
                       // completion(true, isNegativeMarkerFound)
                    } else {
                        this.updateErrorView(shouldShowError: true, validationType: .mediaContent, captureType: .video)
                        completion(false, isNegativeMarkerFound)
                    }
                }
            }
        }
    }
    func handleNewFileContents(url: URL, _ validationType: VideoValidationType, completion: @escaping (Bool) -> Void) {
        let fileContentType = validationType.rawValue
        if let contentData = surveyBlock?.screenCaptureBlock?.validation.filter({$0.type == fileContentType})[0],
           let timeOut = contentData.timeOut, let markers = contentData.markers, let mode = contentData.mode {
            let algo = contentData.algorithm ?? ""
            initiateNewVideoValidation(fileContentType, mode, url,
                                       timeOut: timeOut, markers: markers, algo) { [weak self] (containedText, _) in
                guard let this = self else { return }
                DispatchQueue.main.async {
                    this.activityIndicator.updateIndicatorView(this, hidden: true)
                    if containedText {
                        this.updateErrorView(shouldShowError: false, captureType: .video)
                        completion(true)
                    } else {
                        this.updateErrorView(shouldShowError: true, validationType: .mediaContent, captureType: .video)
                        completion(false)
                    }
                }
            }
        }
    }
    
    func handleFileContent(url: URL, completion: @escaping (Bool) -> Void) {
        let fileContent = CameramanValidation.mediaFileContent
        if let contentData = surveyBlock?.screenCaptureBlock?.validation.filter({$0.type == fileContent})[0],
           let timeOut = contentData.timeOut,
           let v1markers = contentData.v1Markers, let mode = contentData.mode {
            let algo = contentData.algorithm ?? ""
            initiateVideoValidation(CameramanValidation.mediaFileContent, mode, url,
                                    timeOut: timeOut, v1markers: v1markers, algo) { [weak self] (containedText, _) in
                guard let this = self else { return }
                DispatchQueue.main.async {
                    this.activityIndicator.updateIndicatorView(this, hidden: true)
                    if containedText {
                        this.updateErrorView(shouldShowError: false, captureType: .video)
                        completion(true)
                    } else {
                        this.updateErrorView(shouldShowError: true, validationType: .mediaContent, captureType: .video)
                        completion(false)
                    }
                }
            }
        } else {
            self.callMediaUploadingAPI(url)
        }
    }
    
    func isVideoFileSizeCorrect(fileSize: Int) -> Bool {
        guard let url = selectedVideoURL else { return false }
        if let validationType = surveyBlock?.screenCaptureBlock?.validation.map({$0.type}),
           !validationType.contains(CameramanValidation.mediaSize) { return true }
        if let fileSizeType = surveyBlock?.screenCaptureBlock?.validation.map({$0.fileSizeType})[0] {
            let videoSize = getConvertedFileSize(fileSize, fileSizeType)
            guard let type = surveyBlock?.screenCaptureBlock?.dataFormat else { return false }
            let mediSize = CameramanValidation.mediaSize
            if let sizeData = surveyBlock?.screenCaptureBlock?.validation.filter({$0.type == mediSize})[0],
               let minFileSize = sizeData.minFileSize, let maxFileSize = sizeData.maxFileSize {
                if videoSize >= minFileSize && videoSize <= maxFileSize {
                    updateErrorView(shouldShowError: false, validationType: .mediaSize, captureType: type)
                    return true
                } else {
                    updateErrorView(shouldShowError: true, maxSize: maxFileSize,
                                    minSize: minFileSize, validationType: .mediaSize,
                                    videoSize: videoSize, captureType: type)
                    return false
                }
            } else {
                return true
            }
        }
        return false
    }
    
    func isRecentFile() -> Bool {
        let nowDate = Date()
        if let selectedDate = self.selectedDateTime {
            guard let type = surveyBlock?.screenCaptureBlock?.dataFormat else { return false }
            if let validationType = surveyBlock?.screenCaptureBlock?.validation.map({$0.type}),
               !validationType.contains(CameramanValidation.mediaRecency) { return true }
            let diffComponents = Calendar.current.dateComponents([.minute], from: selectedDate, to: nowDate)
            if let recency = surveyBlock?.screenCaptureBlock?.validation.filter({$0.type == CameramanValidation.mediaRecency})[0],
               let fileRecency = recency.fileRecency,
               let minute = diffComponents.minute {
                if minute < fileRecency {
                    updateErrorView(shouldShowError: false, captureType: type)
                    return true
                } else {
                    updateErrorView(shouldShowError: true, validationType: .mediaRecency, captureType: type)
                    return false
                }
            } else {
                return true
            }
        }
        return false
    }
    
    func initiateVideoValidation(_ contentType: String,
                                 _ mode: ModeType,
                                 _ videoUrl: URL,
                                 timeOut: Int,
                                 v1markers: [String],
                                 _ algo: String,
                                 completion: @escaping (Bool, Bool) -> Void) {
        DispatchQueue.main.async {
            self.timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeOut), repeats: true) { [weak self] _ in
                // do something here
                debugPrint("Cancel operation")
                NotificationCenter.default.post(name: Notification.Name.validationTimeOut, object: nil)
                self?.timer?.invalidate()
            }
        }
        activityIndicator.updateIndicatorView(self, hidden: false)
        let videoValidation = VideoValidation.init(contentType: contentType, videoUrl: videoUrl,
                                                   markers: nil, v1markers: v1markers, negativeMarker: nil)
        videoValidation.videoValidationProcess(mode) { [weak self] (containedText, _, testCameramanArray, isNegativeMarkersFound) in
            self?.timer?.invalidate()
            debugPrint("containedText: \(containedText)")
            guard let this = self else { return }
            if let retroTestModelArray = testCameramanArray {
                this.retroValidationArray = retroTestModelArray
                this.testModel = CameraTestModel(fileContentType: contentType,
                                                 algorithm: algo,
                                                 markersV1: v1markers,
                                                 newMarkers: nil,
                                                 maxTimeOut: timeOut,
                                                 mode: mode.rawValue,
                                                 testModelArray: this.retroValidationArray,
                                                 negativeMarkers: nil)
            }
            if UserManager.shared.user?.isTestUser == false {
                Utilities.clearAllDataFrom(folderName: Constants.framePath)
            }
            completion(containedText, isNegativeMarkersFound)
        }
    }
    
    func initiateNewVideoValidation(_ contentType: String,
                                    _ mode: ModeType,
                                    _ videoUrl: URL,
                                    timeOut: Int,
                                    markers: [[String]],
                                    _ algo: String,
                                    completion: @escaping (Bool, Bool) -> Void) {
        DispatchQueue.main.async {
            self.timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeOut), repeats: true) { [weak self] _ in
                // do something here
                debugPrint("Cancel operation")
                NotificationCenter.default.post(name: Notification.Name.validationTimeOut, object: nil)
                self?.timer?.invalidate()
            }
        }
        activityIndicator.updateIndicatorView(self, hidden: false)
        let videoValidation = VideoValidation.init(contentType: contentType,
                                                   videoUrl: videoUrl,
                                                   markers: markers,
                                                   v1markers: nil, negativeMarker: nil)
        videoValidation.videoValidationProcess(mode) { [weak self] (containedText, _, testCameramanArray, isNegativeMarkersFound) in
            self?.timer?.invalidate()
            debugPrint("containedText: \(containedText)")
            guard let this = self else { return }
            if let retroArray = testCameramanArray {
                this.retroValidationArray = retroArray
                this.testModel = CameraTestModel(fileContentType: contentType,
                                                 algorithm: algo,
                                                 markersV1: nil,
                                                 newMarkers: markers,
                                                 maxTimeOut: timeOut,
                                                 mode: mode.rawValue,
                                                 testModelArray: this.retroValidationArray,
                                                 negativeMarkers: nil)
            }
            if UserManager.shared.user?.isTestUser == false {
                Utilities.clearAllDataFrom(folderName: Constants.framePath)
            }
            completion(containedText, isNegativeMarkersFound)
        }
    }
    func initiateNewVideoValidationForV4(_ contentType: String, _ mode: ModeType,
                                         _ videoUrl: URL,
                                         timeOut: Int,
                                         markers: [[String]],
                                         _ algo: String,
                                         negativeMarkers: NegativeMarker,
                                         completion: @escaping (Bool,Bool) -> Void) {
        DispatchQueue.main.async {
            self.timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeOut), repeats: true) { [weak self] _ in
                // do something here
                debugPrint("Cancel operation")
                NotificationCenter.default.post(name: Notification.Name.validationTimeOut, object: nil)
                self?.timer?.invalidate()
            }
        }
        activityIndicator.updateIndicatorView(self, hidden: false)
        let videoValidation = VideoValidation.init(contentType: contentType,
                                                   videoUrl: videoUrl,
                                                   markers: markers,
                                                   v1markers: nil,
                                                   negativeMarker: negativeMarkers.keys)
        videoValidation.videoValidationProcess(mode) { [weak self] (containedText, _, testCameramanArray, isNegativeMarkersFound) in
            self?.timer?.invalidate()
            debugPrint("containedText: \(containedText)")
            debugPrint("contained NegativeMarkers Text: \(isNegativeMarkersFound)")

            guard let this = self else { return }
            if let retroArray = testCameramanArray {
                this.retroValidationArray = retroArray
                this.testModel = CameraTestModel(fileContentType: contentType,
                                                 algorithm: algo,
                                                 markersV1: nil,
                                                 newMarkers: markers,
                                                 maxTimeOut: timeOut,
                                                 mode: mode.rawValue,
                                                 testModelArray: this.retroValidationArray,
                                                 negativeMarkers: negativeMarkers.keys)
            }
            if UserManager.shared.user?.isTestUser == false {
                Utilities.clearAllDataFrom(folderName: Constants.framePath)
            }
            completion(containedText, isNegativeMarkersFound)
        }
    }
}
