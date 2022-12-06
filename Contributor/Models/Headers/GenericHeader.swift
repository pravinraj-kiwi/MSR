//
//  GenericHeader.swift
//  Contributor
//
//  Created by John Martin on 5/5/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation

class GenericHeaderItem: NSObject {
  var text: String!
  var useLargeFont: Bool = false
  
  init(text: String, useLargeFont: Bool = false) {
    self.text = text
    self.useLargeFont = useLargeFont
    super.init()
  }
}
