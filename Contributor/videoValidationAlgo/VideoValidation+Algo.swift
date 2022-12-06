//
//  ViewController+Algo.swift
//  videoTest
//
//  Created by KiwiTech on 9/8/20.
//  Copyright © 2020 KiwiTech. All rights reserved.
//

import UIKit

extension VideoValidation {
    
//Check For mid index
func binarySearch(imageUrls: [URL], minimumIndex: Int,
                  maximumIndex: Int, completion: @escaping (Bool, Int, [CameramanTestModel]?, Bool) -> Void) {
  if timeout {
    completion(false, -1, [], false)
    return
  }
  let midIndex = (minimumIndex + maximumIndex) / 2
  let hasFoundedTextOnMiddle = checkForMiddle(imageUrls: imageUrls, midIndex: midIndex)
    if hasFoundedTextOnMiddle.0 {
        completion(hasFoundedTextOnMiddle.0, midIndex, hasFoundedTextOnMiddle.1, hasFoundedTextOnMiddle.2)
  } else {
    if timeout {
      completion(false, -1, [], false)
      return
    }
    let initialIndex = (imageUrls.count/2)
    let endIndex = (midIndex + (imageUrls.count - 1))/2
    let hasFoundedTextOnRight = checkForRight(imageUrls: imageUrls,
                                              middleIndex: initialIndex, maximumIndex: endIndex)
    completion(hasFoundedTextOnRight.0, midIndex, hasFoundedTextOnRight.1, hasFoundedTextOnRight.2)
  }
}
    
//Check For Middle index
    func checkForMiddle(imageUrls: [URL], midIndex: Int) -> (Bool, [CameramanTestModel], Bool) {
        var middleTextArray = [String]()
        var hasFoundTextOnMiddle = false
        var hasNegativeMarkersFoundOnMiddleMode = false
        
        if timeout {
            return (false, cameraTestModelArray, hasNegativeMarkersFoundOnMiddleMode)
        }
        performOCR(on: imageUrls[midIndex], recognitionLevel: .accurate) { (FoundedTextArrayOnMiddle) in
            middleTextArray = FoundedTextArrayOnMiddle
        }
        if timeout {
            hasFoundTextOnMiddle = false
        }
        let middleString = middleTextArray.joined(separator: ",").lowercased()
        if fileContentType == CameramanValidation.mediaFileContent, let marker = targetV1Value {
            if searchStringForV1(ocrString: middleString, marker) {
                hasFoundTextOnMiddle = true
                hasNegativeMarkersFoundOnMiddleMode = false
                updateModelForTestUser(imageUrls,
                                       index: midIndex,
                                       extractStr: middleTextArray,
                                       hasFoundText: hasFoundTextOnMiddle,
                                       negativeMarkers: nil)
            } else {
                hasNegativeMarkersFoundOnMiddleMode = false
                updateModelForTestUser(imageUrls,
                                       index: midIndex,
                                       extractStr: middleTextArray,
                                       negativeMarkers: nil)
            }
        } else if fileContentType == CameramanValidation.mediaFileContentv4, let negativeMarker = negativeMarkersValue {
            /// check for negative markers notpresence if found then go back with error else proceed with markers validation
            if searchStringForV1(ocrString: middleString, negativeMarker) {
                debugPrint("Negative markers are found")
                hasFoundTextOnMiddle = true
                hasNegativeMarkersFoundOnMiddleMode = true
                updateModelForTestUser(imageUrls,
                                       index: midIndex,
                                       extractStr: middleTextArray,
                                       hasFoundText: hasFoundTextOnMiddle,
                                       negativeMarkers: negativeMarker)
              //  break
            } else {
                hasNegativeMarkersFoundOnMiddleMode = false
                hasFoundTextOnMiddle = searchStringForV2(ocrString: middleString)
                if hasFoundTextOnMiddle {
                    updateModelForTestUser(imageUrls,
                                           index: midIndex,
                                           extractStr: middleTextArray,
                                           hasFoundText: hasFoundTextOnMiddle,
                                           negativeMarkers: nil)
                } else {
                    updateModelForTestUser(imageUrls,
                                           index: midIndex,
                                           extractStr: middleTextArray,
                                           negativeMarkers: nil)
                }
            }
        } else {
            hasNegativeMarkersFoundOnMiddleMode = false
            hasFoundTextOnMiddle = searchStringForV2(ocrString: middleString)
            if hasFoundTextOnMiddle {
                updateModelForTestUser(imageUrls,
                                       index: midIndex,
                                       extractStr: middleTextArray,
                                       hasFoundText: hasFoundTextOnMiddle,
                                       negativeMarkers: nil)
            } else {
                updateModelForTestUser(imageUrls,
                                       index: midIndex,
                                       extractStr: middleTextArray,
                                       negativeMarkers: nil)
            }
        }
        return (hasFoundTextOnMiddle, cameraTestModelArray, hasNegativeMarkersFoundOnMiddleMode)
    }

//Check For right index
func checkForRight(imageUrls: [URL],
                   middleIndex: Int, maximumIndex: Int) -> (Bool, [CameramanTestModel], Bool) {
    var rightTextArray = [String]()
    var hasFoundTextOnRight = false
    var initialIndex = middleIndex
    var hasNegativeMarkersFoundOnRightMode = false
    if timeout {
        return (false, cameraTestModelArray, hasNegativeMarkersFoundOnRightMode)
    }
    while initialIndex <= maximumIndex {
        if timeout {
            hasFoundTextOnRight = false
            break
        }
        performOCR(on: imageUrls[initialIndex], recognitionLevel: .accurate) { (FoundedTextArrayOnLeft) in
            rightTextArray = FoundedTextArrayOnLeft
        }
        if timeout {
            hasFoundTextOnRight = false
            break
        }
        let rightString = rightTextArray.joined(separator: ",").lowercased()
        if fileContentType == CameramanValidation.mediaFileContent, let marker = targetV1Value {
            if searchStringForV1(ocrString: rightString, marker) {
                hasFoundTextOnRight = true
                hasNegativeMarkersFoundOnRightMode = false
                updateModelForTestUser(imageUrls,
                                       index: initialIndex,
                                       extractStr: rightTextArray,
                                       hasFoundText: hasFoundTextOnRight,
                                       negativeMarkers: nil)
                break
            } else {
                hasNegativeMarkersFoundOnRightMode = false
                updateModelForTestUser(imageUrls,
                                       index: initialIndex,
                                       extractStr: rightTextArray,
                                       negativeMarkers: nil)
            }
        } else if fileContentType == CameramanValidation.mediaFileContentv4, let negativeMarker = negativeMarkersValue {
            /// check for negative markers notpresence if found then go back with error else proceed with markers validation
            if searchStringForV1(ocrString: rightString, negativeMarker) {
                debugPrint("Negative markers are found")
                hasFoundTextOnRight = true
                hasNegativeMarkersFoundOnRightMode = true
                updateModelForTestUser(imageUrls,
                                       index: initialIndex,
                                       extractStr: rightTextArray,
                                       hasFoundText: hasFoundTextOnRight,
                                       negativeMarkers: negativeMarker)
                break
            } else {
                hasNegativeMarkersFoundOnRightMode = false
                if searchStringForV2(ocrString: rightString) {
                    hasFoundTextOnRight = true
                    updateModelForTestUser(imageUrls,
                                           index: initialIndex,
                                           extractStr: rightTextArray,
                                           hasFoundText: hasFoundTextOnRight,
                                           negativeMarkers: nil)
                    break
                } else {
                    updateModelForTestUser(imageUrls,
                                           index: initialIndex,
                                           extractStr: rightTextArray,
                                           negativeMarkers: nil)
                }
            }
        } else {
            hasNegativeMarkersFoundOnRightMode = false
            if searchStringForV2(ocrString: rightString) {
                hasFoundTextOnRight = true
                updateModelForTestUser(imageUrls,
                                       index: initialIndex,
                                       extractStr: rightTextArray,
                                       hasFoundText: hasFoundTextOnRight,
                                       negativeMarkers: nil)
                break
            } else {
                updateModelForTestUser(imageUrls,
                                       index: initialIndex,
                                       extractStr: rightTextArray,
                                       negativeMarkers: nil)
            }
        }
        initialIndex+=1
    }
    return (hasFoundTextOnRight, cameraTestModelArray, hasNegativeMarkersFoundOnRightMode)
}
    
//Check For left index
func checkForLeft(imageUrls: [URL],
                  minIndex: Int, maxLeftIndex: Int) -> (Bool, [CameramanTestModel], Bool) {
  var leftTextArray = [String]()
  var hasFoundTextOnLeft = false
  var initialLeftIndex = minIndex
   var hasNegativeMarkersFoundOnLeftMode = false
  if timeout {
    return (false, cameraTestModelArray, hasNegativeMarkersFoundOnLeftMode)
  }
 while initialLeftIndex >= maxLeftIndex {
   if timeout {
    hasFoundTextOnLeft = false
    break
  }
  performOCR(on: imageUrls[initialLeftIndex], recognitionLevel: .accurate) { (FoundedTextArrayOnLeft) in
    leftTextArray = FoundedTextArrayOnLeft
  }
  if timeout {
    hasFoundTextOnLeft = false
    break
  }
  let leftString = leftTextArray.joined(separator: ",").lowercased()
  if fileContentType == CameramanValidation.mediaFileContent, let marker = targetV1Value {
    hasNegativeMarkersFoundOnLeftMode = false
     if searchStringForV1(ocrString: leftString, marker) {
        hasFoundTextOnLeft = true
        updateModelForTestUser(imageUrls,
                               index: initialLeftIndex,
                               extractStr: leftTextArray,
                               hasFoundText: hasFoundTextOnLeft,
                               negativeMarkers: nil)
        break
     } else {
        updateModelForTestUser(imageUrls,
                               index: initialLeftIndex,
                               extractStr: leftTextArray,
                               negativeMarkers: nil)
     }
  } else if fileContentType == CameramanValidation.mediaFileContentv4, let negativeMarker = negativeMarkersValue {
   /// check for negative markers notpresence if found then go back with error else proceed with markers validation
    if searchStringForV1(ocrString: leftString, negativeMarker) {
        debugPrint("Negative markers are found")
        hasFoundTextOnLeft = true
        hasNegativeMarkersFoundOnLeftMode = true
        updateModelForTestUser(imageUrls,
                               index: initialLeftIndex,
                               extractStr: leftTextArray,
                               hasFoundText: hasFoundTextOnLeft,
                               negativeMarkers: negativeMarker)
        break
    } else {
        hasNegativeMarkersFoundOnLeftMode = false
        if searchStringForV2(ocrString: leftString) {
            hasFoundTextOnLeft = true
            updateModelForTestUser(imageUrls,
                                   index: initialLeftIndex,
                                   extractStr: leftTextArray,
                                   hasFoundText: hasFoundTextOnLeft,
                                   negativeMarkers: nil)
            break
        } else {
            updateModelForTestUser(imageUrls,
                                   index: initialLeftIndex,
                                   extractStr: leftTextArray,
                                   negativeMarkers: nil)
         }
    }
  } else {
    hasNegativeMarkersFoundOnLeftMode = false

    if searchStringForV2(ocrString: leftString) {
        hasFoundTextOnLeft = true
        updateModelForTestUser(imageUrls,
                               index: initialLeftIndex,
                               extractStr: leftTextArray,
                               hasFoundText: hasFoundTextOnLeft,
                               negativeMarkers: nil)
        break
    } else {
        updateModelForTestUser(imageUrls,
                               index: initialLeftIndex,
                               extractStr: leftTextArray,
                               negativeMarkers: nil)
     }
   }
   initialLeftIndex-=1
 }
 return (hasFoundTextOnLeft, cameraTestModelArray, hasNegativeMarkersFoundOnLeftMode)
}
    
func searchStringForV1(ocrString: String, _ marker: [String]) -> Bool {
  var hasFoundText = false
  var doesContainAllText: Int = 0
  var targetIndex: Int = 0
  while targetIndex < marker.count {
    if timeout {
      hasFoundText = false
      break
    }
    let searchString = marker[targetIndex].lowercased()
    if ocrString.contains(searchString) {
      doesContainAllText+=1
    }
   targetIndex+=1
  }
  if doesContainAllText == marker.count {
    hasFoundText = true
  }
  return hasFoundText
}
    
func searchStringForV2(ocrString: String) -> Bool {
  var targetIndex: Int = 0
  var hasFoundText = false
  guard let targetText = targetValue else { return hasFoundText }
  while targetIndex < targetText.count {
    if timeout {
     hasFoundText = false
     break
    }
    let targetString = targetText[targetIndex]
    if searchStringForV1(ocrString: ocrString, targetString) {
       hasFoundText = true
       break
    }
    targetIndex+=1
   }
   return hasFoundText
  }
}
