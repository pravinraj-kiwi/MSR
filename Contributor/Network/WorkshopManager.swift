//
//  WorkshopManager.swift
//  Contributor
//
//  Created by John Martin on 11/18/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Moya
import SwiftyUserDefaults

class WorkshopManager: NSObject {
  static let shared: WorkshopManager = {
    let workshop = WorkshopManager()
    return workshop
  }()
  
  let provider: MoyaProvider<WorkshopAPI> = MoyaProvider<WorkshopAPI>()
    
  @discardableResult
  func getWorkshopJob(jobID: String, _ completion: @escaping (Survey?, Error?) -> Void) -> Cancellable? {
    provider.request(WorkshopAPI.getWorkshopJob(jobID)) {
      result in
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let response):
        do {
          let survey = try response.mapObject(Survey.self)
          completion(survey ,nil)
        } catch {
          completion(nil, error)
        }
      }
    }
  }
}
