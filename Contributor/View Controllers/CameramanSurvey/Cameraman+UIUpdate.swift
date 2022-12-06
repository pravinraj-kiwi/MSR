//
//  Cameraman+UIUpdate.swift
//  Contributor
//
//  Created by KiwiTech on 9/14/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Photos
import SwiftyUserDefaults

extension CameramanViewController {
func updateUI(_ screenCaptureType: ScreenCaptureType, asset: PHAsset? = nil,
              uploadURL: URL?, date: Date?, fileName: String = "", image: UIImage? = nil) {
  if let createdDate = date {
    self.selectedDateTime = createdDate
    let dateStr = Utilities.convertDateToString(date: createdDate, format: serverDateFormat)
    self.recentVideoDate.text = Utilities.convertDateFormat(inputDate: dateStr,
                                                                inputDateFormat: shortDateFormat,
                                                                outPutFormat: shortStyleFormat)
    }
    if let url = uploadURL {
        self.selectedVideoURL = url
        self.recentVideoSize.text = url.filesizeNicelyformatted
        if let size = url.filesize {
          let bcf = ByteCountFormatter()
          bcf.allowedUnits = [.useMB]
          bcf.countStyle = .file
          let mbSize = bcf.string(fromByteCount: Int64(size))
          Defaults[.retroVideoFileSize] = mbSize
        }
    }
    switch screenCaptureType {
    case .image:
        if let asset = asset {
          getSizeOfImage(asset)
        }
        if image == nil, let asset = asset {
            PHImageManager.default().requestImage(for: asset,
                                              targetSize: CGSize(width: 116, height: 112),
                                              contentMode: PHImageContentMode.aspectFit,
                                              options: nil) { (image: UIImage?, _: [AnyHashable: Any]?) in
                self.recentVideoImageView.image = image
            }
        } else {
            self.recentVideoImageView.image = image
        }
        let name = uploadURL?.lastPathComponent
        self.recentVideoTitle.text = name

    case .video:
      if let url = uploadURL {
       let asset = AVAsset(url: url)
       if let videoThumbnail = asset.videoThumbnail {
         recentVideoImageView.image = videoThumbnail
        }
     }
     let name = uploadURL?.lastPathComponent
     recentVideoTitle.text = name
   
    case .file:
        recentVideoImageView.contentMode = .scaleAspectFit
        recentVideoImageView.image = Image.filePlaceholder.value
        recentVideoTitle.text = fileName
    }
}
    
func getImageSize(_ asset: PHAsset) -> Int64 {
  let resources = PHAssetResource.assetResources(for: asset)
  var sizeOnDisk: Int64 = 0
  if let resource = resources.first {
    let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
    sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
  }
  return sizeOnDisk
}
    
func getSizeOfImage(_ asset: PHAsset) {
  let sizeOnDisk = getImageSize(asset)
  let size = ByteCountFormatter.init().string(fromByteCount: sizeOnDisk)
  self.recentVideoSize.text = size
  let bcf = ByteCountFormatter()
  bcf.allowedUnits = [.useMB]
  bcf.countStyle = .file
  let mbSize = bcf.string(fromByteCount: sizeOnDisk)
  Defaults[.retroVideoFileSize] = mbSize
}

func getConvertedFileSize(_ fileSize: Int, _ fileSizeType: String) -> Int {
    switch fileSizeType {
    case "KB":
        return fileSize / 1024
    case "MB":
        return fileSize / (1024*1024)
    case "GB":
        return fileSize / (1024*1024*1024)
    default:
        break
    }
    return fileSize
 }
}

extension UIView {
func viewShadow(color: UIColor) {
    layer.masksToBounds = false
    layer.cornerRadius = 7.0
    layer.backgroundColor = UIColor.white.cgColor
    layer.borderColor = UIColor.clear.cgColor
    layer.shadowColor = color.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.shadowOpacity = 0.07
    layer.shadowRadius = 10
  }
}

extension CameramanViewController: UIDocumentPickerDelegate {
func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
   errorView.isHidden = true
   confirmUploadButton.setTitle(Cameraman.confirmUpload.localized(), for: .normal)
   selectedVideoURL = urls[0]
   guard let attributes = try? urls[0].resourceValues(forKeys: [.contentModificationDateKey, .nameKey]) else { return }
   self.updateUI(.file, uploadURL: urls[0], date: attributes.contentModificationDate,
                  fileName: attributes.name ?? urls[0].lastPathComponent)
}

func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {}
}
