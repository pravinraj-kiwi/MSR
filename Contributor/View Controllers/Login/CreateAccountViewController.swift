//
//  CreateAccountViewController.swift
//  Contributor
//
//  Created by KiwiTech on 10/5/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class CreateAccountViewController: UIViewController {

@IBOutlet weak var tableView: UITableView!
@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
@IBOutlet weak var backButton: UIButton!

var accountDatasource = FormDatasource()
var accountData = [FormSection]()

override func viewDidLoad() {
  super.viewDidLoad()
  // Do any additional setup after loading the view.
  self.view.endEditing(false)
  applyCommunityTheme()
  activityIndicator.updateIndicatorView(self, hidden: true)
  view.backgroundColor = Utilities.getRgbColor(247, 247, 247)
  resetDefault()
  setUpDataSource()
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.signUpScreen)
}
    
override func viewWillDisappear(_ animated: Bool) {
  super.viewWillDisappear(animated)
  resetDefault()
}
    
func resetDefault() {
  Defaults.remove(.accountNewPassword)
  Defaults.remove(.accountConfirmPassword)
  Defaults.remove(.accountSelectedDate)
}
    
func registerNib() {
 tableView.register(cellType: FormAcceptanceCell.self)
 tableView.register(cellType: SectionViewCell.self)
 tableView.register(cellType: PlaceholderFormCell.self)
 tableView.register(cellType: FooterCell.self)
 tableView.register(cellType: PlaceHolderMultiCell.self)
 tableView.rowHeight = 56
 tableView.estimatedRowHeight = 56
}
   
func setUpDataSource() {
 registerNib()
 accountDatasource.extraSec = 2
 accountDatasource.screenType = .createAccount
 accountDatasource.tableView = tableView
 accountDatasource.formData = updateAccountData()
 accountDatasource.delegate = self
 tableView.dataSource = accountDatasource
 tableView.delegate = accountDatasource
 tableView.reloadData()
}
   
func updateAccountData() -> [FormSection] {
  let emailField = FormModel()
  emailField.textFieldType = .email
  emailField.placeholderValue = PlaceholderTextValue.email
  emailField.section = 0
  
  let nameField = FormModel()
  nameField.placeholderKey = PlaceholderText.firstName
  nameField.textFieldType = .firstName
  nameField.placeholderValue = PlaceholderTextValue.firstName
  nameField.placeholderKey1 = PlaceholderText.lastName
  nameField.textFieldType1 = .lastName
  nameField.placeholderValue1 = PlaceholderTextValue.lastName
  nameField.showPasswordIcon = false
  nameField.section = 1

  let dobField = FormModel()
  dobField.textFieldType = .dateOfBirth
  dobField.placeholderKey = PlaceholderText.dob.localized()
  dobField.placeholderValue = PlaceholderTextValue.dob
  dobField.section = 2
    
  let passwordField = FormModel()
  passwordField.placeholderKey = PlaceholderText.password.localized()
  passwordField.textFieldType = .signUpNewPassword
  passwordField.placeholderValue = PlaceholderTextValue.newPassword.localized()
  passwordField.placeholderKey1 = PlaceholderText.password.localized()
  passwordField.textFieldType1 = .signUpConfirmPassword
  passwordField.placeholderValue1 = PlaceholderTextValue.confirmPassword.localized()
  passwordField.showPasswordIcon = false
  passwordField.section = 3
    
  let referalCodeField = FormModel()
  referalCodeField.textFieldType = .referalCode
  referalCodeField.placeholderKey = PlaceholderText.referalCode.localized()
  referalCodeField.placeholderValue = PlaceholderTextValue.referalCode
  referalCodeField.fieldValue = UserManager.shared.deepLinkInviteCode ?? ""
  referalCodeField.hintText = Text.hintText.localized()
  referalCodeField.section = 4

  accountData = [FormSection.init(formType: .singleCell, formSection: 0, formValue: [emailField]),
                  FormSection.init(formType: .multiCell, formSection: 1, formValue: [nameField]),
                  FormSection.init(formType: .singleCell, formSection: 2, formValue: [dobField]),
                  FormSection.init(formType: .multiCell, formSection: 3, formValue: [passwordField]),
                  FormSection.init(formType: .singleCell, formSection: 4, formValue: [referalCodeField])]
  return accountData
}
    
@IBAction func clickToGoBack(_ sender: Any) {
   self.navigationController?.popViewController(animated: true)
  }
    
deinit {
   NotificationCenter.default.removeObserver(self, name: Constants.notifName, object: nil)
   NotificationCenter.default.removeObserver(self, name: Constants.notifErrorName, object: nil)
  }
}

extension CreateAccountViewController: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
   guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      backButton.tintColor = Color.primary.value
      return
    }
    backButton.tintColor = colors.primary
  }
}
