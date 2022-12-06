//
//  VideoValidation+Mode.swift
//  Contributor
//
//  Created by KiwiTech on 9/17/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Kingfisher

extension VideoValidation {
    
    func searchTextFromTheImages(modeType: ModeType, imageUrls: [URL],
                                 completion: @escaping (Bool, String, [CameramanTestModel]?, Bool) -> Void) {
        if timeout {
            completion(false, "timeOut", [], false)
            return
        }
        switch modeType {
        case .left:
            let hasTargetOnLeft = modeLeft(imageUrls)
            completion(hasTargetOnLeft.0, "", hasTargetOnLeft.1, hasTargetOnLeft.2)
        case .right:
            let hasTargetOnRight = modeRight(imageUrls)
            completion(hasTargetOnRight.0, "", hasTargetOnRight.1, hasTargetOnRight.2)
        default:
            modeMiddle(imageUrls) { (isTextFounded, _, testCameramanArray, isNegativeMarkerFound) in
                completion(isTextFounded, "", testCameramanArray, isNegativeMarkerFound)
            }
        }
    }
    
    func modeLeft(_ imageUrls: [URL]) -> (Bool, [CameramanTestModel], Bool) {
        var initialIndex = 0
        let endIndex = imageUrls.count / 2
        var leftModeTextArray = [String]()
        var hasFoundTextOnLeftMode = false
        var hasNegativeMarkersFoundOnLeftMode = false
        
        if timeout {
            return (false, cameraTestModelArray, false)
        }
        while initialIndex <= endIndex {
            if timeout {
                hasFoundTextOnLeftMode = false
                break
            }
            performOCR(on: imageUrls[initialIndex], recognitionLevel: .accurate) { (FoundedTextArrayOnLeftMode) in
                leftModeTextArray = FoundedTextArrayOnLeftMode
            }
            if timeout {
                hasFoundTextOnLeftMode = false
                break
            }
            let leftString = leftModeTextArray.joined(separator: ",").lowercased()
            if fileContentType == CameramanValidation.mediaFileContent, let marker = targetV1Value {
                if searchStringForV1(ocrString: leftString, marker) {
                    hasFoundTextOnLeftMode = true
                    hasNegativeMarkersFoundOnLeftMode = false
                    updateModelForTestUser(imageUrls, index: initialIndex,
                                           extractStr: leftModeTextArray,
                                           hasFoundText: hasFoundTextOnLeftMode,
                                           negativeMarkers: nil)
                    break
                } else {
                    hasNegativeMarkersFoundOnLeftMode = false
                    updateModelForTestUser(imageUrls,
                                           index: initialIndex,
                                           extractStr: leftModeTextArray,
                                           negativeMarkers: nil)
                }
            } else if fileContentType == CameramanValidation.mediaFileContentv4, let negativeMarker = negativeMarkersValue {
                /// check for negative markers notpresence if found then go back with error else proceed with markers validation
                if searchStringForV1(ocrString: leftString, negativeMarker) {
                    debugPrint("Negative markers are found")
                    hasFoundTextOnLeftMode = true
                    hasNegativeMarkersFoundOnLeftMode = true
                    updateModelForTestUser(imageUrls,
                                           index: initialIndex,
                                           extractStr: leftModeTextArray,
                                           hasFoundText: hasFoundTextOnLeftMode, negativeMarkers: negativeMarker)
                    break
                } else {
                    if searchStringForV2(ocrString: leftString) {
                        hasFoundTextOnLeftMode = true
                        hasNegativeMarkersFoundOnLeftMode = false
                        updateModelForTestUser(imageUrls,
                                               index: initialIndex,
                                               extractStr: leftModeTextArray,
                                               hasFoundText: hasFoundTextOnLeftMode, negativeMarkers: nil)
                        break
                    } else {
                        hasNegativeMarkersFoundOnLeftMode = false
                        updateModelForTestUser(imageUrls,
                                               index: initialIndex,
                                               extractStr: leftModeTextArray,
                                               negativeMarkers: nil)
                    }
                }
            } else {
                if searchStringForV2(ocrString: leftString) {
                    hasFoundTextOnLeftMode = true
                    hasNegativeMarkersFoundOnLeftMode = false
                    updateModelForTestUser(imageUrls,
                                           index: initialIndex,
                                           extractStr: leftModeTextArray,
                                           hasFoundText: hasFoundTextOnLeftMode,
                                           negativeMarkers: nil)
                    break
                } else {
                    hasNegativeMarkersFoundOnLeftMode = false
                    updateModelForTestUser(imageUrls,
                                           index: initialIndex,
                                           extractStr: leftModeTextArray,
                                           negativeMarkers: nil)
                }
            }
            initialIndex+=1
        }
        return (hasFoundTextOnLeftMode, cameraTestModelArray, hasNegativeMarkersFoundOnLeftMode)
    }
    
    func modeRight(_ imageUrls: [URL]) -> (Bool, [CameramanTestModel], Bool) {
        var middleIndex = imageUrls.count / 2
        let endIndex = imageUrls.count - 1
        var rightModeTextArray = [String]()
        var hasFoundTextOnRightMode = false
        var hasNegativeMarkersFoundOnRightMode = false
        if timeout {
            return (false, cameraTestModelArray, hasNegativeMarkersFoundOnRightMode)
        }
        while middleIndex <= endIndex {
            if timeout {
                hasFoundTextOnRightMode = false
                break
            }
            performOCR(on: imageUrls[middleIndex], recognitionLevel: .accurate) { (FoundedTextArrayOnRightMode) in
                rightModeTextArray = FoundedTextArrayOnRightMode
            }
            if timeout {
                hasFoundTextOnRightMode = false
                break
            }
            let rightString = rightModeTextArray.joined(separator: ",").lowercased()
            if fileContentType == CameramanValidation.mediaFileContent, let marker = targetV1Value {
                if searchStringForV1(ocrString: rightString, marker) {
                    hasFoundTextOnRightMode = true
                    hasNegativeMarkersFoundOnRightMode = false
                    updateModelForTestUser(imageUrls,
                                           index: middleIndex,
                                           extractStr: rightModeTextArray,
                                           hasFoundText: hasFoundTextOnRightMode,
                                           negativeMarkers: nil)
                    break
                } else {
                    hasNegativeMarkersFoundOnRightMode = false
                    updateModelForTestUser(imageUrls,
                                           index: middleIndex,
                                           extractStr: rightModeTextArray,
                                           negativeMarkers: nil)
                }
            } else if fileContentType == CameramanValidation.mediaFileContentv4, let negativeMarker = negativeMarkersValue {
                /// check for negative markers not presence if found then go back with error else proceed with markers validation
                if searchStringForV1(ocrString: rightString, negativeMarker) {
                    debugPrint("Negative markers are found")
                    hasFoundTextOnRightMode = true
                    hasNegativeMarkersFoundOnRightMode = true
                    updateModelForTestUser(imageUrls,
                                           index: middleIndex,
                                           extractStr: rightModeTextArray,
                                           hasFoundText: hasFoundTextOnRightMode,
                                           negativeMarkers: negativeMarker)
                    break
                } else {
                    if searchStringForV2(ocrString: rightString) {
                        hasFoundTextOnRightMode = true
                        hasNegativeMarkersFoundOnRightMode = false
                        updateModelForTestUser(imageUrls,
                                               index: middleIndex,
                                               extractStr: rightModeTextArray,
                                               hasFoundText: hasFoundTextOnRightMode,
                                               negativeMarkers: nil)
                        break
                    } else {
                        hasNegativeMarkersFoundOnRightMode = false
                        updateModelForTestUser(imageUrls,
                                               index: middleIndex,
                                               extractStr: rightModeTextArray,
                                               negativeMarkers: nil)
                    }
                }
            } else {
                if searchStringForV2(ocrString: rightString) {
                    hasFoundTextOnRightMode = true
                    hasNegativeMarkersFoundOnRightMode = false
                    updateModelForTestUser(imageUrls,
                                           index: middleIndex,
                                           extractStr: rightModeTextArray,
                                           hasFoundText: hasFoundTextOnRightMode,
                                           negativeMarkers: nil)
                    break
                } else {
                    hasNegativeMarkersFoundOnRightMode = false
                    updateModelForTestUser(imageUrls,
                                           index: middleIndex,
                                           extractStr: rightModeTextArray,
                                           negativeMarkers: nil)
                }
            }
            middleIndex+=1
        }
        return (hasFoundTextOnRightMode, cameraTestModelArray, hasNegativeMarkersFoundOnRightMode)
    }
    
    func modeMiddle(_ imageUrls: [URL], completion: @escaping (Bool, String, [CameramanTestModel], Bool) -> Void) {
        binarySearch(imageUrls: imageUrls, minimumIndex: 0,
                     maximumIndex: (imageUrls.count - 1)) { [weak self] (founded, _, testCameramanArray, isNegativeMarkerFound) in
            guard let this = self else { return }
            if founded {
                completion(founded, "", testCameramanArray ?? [], isNegativeMarkerFound)
            } else {
                let initialIndex = ((imageUrls.count - 1)/2) - 1
                let endIndex = (imageUrls.count/2)/2
                let hasFoundedTextOnLeft = this.checkForLeft(imageUrls: imageUrls,
                                                             minIndex: initialIndex, maxLeftIndex: endIndex)
                completion(hasFoundedTextOnLeft.0, "", hasFoundedTextOnLeft.1, hasFoundedTextOnLeft.2)
            }
        }
    }
    
    func updateModelForTestUser(_ imageUrls: [URL],
                                index: Int,
                                extractStr: [String],
                                hasFoundText: Bool = false,
                                negativeMarkers: [String]?) {
        if UserManager.shared.user?.isTestUser == true {
            var cameraTestModel = CameramanTestModel()
            cameraTestModel.extractedImage = imageUrls[index]
            cameraTestModel.extractedText = extractStr
            cameraTestModel.extractedIndex = index
            cameraTestModel.validationPassed = hasFoundText
            if let _ = negativeMarkers {
                cameraTestModel.isNegativeMarker = true
            }
           // cameraTestModel.isne = negativeMarkers
            self.cameraTestModelArray.append(cameraTestModel)
        }
    }
}
