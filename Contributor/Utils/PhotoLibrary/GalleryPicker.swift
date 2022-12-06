//
//  GalleryPicker.swift
//  Contributor
//
//  Created by KiwiTech on 8/18/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class GalleryPicker {

func openOldGallery(_ captureType: ScreenCaptureType, _ ctrl: UIViewController) {
  if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
      let imagePicker = UIImagePickerController()
      imagePicker.allowsEditing = false
      imagePicker.delegate = ctrl as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
      imagePicker.presentationController?.delegate = ctrl as? UIAdaptivePresentationControllerDelegate
      if captureType == .image {
        imagePicker.mediaTypes = [Cameraman.mediaImageType]
      } else {
        imagePicker.mediaTypes = [Cameraman.mediaType]
      }
      imagePicker.sourceType = .savedPhotosAlbum
      imagePicker.isModalInPresentation = true
      imagePicker.modalPresentationStyle = .fullScreen
      DispatchQueue.main.async {
        ctrl.present(imagePicker, animated: true, completion: nil)
      }
    }
}
  
func openGallery(captureType: ScreenCaptureType, ctrl: UIViewController) {
  if #available(iOS 14, *) {
      let photoLibrary = PHPhotoLibrary.shared()
      var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
      configuration.selectionLimit = 1
      if captureType == .image {
        configuration.filter = .any(of: [.images, .livePhotos])
      } else {
        configuration.filter = .any(of: [.videos])
      }
      DispatchQueue.main.async {
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = ctrl as? PHPickerViewControllerDelegate
        picker.presentationController?.delegate = ctrl as? UIAdaptivePresentationControllerDelegate
        ctrl.present(picker, animated: true, completion: nil)
      }
   } else {
      self.openOldGallery(captureType, ctrl)
    }
  }
}
