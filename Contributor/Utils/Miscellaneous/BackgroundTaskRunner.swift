//
//  BackgroundTaskRunner.swift
//  Contributor
//
//  Created by arvindh on 15/02/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

class BackgroundTaskRunner: NSObject {
  var task: UIBackgroundTaskIdentifier!
  var application: UIApplication
  
  init(application: UIApplication) {
    self.application = application
    super.init()
    register()
  }
  
  func register() {
    task = application.beginBackgroundTask {
      [weak self] in
      guard let this = self else {
        return
      }
      
      this.endTask()
    }
  }
  
  func endTask() {
    application.endBackgroundTask(task)
    self.task = UIBackgroundTaskIdentifier.invalid
  }
  
  func startTask(_ someWork: () -> Void) {
    assert(task != UIBackgroundTaskIdentifier.invalid, "Task is invalid, create a new task runner instance")
    someWork()
  }
}
