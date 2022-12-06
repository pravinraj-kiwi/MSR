//
//  WorkshopAPI.swift
//  Contributor
//
//  Created by John Martin on 11/16/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import Moya

enum WorkshopAPI {
  case getWorkshopJob(String)
}

extension WorkshopAPI: TargetType {
  var baseURL: URL {
    return Constants.baseWorkshopAPIURL
  }
  
  var path: String {
    switch self {
    case .getWorkshopJob(let jobID): return "/jobs/\(jobID)"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .getWorkshopJob(_): return .get
    }
  }
  
  var sampleData: Data {
    return Data()
  }
  
  var task: Task {
    switch self {
    case .getWorkshopJob(_):
      return Task.requestPlain
    }
  }
  
  var headers: [String : String]? {
    return nil
  }
}
