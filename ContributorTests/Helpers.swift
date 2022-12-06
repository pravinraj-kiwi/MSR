//
//  Helpers.swift
//  ContributorTests
//
//  Created by arvindh on 02/09/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation
import UIKit
@testable import Measure_Staging_2

var Defaults = Helper.testDefaults

class Helper {
  static func createUser() -> User {
    let user = User()
    user.email = "mini4dec@yopmail.com"
    user.userID = 6
    user.balanceMSR = 0
    user.firstName = "Arvindh"
    user.lastName = "Sukumar"
    user.selectedCommunitySlug = "measure"
    return user
  }
  
  static var testDefaults: UserDefaults {
    return UserDefaults(suiteName: "TestDefaults")!
  }
}
