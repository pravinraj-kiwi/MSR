//
//  NetworkManager+MyData.swift
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
func getSurveyCategories(completion: @escaping (Category?, Error?) -> Void) -> Cancellable? {
  return provider.request(ContributorAPI.getSurveyCategories) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let categories = try response.mapObject(Category.self)
        completion(categories, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
}

@discardableResult
 func getCategorySurvey(categoryRef: String, surveyRef: String,
                        completion: @escaping (Survey?, Error?) -> Void) -> Cancellable? {
   let surveyCategoryPath = ContributorAPI.getCategorySurvey(categoryRef: categoryRef,
                                                             surveyRef: surveyRef)
   return provider.request(surveyCategoryPath) { [weak self] (result) in
     guard let _ = self else {
       return
     }
     switch result {
     case .failure(let error):
       completion(nil, error)
     case .success(let response):
       do {
         let survey = try response.mapObject(Survey.self)
         completion(survey, nil)
       } catch {
         completion(nil, error)
       }
     }
   }
}
    
func getOfferNativeSurvey(workShopURL: String, completion: @escaping (NativeOfferSurvey?, Error?) -> Void) {
    Alamofire.request(workShopURL, method: .get, encoding: JSONEncoding.default)
      .validate()
      .responseJSON { [weak self] response in
        guard let _ = self else {
          return
        }
        switch response.result {
        case .failure(let error):
            completion(nil, error)
        case .success(_):
            let survey = Mapper<NativeOfferSurvey>().map(JSONObject: response.result.value)
            completion(survey, nil)
        }
    }
}
    
@discardableResult
func rateSurvey(sampleRequestID: Int, rating: Int,
                ratingItems: [String],
                completion: @escaping (Error?) -> Void) -> Cancellable? {
  let rateSurveyPath = ContributorAPI.rateSurvey(sampleRequestID: sampleRequestID,
                                                 rating: rating, ratingItems: ratingItems)
  return provider.request(rateSurveyPath) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    completion(result.error)
  }
 }
    
@discardableResult
func uploadMedia(_ params: MediaParam,
                 completion: @escaping (MediaUploadResponse?, Error?) -> Void) -> Cancellable? {
  return provider.request(ContributorAPI.uploadMedia(params)) { [weak self] (result) in
    guard let _ = self else {
      return
    }
    switch result {
    case .failure(let error):
      completion(nil, error)
    case .success(let response):
      do {
        let mediaResponse = try response.mapObject(MediaUploadResponse.self)
        completion(mediaResponse, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
 }
    
@discardableResult
 func getProfileAttribute(completion: @escaping ([ProfileAttributeModel]?, Error?) -> Void) -> Cancellable? {
    var selectedLanguage = AppLanguageManager.shared.getLanguage() ?? "en"
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        selectedLanguage = "pt"
    }
   let profileAttributePath = ContributorAPI.attrributedProfile(source: selectedLanguage)
   return provider.request(profileAttributePath) { [weak self] (result) in
     guard let _ = self else {
       return
     }
     
     switch result {
     case .failure(let error):
       completion(nil, error)
     case .success(let response):
       do {
         let attributeModel = try response.mapArray(ProfileAttributeModel.self)
         completion(attributeModel, nil)
       } catch {
         completion(nil, error)
       }
     }
   }
 }
    
@discardableResult
 func getProfileAttributeList(completion: @escaping ([ProfileAttributeModel]?, Error?) -> Void) -> Cancellable? {
    var selectedLanguage = AppLanguageManager.shared.getLanguage() ?? "en"
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        selectedLanguage = "pt"
    }
    let profileAttributePath = ContributorAPI.attributeProfileList(source: selectedLanguage)
   return provider.request(profileAttributePath) { [weak self] (result) in
     guard let _ = self else {
       return
     }
     
     switch result {
     case .failure(let error):
       completion(nil, error)
     case .success(let response):
       do {
         let attributeModel = try response.mapArray(ProfileAttributeModel.self)
         completion(attributeModel, nil)
       } catch {
         completion(nil, error)
       }
     }
   }
 }
}
