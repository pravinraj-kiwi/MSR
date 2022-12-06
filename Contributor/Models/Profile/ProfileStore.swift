//
//  ProfileStore.swift
//  Contributor
//
//  Created by arvindh on 29/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import SwiftyUserDefaults

let profileFetchInterval: TimeInterval = 3600

class ProfileStore: NSObject {
fileprivate(set) var values: [String: AnyHashable] = [:]
fileprivate(set) var temporaryvalues: [String: AnyHashable] = [:]
fileprivate(set) var nonProfileValues: [String: AnyHashable] = [:]
fileprivate(set) var nonProfileTemporaryvalues: [String: AnyHashable] = [:]

var user: User
let key: String
let temporaryKey: String
let nonProfileKey: String
let nonProfileTemporaryKey: String
var backgroundTaskRunner: BackgroundTaskRunner!
    
var profile: Profile? {
    didSet {
        if let profile = profile {
            updateWithBackup(for: profile)
        } else {
            if !values.isEmpty {
                // user has existing responses, but they're not backed-up, so do it now
                backup()
            }
        }
    }
}

var count: Int {
    return values.count
}

var keys: Dictionary<String, AnyHashable>.Keys {
    return values.keys
}

subscript(key: String) -> AnyHashable? {
    return self.values[key]
}

func contains(_ key: String) -> Bool {
    return self.values.keys.contains(key)
}

init(user: User) {
    self.user = user
    self.key = "profileStore-\(self.user.userID!)"
    self.temporaryKey = Constants.profileTempKey
    self.nonProfileKey = "nonProfileStore-\(self.user.userID!)"
    self.nonProfileTemporaryKey = Constants.nonProfileTempKey

    super.init()
    
    loadLocalValues()
    if let _ = Defaults[.loggedInUserAccessToken] {
        callProfileAPI()
    }
}
    
@objc func callProfileAPI() {
    fetchProfile()
    NotificationCenter.default.addObserver(self, selector: #selector(onProfileSurveyFinished), name: .profileSurveyFinished, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onNewAppVersion), name: .newAppVersion, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(fetchProfileIfRequired), name: UIApplication.didBecomeActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onOnBoardingFinished),
                                           name: NSNotification.Name.onboardingFinished, object: nil)
}

fileprivate func loadLocalValues() {
    self.values = UserDefaults.standard.value(forKey: self.key) as? [String: AnyHashable] ?? [:]
}
    
func save() {
    UserDefaults.standard.set(values, forKey: self.key)
}

func saveNonProfile() {
    UserDefaults.standard.set(nonProfileValues, forKey: self.nonProfileKey)
}

func saveTemporaryValues() {
    UserDefaults.standard.set(temporaryvalues, forKey: self.temporaryKey)
}

func saveNonProfileTemporaryValues() {
    UserDefaults.standard.set(nonProfileTemporaryvalues, forKey: self.nonProfileTemporaryKey)
}

func set(values newValues: [String: AnyHashable]) {
    for (valuesKey, values) in newValues {
        replaceOldValueWithNew(valuesKey, savedValues: values)
    }
    save()
}
    
func replaceOldValueWithNew(_ valuesKey: String, savedValues: AnyHashable) {
 if let newValues = UserDefaults.standard.value(forKey: Constants.profileNewValues) as? [[String: [String: AnyHashable]]] {
    let flattenNewValue = newValues.flatMap({$0})
    if flattenNewValue.contains(where: {$0.key == valuesKey}) {
        let newDataDict = flattenNewValue.filter({$0.key == valuesKey})
        let newValuesDict = newDataDict.flatMap({$0.value.compactMap({$0})})
        if let value = savedValues as? String {
           handleSingleValues(newValuesDict, valuesKey, value)
        }
        if let values = savedValues as? [String] {
           handleArrayOfValues(newValuesDict, valuesKey, values)
        }
    } else {
        self.values[valuesKey] = savedValues
    }
 } else {
    self.values[valuesKey] = savedValues
 }
}
    
func handleSingleValues(_ newValuesDict: [Dictionary<String, AnyHashable>.Element],
                        _ valuesKey: String, _ values: String) {
 var updatedSingleValue = String()
 let keyValuePair = newValuesDict.filter({$0.key == values.lowercased()})
  if keyValuePair.isEmpty == false {
     for values in keyValuePair.enumerated() {
        if let newValue = values.element.value as? String {
          updatedSingleValue = newValue
        }
     }
  } else {
      updatedSingleValue = values
  }
  self.values[valuesKey] = updatedSingleValue
}

func handleArrayOfValues(_ newValuesDict: [Dictionary<String, AnyHashable>.Element],
                         _ valuesKey: String, _ values: [String]) {
    var updatedValue =  [String]()
    for savedItems in values {
        let updateKey = savedItems.replacingOccurrences(of: "’", with: "").lowercased()
        let keyValuePair = newValuesDict.filter({$0.key == updateKey})
        if keyValuePair.isEmpty == false {
            for values in keyValuePair.enumerated() {
                if let newValue = values.element.value as? String {
                    updatedValue.append(newValue)
                }
            }
        } else {
            updatedValue.append(savedItems)
        }
    }
    self.values[valuesKey] = updatedValue
}
    
func setTemporary(values newValues: [String: AnyHashable]) {
    for (tempKey, tempValues) in newValues {
        self.temporaryvalues[tempKey] = tempValues
    }
    saveTemporaryValues()
}
    
func setNonProfile(values newValues: [String: AnyHashable]) {
    for (nonProfileKey, nonProfileValue) in newValues {
        self.nonProfileValues[nonProfileKey] = nonProfileValue
    }
    saveNonProfile()
}
    
func setNonProfileTemporary(values newValues: [String: AnyHashable]) {
    for (nonProfileTempKey, nonProfileTempValue) in newValues {
        self.nonProfileTemporaryvalues[nonProfileTempKey] = nonProfileTempValue
    }
    saveNonProfileTemporaryValues()
}

func removeValue(forKey key: String) {
   self.values.removeValue(forKey: key)
   save()
}

func removeTemporaryValue(forKey tempKey: String) {
   self.temporaryvalues.removeValue(forKey: tempKey)
   saveTemporaryValues()
}

func removeNonProfileValue(forKey nonProfileKey: String) {
   self.nonProfileValues = [:]
   self.nonProfileValues.removeValue(forKey: nonProfileKey)
   saveNonProfile()
}
    
func removeNonProfileTemporaryValue(forKey nonProfileTempKey: String) {
   self.nonProfileTemporaryvalues.removeValue(forKey: nonProfileTempKey)
   saveNonProfileTemporaryValues()
 }
}
