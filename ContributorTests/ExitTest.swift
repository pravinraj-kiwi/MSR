//
//  ExitTest.swift
//  ContributorTests
//
//  Created by KiwiTech on 12/7/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import XCTest
import UIKit
@testable import Measure_Staging_2

class ExitTest: XCTestCase {
    
    var exitVC: ExitJobViewController!

    override func setUpWithError() throws {
        let storyboard = UIStoryboard(name: "Job", bundle: nil)
        exitVC = storyboard.instantiateViewController(withIdentifier: "ExitJobViewController") as? ExitJobViewController
        if exitVC != nil {
            exitVC.loadViewIfNeeded()
        }
    }

    override func tearDownWithError() throws {
        exitVC = nil
    }

    func testExample() throws {
      exitVC.exitJobDatasource.delegate?.clickOtherReason()
      exitVC.requestModel?.reasonType = "do_not_use_app"
      exitVC.exitJobDatasource.delegate?.clickToExit()
    }

    func testPerformanceExample() throws {
        
    }
}
