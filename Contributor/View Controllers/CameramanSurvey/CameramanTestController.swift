//
//  CameramanTestController.swift
//  Contributor
//
//  Created by KiwiTech on 12/8/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

struct CameraTestModel {
  var fileContentType: String
  var algorithm: String
  var markersV1: [String]?
  var newMarkers: [[String]]?
  var maxTimeOut: Int
  var mode: String
  var testModelArray: [CameramanTestModel]
  var negativeMarkers: [String]?
}

struct CameramanTestModel {
  var extractedImage: URL?
  var extractedText: [String]?
  var extractedIndex: Int?
  var validationPassed: Bool = false
  var isNegativeMarker: Bool = false
}

struct CameramanTest {
  static let type = "Type"
  static let algorithm = "Algorithm"
  static let markers = "Markers"
  static let maxTimeOut = "Max TimeOut Sec"
  static let mode = "Search Mode"
  static let contentValidationResult = "Content Validation Results"
 static let negativeMarkers = "Negative Markers"
}

class CameramanTestController: UIViewController {
    
 @IBOutlet weak var tableView: UITableView!
 @IBOutlet weak var validationTypeLabel: UILabel!
 @IBOutlet weak var validationAlgoLabel: UILabel!
 @IBOutlet weak var validationMarkersLabel: UILabel!
 @IBOutlet weak var validationMaxTimeOutLabel: UILabel!
 @IBOutlet weak var validationModeLabel: UILabel!
 @IBOutlet weak var validationNegativeMarkersLabel: UILabel!

 var validationDatasource = ValidationTestDatasource()
 var testModelData: CameraTestModel?
    
 override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    if let testDataArray = testModelData?.testModelArray {
        updateNewFileContent()
        initialSetUp(testDataArray)
    }
 }
    
func initialSetUp(_ testModelArray: [CameramanTestModel]) {
  tableView.delegate = validationDatasource
  tableView.dataSource = validationDatasource
  validationDatasource.delegate = self
  validationDatasource.retroValidationArray = testModelArray
  tableView.reloadData()
 }
    
 func updateContent(mode: String, algo: String,
                    timeOut: Int,
                    validationType: String) {
    setTitle(CameramanTest.contentValidationResult)
    updateTextWithAttribute("\(CameramanTest.type): \(validationType)",
                            textLabel: validationTypeLabel,
                            attributedTextStr: "\(CameramanTest.type)")
    updateTextWithAttribute("\(CameramanTest.algorithm): \(algo)",
                            textLabel: validationAlgoLabel,
                            attributedTextStr: "\(CameramanTest.algorithm)")
    updateTextWithAttribute("\(CameramanTest.maxTimeOut): \(timeOut)",
                            textLabel: validationMaxTimeOutLabel,
                            attributedTextStr: "\(CameramanTest.maxTimeOut)")
    updateTextWithAttribute("\(CameramanTest.mode): \(mode)",
                            textLabel: validationModeLabel,
                            attributedTextStr: "\(CameramanTest.mode)")
 }
    
 func updateHeader() {
    let vContent = CameramanValidation.mediaFileContent
    if let mode = testModelData?.mode, let algo = testModelData?.algorithm,
        let timeOutInSec = testModelData?.maxTimeOut,
        let v1Markers = testModelData?.markersV1 {
    updateContent(mode: mode, algo: algo, timeOut: timeOutInSec,
                      validationType: vContent)
    updateTextWithAttribute("\(CameramanTest.markers): \(v1Markers)",
                                textLabel: validationMarkersLabel,
                                attributedTextStr: "\(CameramanTest.markers)")
    }
 }
    
 func updateNewFileContent() {
    if let fileContentType = testModelData?.fileContentType,
       fileContentType != CameramanValidation.mediaFileContent,
       let mode = testModelData?.mode, let algo = testModelData?.algorithm,
       let timeOutInSec = testModelData?.maxTimeOut,
       let newMarkers = testModelData?.newMarkers {
        updateContent(mode: mode, algo: algo, timeOut: timeOutInSec,
                      validationType: fileContentType)
        var extractedText = ""
        for index in 0..<newMarkers.count {
            extractedText += "\(newMarkers[index])"
        }
        updateTextWithAttribute("\(CameramanTest.markers): \(extractedText)",
                                textLabel: validationMarkersLabel,
                                attributedTextStr: "\(CameramanTest.markers)")
    } else {
        updateHeader()
    }
    updateNegativeMarkers()
}
    func updateNegativeMarkers() {
        if let negativeMarkers = testModelData?.negativeMarkers {
            var negativeText = ""
            for index in 0..<negativeMarkers.count {
                negativeText += "\(negativeMarkers[index])"
            }
            updateTextWithAttribute("\(CameramanTest.negativeMarkers): \(negativeMarkers)",
                                    textLabel: validationNegativeMarkersLabel,
                                    attributedTextStr: "\(CameramanTest.negativeMarkers)")
        }
    }
func updateTextWithAttribute(_ prefixString: String, textLabel: UILabel, attributedTextStr: String) {
  let attributedText = prefixString.lineSpaced(1.2, with: Font.regular.of(size: 16))
  let fontAttributes = [
     Attribute.textColor(.black),
     Attribute.font(Font.bold.of(size: 16))
  ]
  attributedText.addAttributesToTerms(fontAttributes, to: [attributedTextStr])
  textLabel.attributedText = attributedText
  }
}

extension CameramanTestController: ValidationTestDelegate {
  func clickToOpenDetail(_ testModel: CameramanTestModel) {
    Router.shared.route(
        to: Route.retroValidationTestDetail(testModel: testModel),
        from: self,
        presentationType: .push(surveyToolBarNeeded: false)
    )
  }
}
