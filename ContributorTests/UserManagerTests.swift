//
//  UserManagerTests.swift
//  ContributorTests
//
//  Created by arvindh on 02/09/18.
//  Copyright © 2018 Measure. All rights reserved.
//

@testable import Measure_Staging_2
import SwiftyUserDefaults
import KeychainSwift
import Moya
import XCTest
import UIKit
import Alamofire

class UserManagerTests: XCTestCase {
  var userManager: UserManager!
  var networkManager: NetworkManager! 
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    Defaults.removeAll()
    userManager = UserManager(defaults: Defaults)
    createUserAndLogIn()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  fileprivate func createNetworkManager() {
    let provider = MoyaProvider<ContributorAPI>(stubClosure: MoyaProvider.immediatelyStub)
    networkManager = NetworkManager(userManager: userManager, provider: provider)
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
        self.userManager.setUser(user)
        Defaults[.user] = user
    }
  }

  func testLoadLoggedInUser() {
    createUserAndLogIn()
  }
  
  func testToggleAmazonDatasource() {
    let datasource = DataSource.amazon
    let isOn = userManager.isOn(dataSource: datasource)
    createUserAndLogIn()
    
    userManager.toggle(dataSource: datasource) { (_) in
      let newIsOn = self.userManager.isOn(dataSource: datasource)
      XCTAssert(isOn == !newIsOn)
    }
  }
  
  func testToggleLocationDatasource() {
    let datasource = DataSource.location
    let isOn = userManager.isOn(dataSource: datasource)
    createUserAndLogIn()
    
    userManager.toggle(dataSource: datasource) { (_) in
      let newIsOn = self.userManager.isOn(dataSource: datasource)
      XCTAssert(isOn == !newIsOn)
    }
  }
  
  func testToggleHealthDatasource() {
    let datasource = DataSource.health
    let isOn = userManager.isOn(dataSource: datasource)
    createUserAndLogIn()
    
    userManager.toggle(dataSource: datasource) { (_) in
      let newIsOn = self.userManager.isOn(dataSource: datasource)
      XCTAssert(isOn == !newIsOn)
    }
  }
  
  func testToggleSpotifyDatasource() {
    let datasource = DataSource.spotify
    let isOn = userManager.isOn(dataSource: datasource)
    createUserAndLogIn()
    
    userManager.toggle(dataSource: datasource) { (_) in
      let newIsOn = self.userManager.isOn(dataSource: datasource)
      XCTAssert(isOn == !newIsOn)
    }
  }
}
