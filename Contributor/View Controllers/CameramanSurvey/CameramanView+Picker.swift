//
//  CameramanView+Picker.swift
//  Contributor
//
//  Created by KiwiTech on 8/18/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

extension CameramanViewController {
func callMediaUploadingAPI(_ url: URL) {
    if ConnectivityUtils.isConnectedToNetwork() == false {
      Helper.showNoNetworkAlert(controller: self)
      return
    }
    activityIndicator.updateIndicatorView(self, hidden: false)
    guard let captureType = surveyBlock?.screenCaptureBlock?.dataFormat else { return }
    let param = MediaParam(videoFileName: url.lastPathComponent,
                                  mediaType: captureType.rawValue,
                                  uploadStatus: UploadStatus.uploading)
    NetworkManager.shared.uploadMedia(param) { [weak self] (response, _) in
      guard let this = self else { return }
      this.activityIndicator.updateIndicatorView(this, hidden: true)
      if let mediaData = response {
        if ConnectivityUtils.isConnectedToNetwork() == false {
          Helper.showNoNetworkAlert(controller: this)
          return
        }
        guard let selectedOffer = this.offerItem else { return }
        if this.checkIfMediaResponseValueNotNil(mediaData) {
            this.configureAWS(mediaData)
            Router.shared.route(
              to: Route.cameramanUploadPage(videoData: mediaData, selectedUrl: url,
                                            surveyManager: this.surveyManager, offerItem: selectedOffer,
                                            screenCaptureType: captureType,
                                            hasSkipContentValidation: this.hasSkipContentValidation),
                from: this,
                presentationType: .push(surveyToolBarNeeded: true, needOnlyExitButton: true)
              )
          } else {
            this.showErrorIfMediaResponseFail()
          }
        } else {
            this.showErrorIfMediaResponseFail()
        }
    }
}
    
func showErrorIfMediaResponseFail() {
  errorView.isHidden = false
  errorLabel.isHidden = true
  errorHeaderLabel.isHidden = false
}
    
func checkIfMediaResponseValueNotNil(_ mediaData: MediaUploadResponse) -> Bool {
   if let awsbucket = mediaData.awsBucket, awsbucket.isEmpty == false,
       let mediaURL = mediaData.url, mediaURL.isEmpty == false,
       let mediaFileName = mediaData.fileName, mediaFileName.isEmpty == false,
       let accessKey = mediaData.awsKeyId, accessKey.isEmpty == false,
       let secretKey = mediaData.awsSecret, secretKey.isEmpty == false,
       let userId = mediaData.userId, userId > 0, let _ = selectedVideoURL {
         return true
    }
    return false
   }
}

extension CameramanViewController: PHPickerViewControllerDelegate {
@available(iOS 14, *)
func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    guard !results.isEmpty else {
        picker.dismiss(animated: true, completion: nil)
        return
    }
    let identifiers = results.compactMap(\.assetIdentifier)
    guard let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil).firstObject else {
        picker.dismiss(animated: true, completion: nil)
        return
    }
    errorView.isHidden = true
    confirmUploadButton.setTitle(Cameraman.confirmUpload.localized(), for: .normal)
    switch fetchResult.mediaType {
    case .image:
        AWSS3Manager.shared.getImage(.image, fetchResult) { [weak self] (image, uploadURL, date) in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if image != nil {
                  this.updateUI(.image, asset: fetchResult, uploadURL: uploadURL, date: date, image: image)
                }
            }
        }
   
    default:
        AWSS3Manager.shared.getVideoData(.video, fetchResult) { [weak self] (uploadURL, date) in
           guard let this = self else { return }
           DispatchQueue.main.async {
            if uploadURL != nil {
                this.updateUI(.video, asset: fetchResult, uploadURL: uploadURL, date: date)
            }
           }
        }
    }
    picker.dismiss(animated: true, completion: nil)
  }
    
@available(iOS 14, *)
func imagePickerControllerDidCancel(_ picker: PHPickerViewController) {
  picker.dismiss(animated: true, completion: nil)
  }
}

extension CameramanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
  errorView.isHidden = true
  confirmUploadButton.setTitle(Cameraman.confirmUpload.localized(), for: .normal)
  if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
    switch asset.mediaType {
    case .image:
    guard let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
    AWSS3Manager.shared.getMediaAsset(.image, imageURL, imageURL.creationDate) { [weak self] (uploadURL, _) in
        guard let this = self else { return }
        DispatchQueue.main.async {
            this.updateUI(.image, asset: asset, uploadURL: uploadURL, date: asset.creationDate)
        }
      }
    default:
      guard let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
      AWSS3Manager.shared.getMediaAsset(.video, mediaURL, mediaURL.creationDate) { [weak self] (uploadURL, _) in
           guard let this = self else { return }
           DispatchQueue.main.async {
            this.updateUI(.video, asset: asset, uploadURL: uploadURL, date: asset.creationDate)
           }
        }
    }
     dismiss(animated: true, completion: nil)
    }
}

func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}
