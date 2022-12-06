//
//  ProfileAttributeListModel.swift
//  Contributor
//
//  Created by KiwiTech on 11/9/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class ProfileAttributeListModel: NSObject {
  var attributeTitle: String = ""
  var attributeItems: ProfileAttributeModel?
  var profileMultiAnswers: [String] = []
  var combineItems: [CombineItems]? = []
}

class CombineItems: NSObject {
  var attributeQuestions: String = ""
  var attributeAnswers: String = ""
    
  init(item: String, answer: String) {
    self.attributeQuestions = item
    self.attributeAnswers = answer
    super.init()
  }
}

class AttributeCollectionModel: NSObject {
  var collectionCount: String = ""
  var collectionLabel: String = ""
    
  init(count: String, label: String) {
    self.collectionCount = count
    self.collectionLabel = label
    super.init()
  }
}
