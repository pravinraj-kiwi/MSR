//
//  MediaUploadResponse.swift
//  Contributor
//
//  Created by KiwiTech on 7/7/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import ObjectMapper

class MediaUploadResponse: NSObject, Mappable {
  var userId: Int?
  var url: String?
  var mediaType: String?
  var fileName: String?
  var uploadStatus: String?
  var awsKeyId: String?
  var awsSecret: String?
  var awsBucket: String?

  required init?(map: Map) {
   super.init()
 }
 
 func mapping(map: Map) {
   userId <- map["user_id"]
   url <- map["url"]
   mediaType <- map["media_type"]
   fileName <- map["file_name"]
   uploadStatus <- map["upload_status"]
   awsKeyId <- map["aws_key_id"]
   awsSecret <- map["aws_secret"]
   awsBucket <- map["aws_bucket"]
 }
}
