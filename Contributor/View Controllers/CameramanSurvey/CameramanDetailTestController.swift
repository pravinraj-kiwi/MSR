//
//  CameramanDetailTestController.swift
//  Contributor
//
//  Created by KiwiTech on 12/10/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class CameramanDetailTestController: UIViewController {
    
 @IBOutlet weak var tableView: UITableView!
 @IBOutlet weak var validationDetailText: UITextView!
 @IBOutlet weak var validationDetailStatus: UILabel!
 var testModel = CameramanTestModel()
 var validationDetailDatasource = ValidationTestDetailDatasource()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    tableView.delegate = validationDetailDatasource
    tableView.dataSource = validationDetailDatasource
    validationDetailDatasource.retroValidation = testModel
    tableView.reloadData()
    if let ocrTextArray = testModel.extractedText {
        var extractedText = ""
           for index in 0..<ocrTextArray.count {
            extractedText += "\(ocrTextArray[index])\n"
           }
        validationDetailText.text = extractedText
    }
   if testModel.validationPassed == true {
    if testModel.isNegativeMarker {
        validationDetailStatus.text = "Validation Passed -> ❌"
    } else {
        validationDetailStatus.text = "Validation Passed -> ✅"
    }
   } else {
       validationDetailStatus.text = "Validation Passed -> ❌"
   }
  }
}
