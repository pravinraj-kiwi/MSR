//
//  CameramanView+CompressVideo.swift
//  Contributor
//
//  Created by KiwiTech on 1/11/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit

extension CameramanViewController {
   
func uploadCompressedVideo() {
  hasSkipContentValidation = true
  if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
  }
  guard let url = selectedVideoURL else {
    showErrorIfMediaResponseFail()
    return
  }
  compressedVideo(url)
}
    
func compressedVideo(_ selectedUrl: URL) {
    activityIndicator.updateIndicatorView(self, hidden: false)
  let videoCompressor = LightCompressor()
  let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressed", isDirectory: true)
    do {
        try FileManager.default.createDirectory(at: destinationPath, withIntermediateDirectories: true, attributes: nil)
    } catch {}
  videoCompressor.compressVideo(
    source: selectedUrl, destination: destinationPath.appendingPathComponent(selectedUrl.lastPathComponent) as URL,
              quality: .medium, isMinBitRateEnabled: true,
              keepOriginalResolution: false,
              completion: {[weak self] result in
                  guard let this = self else { return }
                  switch result {
                  case .onSuccess(let path):
                      // success
                    DispatchQueue.main.async {
                      this.activityIndicator.updateIndicatorView(this, hidden: true)
                      Utilities.clearAllDataFrom(folderName: Constants.framePath)
                      this.callMediaUploadingAPI(path as URL)
                    }
                  case .onStart: break
                      // when compression starts
                  case .onFailure(_):
                      // failure error
                      this.showErrorIfMediaResponseFail()
                  case .onCancelled: break
                      // if cancelled
                  }
              }
           )
    }
}
