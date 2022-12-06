//
//  ChangePasswordViewController.swift
//  Contributor
//
//  Created by KiwiTech on 10/1/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class ChangePasswordViewController: UIViewController {

@IBOutlet weak var tableView: UITableView!
@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   
var passwordDatasource = FormDatasource()
var changePasswordData = [FormSection]()

override func viewDidLoad() {
  super.viewDidLoad()
  // Do any additional setup after loading the view.
  self.view.endEditing(false)
  activityIndicator.updateIndicatorView(self, hidden: true)
  view.backgroundColor = Utilities.getRgbColor(247, 247, 247)
  resetDefault()
  setUpDataSource()
}

override func viewWillDisappear(_ animated: Bool) {
  super.viewWillDisappear(animated)
  resetDefault()
}
 
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.changePasswordScreen)
}
    
func resetDefault() {
  Defaults.remove(.tripleCurrentPassword)
  Defaults.remove(.tripleNewPassword)
  Defaults.remove(.tripleConfirmPassword)
}
    
func registerNib() {
 tableView.register(cellType: SectionViewCell.self)
 tableView.register(cellType: TripleTextFieldsCell.self)
 tableView.register(cellType: FooterCell.self)
 tableView.rowHeight = 56
 tableView.estimatedRowHeight = 56
}
   
func setUpDataSource() {
 registerNib()
 passwordDatasource.extraSec = 1
 passwordDatasource.screenType = .changePassword
 passwordDatasource.tableView = tableView
 passwordDatasource.formData = updateChangePasswordData()
 passwordDatasource.delegate = self
 tableView.dataSource = passwordDatasource
 tableView.delegate = passwordDatasource
 tableView.reloadData()
}
   
func updateChangePasswordData() -> [FormSection] {
 let password = FormModel()
 password.textFieldType = .currentPassword
    password.placeholderKey = PlaceholderText.currentPassword.localized()
    password.placeholderValue = PlaceholderTextValue.currentPassword.localized()
 password.textFieldType1 = .newPassword
    password.placeholderKey1 = PlaceholderText.newPassword.localized()
    password.placeholderValue1 = PlaceholderTextValue.newPassword.localized()
 password.textFieldType2 = .confirmNewPassword
    password.placeholderKey2 = PlaceholderText.confirmPassword.localized()
    password.placeholderValue2 = PlaceholderTextValue.confirmPassword.localized()
 password.section = 0
 password.showPasswordIcon = true
    
 changePasswordData = [FormSection.init(formType: .tripleCell,
                                        formSection: 0,
                                        formValue: [password])]
 return changePasswordData
 }
    
deinit {
  NotificationCenter.default.removeObserver(self, name: Constants.notifName, object: nil)
  NotificationCenter.default.removeObserver(self, name: Constants.notifErrorName, object: nil)
  }
}
