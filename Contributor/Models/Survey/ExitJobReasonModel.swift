//
//  ExitJobReasonModel.swift
//  Contributor
//
//  Created by KiwiTech on 11/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class ExitJobReasonModel: Decodable {
  var reasons: [JobReasonModel]
}

class JobReasonModel: Decodable {
 var reasonName: String
 var reasonImage: String
 var reasonType: String
 var selection: Bool? = false
}

struct ExitRequestModel {
 var reasonType: String
 var reasonStr: String
 var retroVideoSize: String
    var approxUploadSpeed : String
    
    init(type: String,
         reason: String,
         videoSize: String ,
         approxUploadSpeed: String) {
   self.reasonType = type
   self.reasonStr = reason
   self.retroVideoSize = videoSize
        self.approxUploadSpeed = approxUploadSpeed
 }
}
