//
//  SurveyLoadable.swift
//  Contributor
//
//  Created by arvindh on 03/02/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation

@objc protocol SurveyLoadable: class {
  var surveyManager: SurveyManager {get set}
  
  @objc optional func registerForSurveyLoadNotifications()
  @objc func updateUIForSurvey()
  @objc func willFetchSurvey()
  @objc func didFetchSurvey()
  @objc func didFailToFetchSurvey(_ notification: Notification)
}

extension SurveyLoadable where Self: NSObject {
  func registerForSurveyLoadNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.willFetchSurvey), name: NSNotification.Name.willFetchSurvey, object: surveyManager)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.didFetchSurvey), name: NSNotification.Name.didFetchSurvey, object: surveyManager)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.didFailToFetchSurvey(_:)), name: NSNotification.Name.didFailToFetchSurvey, object: surveyManager)
  }
}
