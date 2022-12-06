//
//  PersonalEditViewController.swift
//  Contributor
//
//  Created by KiwiTech on 9/29/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class PersonalEditViewController: UIViewController {
    
 @IBOutlet weak var tableView: UITableView!
 @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
 var personalData = [FormSection]()
 var hasStartedTyping = false
 let editDatasource = FormDatasource()
    
 override func viewDidLoad() {
   super.viewDidLoad()
   // Do any additional setup after loading the view.
   self.view.endEditing(false)
   activityIndicator.updateIndicatorView(self, hidden: true)
   view.backgroundColor = Utilities.getRgbColor(247, 247, 247)
   setUpDataSource()
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.personalDetailScreen)
}

func registerNib() {
 tableView.register(cellType: SectionViewCell.self)
 tableView.register(cellType: PlaceholderFormCell.self)
 tableView.register(cellType: FooterCell.self)
 tableView.register(cellType: PlaceHolderMultiCell.self)
 tableView.rowHeight = 56
 tableView.estimatedRowHeight = 56
}
    
func setUpDataSource() {
  registerNib()
  editDatasource.extraSec = 1
  editDatasource.screenType = .personalDetail
  editDatasource.tableView = tableView
  editDatasource.formData = updatePersonalData()
  editDatasource.delegate = self
  tableView.dataSource = editDatasource
  tableView.delegate = editDatasource
  tableView.reloadData()
}
    
func updatePersonalData() -> [FormSection] {
  let user = UserManager.shared.user
  let emailEdit = FormModel()
  emailEdit.textFieldType = .email
  emailEdit.fieldValue = user?.email ?? ""
  emailEdit.section = 0
  
  let nameEdit = FormModel()
  nameEdit.placeholderKey = PlaceholderText.firstName.localized()
  nameEdit.textFieldType = .firstName
  nameEdit.fieldValue = user?.firstName ?? ""
  nameEdit.placeholderKey1 = PlaceholderText.lastName.localized()
  nameEdit.textFieldType1 = .lastName
  nameEdit.fieldValue1 = user?.lastName ?? ""
  nameEdit.section = 1

  personalData = [FormSection.init(formType: .singleCell, formSection: 0, formValue: [emailEdit]),
                  FormSection.init(formType: .multiCell, formSection: 1, formValue: [nameEdit])]
  return personalData
 }
    
deinit {
  NotificationCenter.default.removeObserver(self, name: Constants.notifName, object: nil)
  NotificationCenter.default.removeObserver(self, name: Constants.notifErrorName, object: nil)
  }
}
