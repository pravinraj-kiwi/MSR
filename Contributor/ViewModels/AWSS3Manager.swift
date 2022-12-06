//
//  AWSS3Manager.swift
//  AmazonS3Upload
//
//  Created by KiwiTech on 7/2/20.
//  Copyright © 2020 maximbilan. All rights reserved.
//

import Foundation
import UIKit
import AWSS3
import MediaPlayer
import SystemConfiguration
import Photos

typealias ProgressBlock = (_ progress: Double, _ transferState: AWSS3TransferUtilityMultiPartUploadTask) -> Void
typealias CompletionBlock = (_ response: AWSS3TransferUtilityMultiPartUploadTask?, _ error: Error?) -> Void

class AWSS3Manager {

static let shared = AWSS3Manager()
var reachability: Reachability?
private init () { }
let serverDateFormat = DateFormatType.serverDateFormat.rawValue
let normalDateFormat = DateFormatType.normalDateFormat.rawValue
let normalVideoDateFormat = DateFormatType.normalVideoDateFormat.rawValue
   // var currentTaskId = ""
// Upload video from local path url
 func uploadS3Data(bucketName: String, videoUrl: URL, fileName: String,
                   s3FolderName: String, contenType: String, progress: ProgressBlock?,
                   completion: CompletionBlock?) {
    self.uploadfile(bucketName: bucketName, fileUrl: videoUrl,
                    fileName: fileName, s3FolderName: s3FolderName,
                    contenType: contenType, progress: progress, completion: completion)
}

// fileUrl :  file local path url
// fileName : name of file, like "myimage.jpeg" "video.mov"
// contenType: file MIME type
// progress: file upload progress, value from 0 to 1, 1 for 100% complete
// completion: completion block when uplaoding is finish, you will get S3 url of upload file here
 private func uploadfile(bucketName: String, fileUrl: URL,
                         fileName: String, s3FolderName: String,
                         contenType: String, progress: ProgressBlock?,
                         completion: CompletionBlock?) {
    // Upload progress block
    let expression = AWSS3TransferUtilityMultiPartUploadExpression()
    expression.progressBlock = {(task, awsProgress) in
        guard let uploadProgress = progress else { return }
        DispatchQueue.main.async {
            uploadProgress(awsProgress.fractionCompleted, task)
        }
    }
    
    // Completion block
    var completionHandler: AWSS3TransferUtilityMultiPartUploadCompletionHandlerBlock?
    completionHandler = { (task, error) -> Void in
        DispatchQueue.main.async(execute: {
            if let completionBlock = completion {
                completionBlock(task, error)
            }
        })
    }
    // Start uploading using AWSS3TransferUtility
    let awsTransferUtility = AWSS3TransferUtility.default()
    let keyName = "\(s3FolderName)\(fileName)"
    awsTransferUtility.uploadUsingMultiPart(fileURL: fileUrl, bucket: bucketName,
                                            key: keyName, contentType: contenType,
                                            expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
        if let result = task.result {
            print("Your video is being uploading....")
            //self.currentTaskId = result.transferID
        }
        return nil
    }
}
    func cancelUpload() {
//        AWSS3TransferUtility.default().enumerateToAssignBlocks { (uploadTask, progress, error) in
//            debugPrint("AbC")
//        } multiPartUploadBlocksAssigner: { (task, progress, error) in
//            debugPrint("AAbC")
//            task.cancel()
//
//        } downloadBlocksAssigner: { (task, progress, error) in
//            debugPrint("AAAAAbC")
//
//        }
    }
    func cancel(taskIdentifier: UInt) {
       
     }
func getImageData(_ image: UIImage? = nil, _ strURL: URL? = nil,
                  _ creationDate: Date? = nil, _ callBack: @escaping (_ url: URL?, _ creationDate: Date?) -> Void) {
    
    guard let date = creationDate else { return }
    let dateStr = Utilities.convertDateToString(date: date, format: serverDateFormat,
                                                       outpuFormat: normalDateFormat)
    let createdDate = Utilities.convertDateFormat(inputDate: dateStr, inputDateFormat: normalDateFormat,
                                                                          outPutFormat: normalVideoDateFormat)
    let imagePath = NSTemporaryDirectory() + "Image\(createdDate).PNG"
    let imageURL = NSURL(fileURLWithPath: imagePath)
    if let imageUrl = strURL {
        let imageData = NSData(contentsOf: imageUrl)
        let writeResult = imageData?.write(to: imageURL as URL, atomically: true)
        if writeResult != nil {
            callBack(imageURL as URL, creationDate)
        }
    } else {
        let imageData = image?.pngData()
        do {
          try imageData?.write(to: imageURL as URL)
          callBack(imageURL as URL, creationDate)
        } catch {
          debugPrint("writing file error", error)
        }
    }
}
    
func getVideoAssetData(_ strURL: URL? = nil, _ callBack: @escaping (_ url: URL?, _ creationDate: Date?) -> Void) {
  if let creationDate = strURL?.creationDate {
    let dateStr = Utilities.convertDateToString(date: creationDate, format: serverDateFormat,
                                                    outpuFormat: normalDateFormat)
    let createdDate = Utilities.convertDateFormat(inputDate: dateStr, inputDateFormat: normalDateFormat,
                                                                       outPutFormat: normalVideoDateFormat)
    if let videoUrl = strURL {
        let videoData = NSData(contentsOf: videoUrl)
        let videoPath = NSTemporaryDirectory() + "Recording\(createdDate).MOV"
        let videoURL = NSURL(fileURLWithPath: videoPath)
        let writeResult = videoData?.write(to: videoURL as URL, atomically: true)
        if writeResult != nil {
            callBack(videoURL as URL, creationDate)
        }
    }
  }
}
    
func getMediaAsset(_ screenCaptureType: ScreenCaptureType, image: UIImage? = nil, _ strURL: URL? = nil,
                   _ creationDate: Date? = nil, _ callBack: @escaping (_ url: URL?, _ creationDate: Date?) -> Void) {
    switch screenCaptureType {
    case .image:
        getImageData(image, strURL, creationDate, callBack)
    default:
        getVideoAssetData(strURL, callBack)
  }
}
    
func getVideoData(_ screenCaptureType: ScreenCaptureType, _ asset: PHAsset,
                  _ callBack: @escaping (_ url: URL?, _ creationDate: Date?) -> Void) {
    let options = PHVideoRequestOptions()
    options.deliveryMode = PHVideoRequestOptionsDeliveryMode.automatic
    options.version = .current
    options.isNetworkAccessAllowed = true

    options.progressHandler = {  (progress, error, stop, info) in
       print("progress: \(progress)")
    }
    
    PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (asset, _, _) in
      if let strURL = (asset as? AVURLAsset)?.url {
          self.getMediaAsset(screenCaptureType, strURL) { (url, date) in
            callBack(url, date)
          }
        }
    }
}
    
func getImage(_ screenCaptureType: ScreenCaptureType, _ fetchResult: PHAsset,
              completion: @escaping (_ image: UIImage?, _ url: URL?, _ creationDate: Date?) -> Void) {
        PHImageManager.default().requestImage(for: fetchResult,
                                          targetSize: CGSize(width: 116, height: 112),
                                          contentMode: PHImageContentMode.aspectFit,
                                          options: nil) { (image: UIImage?, _: [AnyHashable: Any]?) in
        self.getMediaAsset(screenCaptureType, image: image, nil, fetchResult.creationDate) { (url, date) in
            completion(image, url, date)
        }
     }
  }
}
