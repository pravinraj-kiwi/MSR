//
//  ProfileStore+QuestionSetup.swift
//  Contributor
//
//  Created by KiwiTech on 6/2/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import os
import UIKit
import SwiftyUserDefaults

extension ProfileStore {

func values(for survey: Survey) -> [String: BlockResponseComponent] {
    var valuesForSurvey: [String: BlockResponseComponent] = [:]
    for page in survey.pages {
        for block in page.blocks {
            guard let widget = block.widgetTypeString,
                  let blockResponse = BlockType(rawValue: widget)?.associatedClass,
                  let blockId = block.blockID, let jsonValue = self[blockId] else {
                continue
            }
            valuesForSurvey[blockId] = blockResponse.init(jsonValue: jsonValue)
        }
    }
    return valuesForSurvey
}

func updateWithBackup(for profile: Profile) {
    let updateBackupStatus = {
        let newBackupStatus = ProfileBackupStatus()
        newBackupStatus.changeTag = profile.changeTag
        newBackupStatus.modifiedAt = profile.modifiedAt
        newBackupStatus.fetchDate = Date()
        Defaults[.profileBackupStatus] = newBackupStatus
    }
    
    let updateValues = {
        self.set(values: profile.json)
    }
    
    guard let profileBackupStatus = Defaults[.profileBackupStatus],
        let changeTag = profileBackupStatus.changeTag,
        let modifiedAt = profileBackupStatus.modifiedAt
        else {
            updateValues()
            updateBackupStatus()
            return
    }
    
    if let serverChangeTag = profile.changeTag,
        let serverModifiedAt = profile.modifiedAt {
        if (serverChangeTag != changeTag) || (serverModifiedAt >= modifiedAt) {
            updateValues()
            updateBackupStatus()
        }
    }
  }

func updateAgeFromDOB() -> Int? {
    if let dobString = values[ProfileItemRefs.dob] as? String {
        let dobFormatter = DateFormatter()
        dobFormatter.locale = Locale.current
        dobFormatter.dateFormat = DateFormatType.shortDateFormat.rawValue
        dobFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        guard let dob = dobFormatter.date(from: dobString) else {
            return nil
        }
        let secondsInAYear: Double = 60 * 60 * 24 * 365
        let ageInYears: Int? = Int(-dob.timeIntervalSinceNow / secondsInAYear)
        if let userAge = ageInYears {
            set(values: ["age": userAge])
            return ageInYears
        }
    }
    return nil
}

func updateGeoFromPostalCode(completion: (() -> Void)? = nil) {
    guard let countryUID = values[ProfileItemRefs.country] as? String,
        let postalCodeRef = ProfileItemRefs.postalCodeRefByCountryUID[countryUID],
        let postalCodeStringRef = ProfileItemRefs.postalCodeStringRefByCountryUID[countryUID] else {
            completion?()
            return
    }
    if let postalCodeString = values[postalCodeRef], values[postalCodeStringRef] == nil {
        set(values: [postalCodeStringRef: postalCodeString])
        removeValue(forKey: postalCodeRef)
    }
    guard let postalCodeString = values[postalCodeStringRef] as? String else {
        completion?()
        return
    }
    let otherCountryUIDs = ProfileItemRefs.countrySpecificItems.keys.filter { $0 != countryUID }
    for otherCountryUID in otherCountryUIDs {
        for ref in ProfileItemRefs.countrySpecificItems[otherCountryUID]! {
            removeValue(forKey: ref)
        }
    }
    backgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
    backgroundTaskRunner.startTask {
    NetworkManager.shared.resolvePostalCode(countryUID: countryUID, postalCode: postalCodeString) {
        [weak self] profileItemResolutionResponse, error in
        guard let this = self else {
            return
        }
        if let p = profileItemResolutionResponse, p.found {
            this.set(values: p.items)
            debugPrint("Running in backgrount set profile")
        }
        completion?()
      }
      self.backgroundTaskRunner.endTask()
    }
    Defaults[.haveResolvedGeo] = true
  }
}
