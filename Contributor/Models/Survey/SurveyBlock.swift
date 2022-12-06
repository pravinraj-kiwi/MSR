//
//  SurveyBlock.swift
//  Contributor
//
//  Created by arvindh on 30/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import ObjectMapper

enum BlockType: String {
  case radio, date, checkbox
  case singleLineText = "single_line_text"
  var associatedClass: BlockResponseComponent.Type {
    switch self {
    case .radio:
      return RadioBlockResponse.self
    case .date:
      return DateBlockResponse.self
    case .checkbox:
      return CheckboxBlockResponse.self
    case .singleLineText:
      return SingleLineTextBlockResponse.self
    }
  }
}

class SurveyBlock: NSObject, Mappable {
  class Choice: NSObject, Mappable {
    var label: String?
    var labelPt: String?
    var value: String?
    
    required override init() {
      super.init()
    }
    
    required init?(map: Map) {
      super.init()
    }
    
    func mapping(map: Map) {
      label <- map["label.en"]
      labelPt <- map["label.pt"]
      value <- map["value"]
    }
  }
  var isProfile: Bool = true
  var question: String?
  var questionPt: String?
  var choices: [Choice]?
  var label: String?
  var labelPt: String?
  var exampleText: String?
  var blockID: String?
  var blockType: String?
  var widgetTypeString: String?
  var screenCaptureBlock: ScreenCaptureBlock?

  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    isProfile <- map["question.is_profile"]
    question <- map["question.question.en"]
    questionPt <- map["question.question.pt"]
    choices <- map["question.choices"]
    widgetTypeString <- map["question.widget"]
    label <- map["question.label.en"]
    labelPt <- map["question.label.pt"]
    exampleText <- map["question.example_text"]
    blockID <- map["question.id"]
    blockType <- map["type"]
    screenCaptureBlock <- map["screen_capture"]
  }
}

class ScreenCaptureBlock: NSObject, Mappable {
  var dataTypeLogoUrl: String?
  var screenCaptureId: String?
  var appName: String?
  var dataType: String?
  var dataFormat: ScreenCaptureType?
  var label: String?
  var showInstructions: Bool?
  var instructions: String?
  var instructionsPt: String?
  var validation: [Validation] = []

  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    screenCaptureId <- map["id"]
    appName <- map["app_name"]
    dataType <- map["data_type"]
    dataFormat <- map["data_format"]
    label <- map["label.en"]
    showInstructions <- map["show_instructions"]
   instructions <- map["instructions.ios.en"]
    instructionsPt <- map["instructions.ios.pt"]
    validation <- map["validation"]
    dataTypeLogoUrl <- map["data_type_logo"]
  }
}

class Validation: NSObject, Mappable {
 var fileSizeType: String? = "KB"
 var minFileSize: Int?
 var maxFileSize: Int?
 var fileRecency: Int?
 var algorithm: String?
 var markers: [[String]]?
 var v1Markers: [String]?
 var timeOut: Int?
 var type: String?
 var mode: ModeType?
 var negativeMarkers: NegativeMarker?


required init?(map: Map) {
   super.init()
 }

func mapping(map: Map) {
   type <- map["type"]
   algorithm <- map["params.algorithm"]
   minFileSize <- map["params.lower"]
   maxFileSize <- map["params.upper"]
   fileRecency <- map["params.max_age_in_minutes"]
   markers <- map["params.markers"]
   v1Markers <- map["params.markers"]
   mode <- map["params.mode"]
   timeOut <- map["params.max_timeout_secs"]
    negativeMarkers <- map["params.negative_markers"]
 }
}
class NegativeMarker: NSObject, Mappable {
    required init?(map: Map) {
       super.init()
     }
    var keys: [String]?
    var messageEn: String?
    var messagePt: String?
    func mapping(map: Map) {
        keys <- map["keys"]
        messageEn <- map["message.en"]
        messagePt <- map["message.pt"]
     }
}
enum ModeType: String {
 case middle
 case left
 case right
}
