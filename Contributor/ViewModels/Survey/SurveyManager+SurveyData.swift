//
//  SurveyManager+NonProfile.swift
//  Contributor
//
//  Created by KiwiTech on 6/1/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension SurveyManager {

func fetchSurvey(_ completion: @escaping (Error?) -> Void) {
    fetchTask?.cancel()
    switch surveyType {
    case .welcome, .category, .categoryOffer:
       fetchTask = networkManager.getCategorySurvey(categoryRef: surveyType.categoryRef,
                                                    surveyRef: surveyType.categorySurveyRef) { [weak self] (survey, error) in
         guard let this = self else {
         return
         }
         
         if let error = error {
            completion(error)
         } else {
            this.survey = survey
            completion(nil)
           }
        }
    
    case .embeddedOffer(let offerItem, _):
        guard let survey = offerItem.embeddedSurvey else {
            completion(SurveyFetchError.embeddedSurveyNotFound)
            return
        }
        self.survey = survey
        completion(nil)
        
    case .externalOffer(let offerItem):
        if offerItem.sampleRequestType == SampleRequestType.workShopSurvey {
            removeNonProfileStore(offerItem)
            networkManager.getOfferNativeSurvey(workShopURL: offerItem.urlString) { [weak self] (survey, error) in
                guard let this = self else {
                    return
                }
                if let error = error {
                    completion(error)
                } else {
                    this.survey = survey?.nativeSurvey
                    completion(nil)
                }
            }
        }
        completion(nil)
    }
  }
    
func removeNonProfileStore(_ offerItem: OfferItem) {
   if offerItem.sampleRequestType == SampleRequestType.workShopSurvey {
   if let userId = UserManager.shared.user?.userID {
       UserDefaults.standard.removeObject(forKey: "nonProfileStore-\(userId)")
       UserDefaults.standard.removeObject(forKey: Constants.nonProfileTempKey)
      if let profileStore = self.networkManager.userManager?.profileStore {
           profileStore.removeNonProfileValue(forKey: profileStore.nonProfileKey)
       }
    }
  }
 }
}

extension SurveyManager {

var canGoToNextPage: Bool {
    guard let currentPage = currentPage else {
        return false
    }
    
    var canProceed = true
    
    for block in currentPage.blocks {
        if (self.value(forBlock: block) != nil) || (self.temporaryValue(forBlock: block) != nil) ||
            (self.nonProfileTemporaryValue(forBlock: block) != nil) || (self.nonProfileValue(forBlock: block) != nil) {
            continue
        } else {
            canProceed = false
        }
    }
    return canProceed
}

func goToPage(_ index: Int, _ completion: (SurveyError?) -> Void) {
    guard let survey = self.survey else {
        completion(SurveyError.surveyNotLoaded)
        return
    }
    
    guard index >= 0, index < survey.pages.count else {
        completion(SurveyError.unableToLoadPage)
        return
    }
    
    let page = survey.pages[index]
    currentPage = page
    completion(nil)
}

func nextPage(isSurveyStart: Bool = false,
              offerItem: OfferItem? = nil,
              _ completion: (SurveyError?) -> Void) {
    guard let survey = self.survey else {
        completion(SurveyError.surveyNotLoaded)
        return
    }
    
    // set to zero as a default for survey starts
    var nextIndex = 0
    
    if !isSurveyStart {
        guard let index = currentIndex else {
            completion(SurveyError.unableToLoadPage)
            return
        }
        nextIndex = index + 1
    }
    
    guard nextIndex >= 0, nextIndex < survey.pages.count else {
        finish(offerItem)
        completion(SurveyError.endReached)
        return
    }
    
    guard let profileStore = networkManager.userManager?.profileStore else {
        completion(SurveyError.unableToLoadPage)
        return
    }
        
    var foundNextPage = false
    
    while !foundNextPage && nextIndex < survey.pages.count {
        let nextPage = survey.pages[nextIndex]
        let hasTests = !nextPage.includeIf.isEmpty

        if let selectedOffer = offerItem,
              let sampleRequestType = selectedOffer.sampleRequestType,
              sampleRequestType == SampleRequestType.workShopSurvey {
              let shouldSkipQuestion = skipQuestionForWorkShopSurvey(profileStore, nextPage)
              if shouldSkipQuestion {
                  nextIndex += 1
                  continue
              }
        }
        
        var allValues = [String: AnyHashable]()
        // merge existing profile with any new data to run logic
        let existingValues = profileStore.values
        let newValues = profileStore.temporaryvalues
        allValues = existingValues.merging(newValues) { (_, new) in new }

        if let selectedOffer = offerItem,
            let sampleRequestType = selectedOffer.sampleRequestType,
            sampleRequestType == SampleRequestType.workShopSurvey, let userId = networkManager.userManager?.user?.userID {
            let nonProfileStore = UserDefaults.standard.value(forKey: "nonProfileStore-\(userId)")
            let nonProfileTemp = UserDefaults.standard.value(forKey: Constants.nonProfileTempKey)
            let existingNonProfileValues = nonProfileStore as? [String: AnyHashable] ?? [:]
            let newNonProfileValues = nonProfileTemp as? [String: AnyHashable] ?? [:]
            let nonProfileAllValues = existingNonProfileValues.merging(newNonProfileValues) { (_, new) in new }
            allValues = allValues.merging(nonProfileAllValues) { (_, new) in new }
        }
                
        if !hasTests || (hasTests && evaluateJSONLogicTest(tests: nextPage.includeIf, data: allValues)) {
            foundNextPage = true
            currentPage = nextPage
        } else {
            nextIndex += 1
        }
    }
    if !foundNextPage {
        finish(offerItem)
        completion(SurveyError.endReached)
        return
    }
    completion(nil)
}
     
func skipQuestionForWorkShopSurvey(_ profileStore: ProfileStore, _ surveyPage: SurveyPage) -> Bool {
   let profileQuestions = surveyPage.blocks.filter({$0.isProfile == true})
   if profileQuestions.isEmpty == false {
    let profileQuestion = profileQuestions.map({$0.blockID})
    if let questionId = profileQuestion[0] {
        let value = profileStore.values[questionId]
        if value != nil {
          return true
        }
    }
  }
  return false
}

func previousPage(_ completion: (SurveyError?) -> Void) {
    guard let survey = self.survey else {
        completion(SurveyError.surveyNotLoaded)
        return
    }
    guard let index = currentIndex, index > 0 else {
        completion(nil)
        return
    }
    let previousPage = survey.pages[index - 1]
    self.currentPage = previousPage
    completion(nil)
 }
}
