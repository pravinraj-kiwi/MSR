//
//  VideoValidation.swift
//  Contributor
//
//  Created by KiwiTech on 9/14/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import ImageIO
import AVFoundation
import VisionKit
import Vision

class VideoValidation {
    
var timeout = false
let selectedVideoUrl: URL?
var targetValue: [[String]]? = []
var targetV1Value: [String]? = []
var fileContentType: String
var cameraTestModelArray = [CameramanTestModel]()
var negativeMarkersValue: [String]? = []
    
    init(contentType: String, videoUrl: URL, markers: [[String]]?, v1markers: [String]?, negativeMarker: [String]?) {
  self.selectedVideoUrl = videoUrl
  self.targetValue = markers
  self.targetV1Value = v1markers
  self.fileContentType = contentType
  self.negativeMarkersValue = negativeMarker
  NotificationCenter.default.addObserver(self, selector: #selector(updateTimeOutVariable),
                                         name: NSNotification.Name.validationTimeOut, object: nil)
}
    
@objc func updateTimeOutVariable() {
    timeout = true
}
    
func getImagesFromVideo(completion: @escaping ([URL]) -> Void) {
 if timeout {
  completion([])
  return
 }
 if let videoURL = selectedVideoUrl {
  let asset = AVAsset(url: videoURL)

  let duration = asset.duration
  let durationTime = CMTimeGetSeconds(duration)
  let durationInt: Int = Int(durationTime)

 if timeout {
  completion([])
  return
 }
 calculateNumberOfFrames(asset, videoDuration: durationInt,
                        videoURL: videoURL) { (imageURL) in
    completion(imageURL)
   }
  }
}

func calculateNumberOfFrames(_ asset: AVAsset, videoDuration: Int,
                             videoURL: URL, completion: @escaping ([URL]) -> Void) {
 if let fps = asset.fps?.rounded() {
   let intFps = Int(fps)
    
   let frameSkipFactor = Int(fps / 2)

   let numOfFrames = (videoDuration * intFps) / frameSkipFactor
   debugPrint("NumOfFrames: \(numOfFrames)")

   if timeout {
    completion([])
    return
  }
  extractImages(videoURL, intFps, numOfFrames) {(imageUrls) in
    completion(imageUrls)
   }
 }
}

func extractImages(_ videoURL: URL, _ fps: Int,
                   _ noOfFrames: Int, completion: @escaping ([URL]) -> Void) {
  if timeout {
    completion([])
    return
  }
 let request = NSFrameExtractingRequest.init()
 request.sourceVideoFile = videoURL
 request.scalePreset = .high
 request.frameCount = UInt(noOfFrames)
 request.framesPerSecond = UInt(fps)

 if timeout {
    completion([])
    return
 }
 NSGIF.extract(request) { (response) in
    guard let responseData = response else {
        completion([])
        return
    }
    guard let images = responseData.imageUrls else {
        completion([])
        return
    }
    completion(images)
  }
}
    
func videoValidationProcess(_ mode: ModeType,
                            completion: @escaping (Bool, String, [CameramanTestModel]?, Bool) -> Void) {
  if timeout {
    completion(false, "Operation time out", [], false)
    return
  }
  self.getImagesFromVideo { (imageUrls) in
    if self.timeout {
        completion(false, "Operation time out", [], false)
        return
    }
    debugPrint("ImageUrl Count: \(imageUrls.count)")
    if imageUrls.isEmpty {
      completion(false, "", [], false)
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
        self.searchTextFromTheImages(modeType: mode, imageUrls: imageUrls) { (hasFounded, outcomeString, testCameramanArray, isNegativeMarkerFound) in
            completion(hasFounded, outcomeString, testCameramanArray, isNegativeMarkerFound)
          }
    }

   }
}

deinit {
    NotificationCenter.default.removeObserver(self)
 }
}

extension VideoValidation {
func performOCR(on url: URL?, recognitionLevel: VNRequestTextRecognitionLevel,
                completion: @escaping ([String]) -> Void) {
    if timeout {
        completion([])
        return
    }
    guard let url = url else { return }
    var targetValues = [String]()
    let requestHandler = VNImageRequestHandler(url: url, options: [:])
    let request = VNRecognizeTextRequest { (request, error) in
        if let _ = error {
            return
        }
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        for currentObservation in observations {
            if self.timeout {
                completion([])
                break
            }
            let topCandidate = currentObservation.topCandidates(1)
            if let recognizedText = topCandidate.first {
                targetValues.append(recognizedText.string)
            }
        }
        completion(targetValues)
    }
    request.recognitionLevel = recognitionLevel
    request.usesLanguageCorrection = false
    try? requestHandler.perform([request])
  }
}

extension AVAsset {
   var fps: Float? {
      self.tracks(withMediaType: .video).first?.nominalFrameRate
   }
}
