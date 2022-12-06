//
//  SurveyResponse.swift
//  Contributor
//
//  Created by arvindh on 08/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

protocol BlockResponseComponent: class {
  var jsonValue: AnyHashable? {get}
  init()
  init(jsonValue: AnyHashable)
}

class SurveyResponse: NSObject {
  var values: [String: BlockResponseComponent] = [:]
}

class SurveyBlockResponse: NSObject {
  var blockID: String!
}

class SingleLineTextBlockResponse: SurveyBlockResponse, BlockResponseComponent {
  var value: String?
  var jsonValue: AnyHashable? {
    return value
  }
  
  required init(jsonValue: AnyHashable) {
    super.init()
    self.value = jsonValue as? String
  }
  
  required override init() {
    super.init()
  }
}

class DateBlockResponse: SurveyBlockResponse, BlockResponseComponent {
  var value: Date?
  var jsonValue: AnyHashable? {
    guard let date = value else {
      return nil
    }
    let df = ISO8601DateFormatter()
    df.formatOptions = [.withFullDate]
    return df.string(from: date)
  }
  
  required init(jsonValue: AnyHashable) {
    super.init()
    if let dateString = jsonValue as? String {
      let df = ISO8601DateFormatter()
      df.formatOptions = [.withFullDate]
      self.value = df.date(from: dateString)
    }
  }
  
  required override init() {
    super.init()
  }
}

class RadioBlockResponse: SurveyBlockResponse, BlockResponseComponent {
  var value: SurveyBlock.Choice?
  var jsonValue: AnyHashable? {
    return value?.value
  }
  
  required init(jsonValue: AnyHashable) {
    super.init()
    
    if let choice = jsonValue as? String {
      self.value = SurveyBlock.Choice(JSON: ["value": choice])
    }
  }
  
  required override init() {
    super.init()
  }
}

class CheckboxBlockResponse: SurveyBlockResponse, BlockResponseComponent {
  var value: Set<SurveyBlock.Choice>? 
  var jsonValue: AnyHashable? {
    return value?.map({ (choice) -> String in
       if let choiceValue = choice.value {
          return choiceValue
       }
       return ""
    })
  }
  
  required init(jsonValue: AnyHashable) {
    super.init()
    if jsonValue as? [String] == nil {
        let singleValuesArray: [SurveyBlock.Choice] = [jsonValue].map { choiceValue in
            let choice = SurveyBlock.Choice()
            choice.value = choiceValue as? String
            return choice
        }
       self.value = Set<SurveyBlock.Choice>(singleValuesArray)
    } else {
        updateOptionFromMultipleOption(jsonValue)
    }
  }
    
func updateOptionFromMultipleOption(_ jsonValue: AnyHashable) {
  if let choices = jsonValue as? [String] {
      let valuesArray: [SurveyBlock.Choice] = choices.map { choiceString in
        let choice = SurveyBlock.Choice()
        choice.value = choiceString
        return choice
     }
     self.value = Set<SurveyBlock.Choice>(valuesArray)
    }
}
  
  required override init() {
    super.init()
  }
}
