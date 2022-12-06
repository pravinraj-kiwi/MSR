//
//  SurveyManager.swift
//  Contributor
//
//  Created by arvindh on 30/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import Moya
import SwiftyUserDefaults
import Alamofire

enum SurveyType {
case welcome
case category(category: SurveyCategory)
case categoryOffer(offerItem: OfferItem, params: CategoryOfferURLParams)
case embeddedOffer(offerItem: OfferItem, params: EmbeddedOfferURLParams)
case externalOffer(offerItem: OfferItem)

var categoryRef: String {
    switch self {
    case .welcome:
        return "basic"
    case .category(let category):
        return category.ref
    case .categoryOffer(_, let params):
        return params.category
    default:
        return ""
    }
}

var categorySurveyRef: String {
    return "standard"
}

var stringValue: String {
    switch self {
    case .welcome: return "profile"
    case .category: return "data"
    case .categoryOffer, .embeddedOffer: return "internal_offer"
    case .externalOffer: return "external"
    }
  }
}

enum SurveyError {
 case surveyNotLoaded
 case endReached
 case unableToLoadPage
}

enum SurveyCallbackType {
 case started
 case completed
 case terminated
}

enum SurveyFetchError: LocalizedError {
  case embeddedSurveyNotFound
}

class SurveyManager: NSObject {
var surveyType: SurveyType = .welcome
var survey: Survey?
var offerItem: OfferItem?
var currentPage: SurveyPage?
var currentIndex: Int? {
    guard let currentPage = currentPage else {
        return nil
    }
    
    return survey?.pages.firstIndex(of: currentPage)
}
var networkManager: NetworkManager!

fileprivate(set) var values: [String: BlockResponseComponent] = [:] {
    didSet {
        var json: [String: AnyHashable] = [:]
        for (key, value) in values {
            if let jsonValue = value.jsonValue {
                json[key] = jsonValue
            }
        }
        store(newValues: json)
    }
}
    
fileprivate(set) var temporaryValues: [String: BlockResponseComponent] = [:] {
    didSet {
        var json: [String: AnyHashable] = [:]
        for (key, value) in temporaryValues {
            if let jsonValue = value.jsonValue {
                json[key] = jsonValue
            }
        }
        temporaryStore(newValues: json)
    }
}
    
fileprivate(set) var nonProfileValues: [String: BlockResponseComponent] = [:] {
    didSet {
        var json: [String: AnyHashable] = [:]
        for (key, value) in nonProfileValues {
            if let jsonValue = value.jsonValue {
                json[key] = jsonValue
            }
        }
        nonProfileStore(newValues: json)
    }
}
    
fileprivate(set) var nonProfileTemporaryValues: [String: BlockResponseComponent] = [:] {
    didSet {
        var json: [String: AnyHashable] = [:]
        for (key, value) in nonProfileTemporaryValues {
            if let jsonValue = value.jsonValue {
                json[key] = jsonValue
            }
        }
        temporaryNonProfileStore(newValues: json)
    }
}

var fetchTask: Cancellable?

init(surveyType: SurveyType, networkManager: NetworkManager = NetworkManager.shared) {
    self.surveyType = surveyType
    self.networkManager = networkManager
    super.init()
    
    switch surveyType {
    case .welcome, .category, .categoryOffer, .embeddedOffer:
        fetchSurveyAndStart { _ in }
    case .externalOffer(let offerItem):
        self.offerItem = offerItem
        fetchSurveyAndStart { _ in }
    }
}

convenience init(survey: Survey, surveyType: SurveyType, networkManager: NetworkManager = NetworkManager.shared) {
    self.init(surveyType: surveyType, networkManager: networkManager)
    self.survey = survey
    start()
    loadInitialValues()
}

func fetchSurveyAndStart(_ completion: @escaping (Error?) -> Void) {
   NotificationCenter.default.post(name: NSNotification.Name.willFetchSurvey, object: self)
   fetchSurvey { (error) in
     if let error = error {
        os_log("Failed to fetch survey", log: OSLog.surveys, type: .error)
        NotificationCenter.default.post(name: .didFailToFetchSurvey, object: self, userInfo: ["error": error])
        return
    }
    self.start()
    self.loadInitialValues()
    NotificationCenter.default.post(name: .didFetchSurvey, object: self)
    completion(error)
  }
}

fileprivate func start() {
    currentPage = nil
    nextPage(isSurveyStart: true, offerItem: offerItem) { _ in }
}

func loadInitialValues() {
    guard let survey = survey else {
        return
    }
    if let profileStore = networkManager.userManager?.profileStore {
        values = profileStore.values(for: survey) ?? [:]
    }
}

func value(forBlock block: SurveyBlock) -> BlockResponseComponent? {
    let key: String = block.blockID ?? ""
    return values[key]
}

func temporaryValue(forBlock block: SurveyBlock) -> BlockResponseComponent? {
    let key: String = block.blockID ?? ""
    return temporaryValues[key]
}
 
func nonProfileValue(forBlock block: SurveyBlock) -> BlockResponseComponent? {
    let key: String = block.blockID ?? ""
    return values[key]
}
    
func nonProfileTemporaryValue(forBlock block: SurveyBlock) -> BlockResponseComponent? {
    let key: String = block.blockID ?? ""
    return nonProfileTemporaryValues[key]
}

func setValue(_ value: BlockResponseComponent?, forBlock block: SurveyBlock) {
    let key: String = block.blockID ?? ""
    
    guard let value = value else {
        values.removeValue(forKey: key)
        return
    }
    values[key] = value
}

func setTemporaryValue(_ value: BlockResponseComponent?, forBlock block: SurveyBlock) {
    let key: String = block.blockID ?? ""
    
    guard let value = value else {
        temporaryValues.removeValue(forKey: key)
        return
    }
    temporaryValues[key] = value
}
    
func setNonProfileValue(_ value: BlockResponseComponent?, forBlock block: SurveyBlock) {
    let key: String = block.blockID ?? ""
    
    guard let value = value else {
        nonProfileValues.removeValue(forKey: key)
        return
    }
    nonProfileValues[key] = value
}

func setNonProfileTemporaryValue(_ value: BlockResponseComponent?, forBlock block: SurveyBlock) {
    let key: String = block.blockID ?? ""
    
    guard let value = value else {
        nonProfileTemporaryValues.removeValue(forKey: key)
        return
    }
    nonProfileTemporaryValues[key] = value
}

func removeValue(forBlock block: SurveyBlock) {
    values.removeValue(forKey: block.blockID ?? "")
}

func removeNonProfileValue(forBlock block: SurveyBlock) {
    nonProfileValues.removeValue(forKey: block.blockID ?? "")
}

func store(newValues: [String: AnyHashable]) {
    if let profileStore = networkManager.userManager?.profileStore {
       profileStore.set(values: newValues)
    }
}

func temporaryStore(newValues: [String: AnyHashable]) {
    if let profileStore = networkManager.userManager?.profileStore {
       profileStore.setTemporary(values: newValues)
    }
}

func nonProfileStore(newValues: [String: AnyHashable]) {
    if let profileStore = networkManager.userManager?.profileStore {
       profileStore.setNonProfile(values: newValues)
    }
}
    
func temporaryNonProfileStore(newValues: [String: AnyHashable]) {
    if let profileStore = networkManager.userManager?.profileStore {
      profileStore.setNonProfileTemporary(values: newValues)
    }
}

func updateProfileValues() {
    values = temporaryValues
    temporaryValues = [:]
    if let profileStore = networkManager.userManager?.profileStore {
        UserDefaults.standard.removeObject(forKey: profileStore.temporaryKey)
    }
    updateProfileItems()
}

func updateNonProfileValues() {
  nonProfileValues = nonProfileTemporaryValues
  let isContainProfileItem = checkIfWorkshopSurveyHasProfileItems(nonProfileTemporaryValues)
    nonProfileTemporaryValues = [:]
  if let profileStore = networkManager.userManager?.profileStore, let userId = UserManager.shared.user?.userID {
    UserDefaults.standard.setValue(profileStore.nonProfileValues, forKey: "nonProfileStore-\(userId)")
    UserDefaults.standard.removeObject(forKey: profileStore.nonProfileTemporaryKey)
  }
  if isContainProfileItem {
    updateProfileItems()
  }
}
    
func checkIfWorkshopSurveyHasProfileItems(_ nonTempValues: [String: BlockResponseComponent]) -> Bool {
  if let profileStore = networkManager.userManager?.profileStore {
    for item in nonTempValues {
        if profileStore.values.contains(where: { $0.key == item.key}) {
            return true
        }
    }
  }
 return false
}
  
func updateProfileItems() {
    let userInfo: [String: Any] = [
            "categoryRef": surveyType.categoryRef,
            "itemRefs": Array(values.keys)
    ]
    NotificationCenter.default.post(name: .profileSurveyFinished, object: nil, userInfo: userInfo)
}
    
func finish(_ offerItem: OfferItem?) {
  updateProfileValues()
    if let selectedOffer = offerItem,
        let sampleRequestType = selectedOffer.sampleRequestType,
        sampleRequestType == SampleRequestType.workShopSurvey {
        updateNonProfileValues()
    }
  }
}
