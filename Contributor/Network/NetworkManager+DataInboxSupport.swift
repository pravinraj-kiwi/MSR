//
//  NetworkManager+DataInboxSupport.swift
//  Contributor
//
//  Created by KiwiTech on 5/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya
import SwiftyUserDefaults
import ObjectMapper
import Moya_ObjectMapper
import Alamofire
import os

extension NetworkManager {

@discardableResult
func getDataInboxPackage(completion: @escaping ([DataInboxSupport]?, Error?) -> Void) -> Cancellable? {
  return provider.request(ContributorAPI.getDataInboxPackage) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let dataPackage = try response.map([DataInboxSupport].self)
        completion(dataPackage, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
}

@discardableResult
func deleteProcessedData(package: [DataInboxSupport],
                         completion: @escaping (DeletePackageModel?, Error?) -> Void) -> Cancellable? {
  let deleteProcessPath = ContributorAPI.deletePackageProcessedData(packages: package)
  return provider.request(deleteProcessPath) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
     do {
       let deletedPackage = try response.map(DeletePackageModel.self)
       completion(deletedPackage, nil)
     } catch {
        completion(nil, error)
      }
    }
  }
 }
}
