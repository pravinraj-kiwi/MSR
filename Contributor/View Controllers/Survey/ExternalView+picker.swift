//
//  ExternalView+picker.swift
//  Contributor
//
//  Created by KiwiTech on 8/18/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

extension ExternalSurveyViewController: PHPickerViewControllerDelegate {
@available(iOS 14, *)
func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    guard !results.isEmpty else {
        webView.evaluateJavaScript("sendMeasureMessage('uncheckFinishedCheckbox','{};')", completionHandler: nil)
        picker.dismiss(animated: true, completion: nil)
        return
    }
    let identifiers = results.compactMap(\.assetIdentifier)
    guard let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil).firstObject else {
        webView.evaluateJavaScript("sendMeasureMessage('uncheckFinishedCheckbox','{};')", completionHandler: nil)
        picker.dismiss(animated: true, completion: nil)
        return
    }
    activityIndicator.updateIndicatorView(self, hidden: false)
    switch fetchResult.mediaType {
    case .image:
        AWSS3Manager.shared.getImage(.image, fetchResult) { [weak self] (image, uploadURL, _) in
            guard let this = self else { return }
            DispatchQueue.main.async {
              this.moveToUploadVideo(uploadURL, asset: fetchResult, image: image)
            }
        }
        
    default:
        AWSS3Manager.shared.getVideoData(.video, fetchResult) { [weak self] (uploadURL, createdDate) in
           guard let this = self else { return }
           DispatchQueue.main.async {
            this.moveToUploadVideo(uploadURL, asset: fetchResult, createdDate)
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

extension ExternalSurveyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerController(_ picker: UIImagePickerController,
                           didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    if let phAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
      updateAccordingToMediaType(picker, info, phAsset)
    }
}
    
func updateAccordingToMediaType(_ picker: UIImagePickerController,
                                _ info: [UIImagePickerController.InfoKey: Any],
                                _ phAsset: PHAsset) {
 switch phAsset.mediaType {
 case .image:
    guard let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
    AWSS3Manager.shared.getMediaAsset(.image, imageURL, imageURL.creationDate) { [weak self] (uploadURL, _) in
         guard let this = self else { return }
         DispatchQueue.main.async {
            this.moveToUploadVideo(uploadURL, asset: phAsset)
         }
    }
 default:
    guard let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
    AWSS3Manager.shared.getMediaAsset(.video, mediaURL, mediaURL.creationDate) { [weak self] (uploadURL, _) in
         guard let this = self else { return }
         DispatchQueue.main.async {
            this.moveToUploadVideo(uploadURL, asset: phAsset, phAsset.creationDate)
        }
     }
   }
   picker.dismiss(animated: true, completion: nil)
}
    
func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    webView.evaluateJavaScript("sendMeasureMessage('uncheckFinishedCheckbox','{};')", completionHandler: nil)
    picker.dismiss(animated: true, completion: nil)
   }
}
