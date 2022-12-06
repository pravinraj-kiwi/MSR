//
//  PhotoLibraryPermissions.swift
//  Contributor
//
//  Created by KiwiTech on 7/14/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Photos

public extension PHPhotoLibrary {

   static func execute(controller: UIViewController,
                       onAccessHasBeenGranted: @escaping () -> Void,
                       onAccessHasBeenLimited: @escaping () -> Void,
                       onAccessHasBeenDenied: (() -> Void)? = nil) {
      let onDeniedOrRestricted = onAccessHasBeenDenied ?? {
        DispatchQueue.main.async {
         let alert = UIAlertController(
            title: PhotoPermissionAlertText.title.localized(),
            message: PhotoPermissionAlertText.message.localized(),
            preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Text.cancel.localized(),
                                       style: .cancel, handler: { _ in
             NotificationCenter.default.post(name: NSNotification.Name.dismissSurveyPage,
                                             object: nil)
         }))
         alert.addAction(UIAlertAction(title: PhotoPermissionAlertText.settings.localized(),
                                       style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
               UIApplication.shared.open(settingsURL)
            }
         }))
         controller.present(alert, animated: true)
      }
    }
    var status = PHPhotoLibrary.authorizationStatus()
    if #available(iOS 14, *) {
        status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    switch status {
    case .notDetermined:
       onNotDetermined(onDeniedOrRestricted, onAccessHasBeenGranted)
    case .denied, .restricted:
       onDeniedOrRestricted()
    case .authorized:
        onAccessHasBeenGranted()
    case .limited:
        onAccessHasBeenLimited()
    @unknown default:
       fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
    }
  }
}

private func onNotDetermined(_ onDeniedOrRestricted: @escaping (() -> Void),
                             _ onAuthorized: @escaping (() -> Void)) {
   PHPhotoLibrary.requestAuthorization({ status in
      switch status {
      case .notDetermined:
         onNotDetermined(onDeniedOrRestricted, onAuthorized)
      case .denied, .restricted:
         onDeniedOrRestricted()
      case .authorized:
         onAuthorized()
      @unknown default:
         fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
      }
   })
}
