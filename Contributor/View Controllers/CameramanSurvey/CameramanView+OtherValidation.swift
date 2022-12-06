//
//  CameramanView+OtherValidation.swift
//  Contributor
//
//  Created by KiwiTech on 12/16/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

extension CameramanViewController {
    
    func getFileRecencyError() -> String {
        switch surveyBlock?.screenCaptureBlock?.dataFormat {
        case .image:
            return ImageUpload.imageFileRecency.localized()
        case .video:
            return VideoUpload.videoFileRecency.localized()
        case .file:
            return FileUpload.fileRecency.localized()
        default: break
        }
        return ""
    }
    
    func getFileContentValidation(_ appName: String,
                                  isNegativeMarker: Bool ,
                                  negativeMarkerMsg: String = "") {
        var suffixMessage = ""
        var message = ""
        if isNegativeMarker {
            suffixMessage = VideoUpload.videoFileContentSufix.localized() + VideoUpload.videoFileContentEnd.localized()
            message = negativeMarkerMsg + suffixMessage
        } else {
            suffixMessage = VideoUpload.videoFileContentSufix.localized() + " \(appName) " + VideoUpload.videoFileContentEnd.localized()
            message = VideoUpload.videoFileContentPrefix.localized() + " \(appName)" + suffixMessage
        }
        
        let attributedText = message.withFont(Font.italic.of(size: 15))
        let linkFontAttributes = [
            Attribute.textColor(Utilities.getRgbColor(251, 72, 72)),
            Attribute.underlineColor(Utilities.getRgbColor(251, 72, 72)),
            Attribute.underlineStyle(.single)
        ]
        attributedText.addAttributesToTerms(linkFontAttributes, to: [Text.here.localized()])
        errorLabel.attributedText = attributedText
    }
    
    func getFileContentValidationForTestUser(_ appName: String,
                                             isNegativeMarker: Bool ,
                                             negativeMarkerMsg: String = "") {
        var suffixMessage = ""
        var message = ""
        if isNegativeMarker {
            suffixMessage = VideoUpload.videoFileContentSufix.localized() + VideoUpload.videoFileTestUserContentEnd.localized()
            message = negativeMarkerMsg + suffixMessage
        } else {
            suffixMessage = VideoUpload.videoFileContentSufix.localized() + " \(appName) " + VideoUpload.videoFileTestUserContentEnd.localized()
            message = VideoUpload.videoFileContentPrefix.localized() + " \(appName)" + suffixMessage
        }
        
        let attributedText = message.withFont(Font.italic.of(size: 15))
        let linkFontAttributes = [
            Attribute.textColor(.blue),
            Attribute.underlineColor(.blue),
            Attribute.underlineStyle(.single)
        ]
        attributedText.addAttributesToTerms(linkFontAttributes, to: [Text.seeResult.localized(), Text.here.localized()])
        errorLabel.attributedText = attributedText
    }
    
    func updateErrorView(shouldShowError: Bool, maxSize: Int = 0, minSize: Int = 0,
                         validationType: CameramanValidationType = .mediaSize,
                         videoSize: Int = 0, captureType: ScreenCaptureType, isNegativeMarkersFound: Bool = false, negativeMarkerMsg : String = "") {
        if shouldShowError {
            switch validationType {
            case .mediaRecency:
                errorView.isHidden = false
                errorLabel.text = getFileRecencyError()
            case .mediaSize:
                errorView.isHidden = false
                updateErrorIfExist(maxSize: maxSize, minSize: minSize,
                                   videoSize: videoSize, captureType: captureType)
            case .mediaContent:
                if isNegativeMarkersFound {
                    addTapGestureOnLabel()
                    if ConnectivityUtils.isConnectedToNetwork() == false {
                        errorView.isHidden = false
                        self.getFileContentValidation("",
                                                      isNegativeMarker: true,
                                                      negativeMarkerMsg: negativeMarkerMsg)
                        return
                    }
                    updateMediaFileContent("",
                                           isNegativeMarker: true,
                                           negativeMarkerMsg: negativeMarkerMsg)
                } else {
                    if let appName = surveyBlock?.screenCaptureBlock?.appName {
                        addTapGestureOnLabel()
                        if ConnectivityUtils.isConnectedToNetwork() == false {
                            errorView.isHidden = false
                            self.getFileContentValidation(appName,
                                                          isNegativeMarker: false, negativeMarkerMsg: "")
                            //self.getFileContentValidation(appName, isNegativeMarker: false)
                            return
                        }
                        updateMediaFileContent(appName,
                                               isNegativeMarker: false,
                                               negativeMarkerMsg: "")
                    }
                }
            }
            confirmUploadButton.setTitle(Cameraman.uploadTryAgain.localized(), for: .normal)
        } else {
            errorView.isHidden = true
            confirmUploadButton.setTitle(Cameraman.confirmUpload.localized(), for: .normal)
        }
    }
    
    func updateMediaFileContent(_ appName: String,
                                isNegativeMarker: Bool ,
                                negativeMarkerMsg: String = "") {
        NetworkManager.shared.checkIfIsTestUser { (status, error) in
            if error != nil {
                self.errorView.isHidden = false
                self.getFileContentValidation(appName,
                                              isNegativeMarker: isNegativeMarker,
                                              negativeMarkerMsg: negativeMarkerMsg)
                //        if isNegativeMarker {
                //            self.getFileContentValidation("",
                //                                          isNegativeMarker: isNegativeMarker,
                //                                          negativeMarkerMsg: negativeMarkerMsg)
                //        } else {
                //            self.getFileContentValidation(appName, isNegativeMarker: isNegativeMarker)
                //        }
                return
            }
            UserManager.shared.user?.isTestUser = status?.isTestUser ?? false
            if UserManager.shared.user?.isTestUser == true {
                self.errorView.isHidden = false
                self.getFileContentValidationForTestUser(appName,
                                                         isNegativeMarker: isNegativeMarker,
                                                         negativeMarkerMsg: negativeMarkerMsg)
                //self.getFileContentValidationForTestUser(appName, isNegativeMarker: <#Bool#>)
            } else {
                self.errorView.isHidden = false
                self.getFileContentValidation(appName,
                                              isNegativeMarker: isNegativeMarker,
                                              negativeMarkerMsg: negativeMarkerMsg)
                // self.getFileContentValidation(appName, isNegativeMarker: <#Bool#>)
            }
        }
    }
    
    func updateErrorIfExist(maxSize: Int = 0, minSize: Int = 0,
                            videoSize: Int = 0, captureType: ScreenCaptureType) {
        if maxSize == 0 || minSize == 0 {
            errorLabel.text = ""
        }
        if videoSize < minSize {
            if captureType == .image || captureType == .file {
                let prefix = "\(CameramanError.the.localized()) \(captureType.rawValue)"
                let sufix = "\(CameramanError.minumumSize.localized()) \(minSize) \(CameramanError.kbTryAgain.localized())"
                errorLabel.text = prefix + sufix
            } else {
                errorLabel.text = "\(CameramanError.underMinimumSize.localized()) \(minSize / 1000) \(CameramanError.mbTryAgain.localized())"
            }
        }
        if videoSize <= minSize && videoSize < maxSize {
            if captureType == .image || captureType == .file {
                let prefix = "\(CameramanError.the.localized()) \(captureType.rawValue)"
                let sufix = "\(CameramanError.minumumSize.localized()) \(minSize) \(CameramanError.kbTryAgain.localized())"
                errorLabel.text = prefix + sufix
            } else {
                errorLabel.text = "\(CameramanError.underMinimumSize.localized()) \(minSize / 1000) \(CameramanError.mbTryAgain.localized())"
            }
        }
        if videoSize > maxSize {
            if captureType == .image || captureType == .file {
                let prefix = "\(CameramanError.the.localized()) \(captureType.rawValue)"
                let sufix = "\(CameramanError.maximumSize.localized()) \(maxSize / 1000) \(CameramanError.mbTryAgain.localized())"
                errorLabel.text = prefix + sufix
            } else {
                errorLabel.text = "\(CameramanError.overMaximumSize.localized()) \(maxSize / 1000) \(CameramanError.mbTryAgain.localized())"
            }
        }
    }
}
