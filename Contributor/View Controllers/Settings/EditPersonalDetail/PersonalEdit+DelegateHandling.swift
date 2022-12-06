//
//  PersonalEdit+DelegateHandling.swift
//  Contributor
//
//  Created by KiwiTech on 9/30/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import EmailValidator

extension PersonalEditViewController: FormDatasourceDelegate {

func clickToPeformAction(_ updatedFormData: [FormSection]) {
  self.view.endEditing(true)
  let email = updatedFormData.flatMap({$0.sectionValue.filter({$0.textFieldType == .email})}).map({$0.fieldValue})[0]
  let firstName = updatedFormData.flatMap({$0.sectionValue.filter({$0.textFieldType == .firstName})}).map({$0.fieldValue})[0]
  let lastName = updatedFormData.flatMap({$0.sectionValue.filter({$0.textFieldType1 == .lastName})}).map({$0.fieldValue1})[0]
  if !email.isEmpty && !firstName.isEmpty && !lastName.isEmpty {
     updatePersonalDetail(email, firstName, lastName)
  } else {
    NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
  }
}
    
func clickToOpenTerms() {}
func clickoOpenPrivacy() {}
}

extension PersonalEditViewController {
func updatePersonalDetail(_ email: String, _ firstName: String, _ lastName: String) {
    let userInfo: [User.CodingKeys: Any] = [
      User.CodingKeys.email: email,
      User.CodingKeys.firstName: firstName,
      User.CodingKeys.lastName: lastName
    ]
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    activityIndicator.updateIndicatorView(self, hidden: false)
    NetworkManager.shared.updateUser(userInfo, completion: { [weak self] (error) in
      guard let this = self else {return}
      this.activityIndicator.updateIndicatorView(this, hidden: true)
      this.personalData.removeAll()
      if let _ = error {
        let toaster = Toaster(view: this.view)
        toaster.toast(message: Text.generalError.localized())
      } else {
        this.navigationController?.popViewController(animated: true)
      }
    })
  }
}
