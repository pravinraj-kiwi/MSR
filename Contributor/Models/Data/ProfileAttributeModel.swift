//
//  ProfileAttributeModel.swift
//  Contributor
//
//  Created by KiwiTech on 11/5/20.
//  Copyright © 2020 Measure. All rights reserved.
//
import ObjectMapper

class ProfileAttributeModel: NSObject, Mappable {
  var categoryLabel: String?
  var priority: Int?
  var label: String?
  var ref: String?
  var attributeOption: [AttributeChoice]?
  var categoryRef: String?

  required init?(map: Map) {
   super.init()
 }
 
 func mapping(map: Map) {
   categoryLabel <- map["category_label"]
   priority <- map["priority"]
   label <- map["label"]
   ref <- map["ref"]
   attributeOption <- map["choices"]
   categoryRef <- map["category_ref"]
 }
}

class AttributeChoice: NSObject, Mappable {
  var label: String?
  var standAloneLabel: String?
  var value: String?
  
  required override init() {
    super.init()
  }
  
  required init?(map: Map) {
    super.init()
  }
  
  func mapping(map: Map) {
    label <- map["label"]
    standAloneLabel <- map["standalone_label"]
    value <- map["value"]
  }
}
