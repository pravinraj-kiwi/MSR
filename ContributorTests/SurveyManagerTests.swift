//
//  SurveyManagerTests.swift
//  ContributorTests
//
//  Created by arvindh on 06/08/19.
//  Copyright © 2019 Measure. All rights reserved.
//

@testable import Measure_Staging_2
import XCTest
import Moya
import UIKit
import Alamofire

class SurveyManagerTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  fileprivate func createNetworkManager() -> NetworkManager {
    let provider = MoyaProvider<ContributorAPI>(stubClosure: MoyaProvider.immediatelyStub)
    let networkManager = NetworkManager(userManager: UserManager(defaults: Defaults), provider: provider)
    return networkManager
  }
    
    func createUserAndLogIn(user: User? = nil) {
      let user = user ?? Helper.createUser()
      let param = ["username": user.email,
                   "password": "123456"]
      Alamofire.request("\(Constants.baseContributorAPIURL)/v1/login",
                        method: .post, parameters: param,
                        encoding: JSONEncoding.default)
          .validate()
          .responseJSON { response in
              switch response.result {
              case .success(let response):
                  if let result = response as? NSDictionary,
                      let accessToken = result.value(forKey: "access") as? String,
                      let refreshToken = result.value(forKey: "refresh") as? String {
                  user.accessToken = accessToken
                  user.refreshToken = refreshToken
              }
              case .failure(_): break
              }
          Defaults[.user] = user
      }
    }
  
  fileprivate func createSurvey() -> Survey {
    let data = NSDataAsset(name: "getSurvey")!.data
    let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
    let survey = Survey(JSON: json)
    return survey!
  }
  
  fileprivate func createSurveyManagerWithSurvey() -> SurveyManager? {
    let networkManager = createNetworkManager()
    let survey = createSurvey()
    if let surveyCat = survey.category {
        let cat = SurveyType.category(category: surveyCat)
        let surveyManager = SurveyManager(survey: survey, surveyType: cat, networkManager: networkManager)
        return surveyManager
    }
    return nil
  }
  
  func testSurveyShouldNotBeNilAtStart() {
    let networkManager = createNetworkManager()
    let survey = createSurvey()
    if let surveyCat = survey.category {
        let cat = SurveyType.category(category: surveyCat)
        let surveyManager = SurveyManager(survey: survey, surveyType: cat, networkManager: networkManager)
        let expectation = XCTestExpectation(description: "Survey should start")
        surveyManager.fetchSurveyAndStart { (_) in
          expectation.fulfill()
        }
    }
  }
  
  func testSurveyEndReached() {
    let surveyManager = createSurveyManagerWithSurvey()
    let numberOfPages = surveyManager?.survey?.pages.count ?? 0
    surveyManager?.goToPage(numberOfPages-1) { (error) in
      XCTAssert(error == nil)
        XCTAssert(surveyManager?.canGoToNextPage == false)
      
        surveyManager?.nextPage({ (nextPageError) in
        XCTAssert(nextPageError == SurveyError.endReached)
      })
    }
  }
  
  func testSurveyNextPage() {
    let surveyManager = createSurveyManagerWithSurvey()
    _ = surveyManager?.currentIndex ?? 1
    surveyManager?.nextPage({ (_) in
    })
  }
  
  func testSurveyPreviousPage() {
    let surveyManager = createSurveyManagerWithSurvey()
    
    surveyManager?.goToPage(1) { (error) in
      XCTAssert(error == nil)
        let currentIndex = surveyManager?.currentIndex ?? 0

        surveyManager?.previousPage({ (previousPageError) in
        XCTAssert(previousPageError == nil)
            XCTAssert((surveyManager?.currentIndex!)! < currentIndex)
      })
    }
  }
  
  func testSurveyPreviousPageWhenOnFirstPage() {
    let surveyManager = createSurveyManagerWithSurvey()
    surveyManager?.previousPage({ (previousPageError) in
      XCTAssert(previousPageError == nil)
     let currentIndex = surveyManager?.currentIndex ?? 0
      XCTAssert(currentIndex == 0)
    })
  }
  
  func testSurveySetValue() {
    let surveyManager = createSurveyManagerWithSurvey()
    if  let page = surveyManager?.currentPage,
        let block = page.blocks.first {
        let newValue = RadioBlockResponse()
        newValue.value = block.choices?.first
        surveyManager!.setValue(newValue, forBlock: block)
        if let profileStore = surveyManager?.networkManager.userManager?.profileStore,
           let blockId = block.blockID {
            let storedValue = profileStore[blockId]
          XCTAssert(storedValue == newValue.value?.value)
        }
    }
  }
  
  func testSurveySetNilValue() {
    let surveyManager = createSurveyManagerWithSurvey()
    if let page = surveyManager?.currentPage, let block = page.blocks.first {
        surveyManager?.setValue(nil, forBlock: block)
        if let profileStore = surveyManager?.networkManager.userManager?.profileStore,
           let blockId = block.blockID {
            let storedValue = profileStore[blockId]
            XCTAssert(storedValue == nil)
        }
    }
  }
  
  func testSurveyInitialValues() {
    let surveyManager = createSurveyManagerWithSurvey()
    let values = surveyManager?.values.mapValues { (r) -> AnyHashable? in
      return r.jsonValue
    }
    
    if let profileStore = surveyManager?.networkManager.userManager?.profileStore {
        let storedValues = profileStore.values(for: (surveyManager?.survey!)!).mapValues { (r) -> AnyHashable? in
          return r.jsonValue
        }
        XCTAssert(storedValues == values)
    }
  }
}
