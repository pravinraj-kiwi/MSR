//
//  NetworkManager+SurveyPartnerApps.swift
//  Contributor
//
//  Created by Mini on 22/05/20.
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
func getDynataProfileItems(appType: ConnectedApp,
                           completion: @escaping (ConnectedAppData?,
                                                  Error?) -> Void) -> Cancellable? {
  let partnerRequestPath = ContributorAPI.partnerAppRequest(connectApp: appType)
  return provider.request(partnerRequestPath) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let dynataData = try response.map(ConnectedAppData.self)
        completion(dynataData, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
}
 
@discardableResult
func getDynataJobDetail(_ app: ConnectedApp,
                        completion: @escaping (DynataJobDetail?,
                                               Error?) -> Void) -> Cancellable? {
    let connectAppDetail = ContributorAPI.getDynataJobDetail(connectApp: app)
    return provider.request(connectAppDetail) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let dynataJobEarningDetail = try response.mapObject(DynataJobDetail.self)
        completion(dynataJobEarningDetail, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
 }
    
@discardableResult
func getPartnerJobDetail(_ app: ConnectedApp,
                         _ transactionId: Int,
                         completion: @escaping (TransactionDetail?,
                                                Error?) -> Void) -> Cancellable? {
    let partnerJobDetail = ContributorAPI.getPartnerDetail(connectApp: app, transactionID: transactionId)
    return provider.request(partnerJobDetail) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let partnerDetail = try response.mapObject(TransactionDetail.self)
        completion(partnerDetail, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
 }
}
