//
//  TopHeader.swift
//  Contributor
//
//  Created by John Martin on 5/5/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation

class TopHeaderItem: NSObject {
  var text: String!
  var showDate: Bool!
  
  init(text: String, showDate: Bool = false) {
    self.text = text
    self.showDate = showDate
    super.init()
  }
}
class SeperatorItem: NSObject {
    override init() {
    super.init()
  }
}
class StoryListItem: NSObject {
  var stories: [Story]?
  
  init(stories: [Story]) {
    self.stories = stories
    super.init()
  }
}
