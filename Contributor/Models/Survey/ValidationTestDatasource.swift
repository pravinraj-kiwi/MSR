//
//  ValidationTestDatasource.swift
//  Contributor
//
//  Created by KiwiTech on 12/9/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol ValidationTestDelegate: class {
    func clickToOpenDetail(_ testModel: CameramanTestModel)
}

class ValidationTestDatasource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
 var retroValidationArray: [CameramanTestModel] = []
 weak var delegate: ValidationTestDelegate?

 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return retroValidationArray.count
 }

 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(with: ValidationTestCell.self, for: indexPath)
    let testResult = retroValidationArray[indexPath.row]
    cell.updateCellContent(testResult)
    return cell
 }
    
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let testResult = retroValidationArray[indexPath.row]
    delegate?.clickToOpenDetail(testResult)
 }
}

class ValidationTestDetailDatasource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
 var retroValidation: CameramanTestModel?

 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
 }

 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(with: ValidationTestDetailCell.self, for: indexPath)
    if let retroData = retroValidation {
      cell.updateCellContent(retroData)
    }
    return cell
 }
}
