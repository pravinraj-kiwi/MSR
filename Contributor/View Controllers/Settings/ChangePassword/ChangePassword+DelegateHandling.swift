//
//  ChangePassword+DelegateHandling.swift
//  Contributor
//
//  Created by KiwiTech on 10/1/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya

extension ChangePasswordViewController: FormDatasourceDelegate {

func hasPasswordMatched() -> Bool {
  let newPassword = changePasswordData.flatMap({$0.sectionValue.map({$0.fieldValue1})})[0]
  let confirmPassword = changePasswordData.flatMap({$0.sectionValue.map({$0.fieldValue2})})[0]
  if !newPassword.isEmpty && !confirmPassword.isEmpty {
    if  newPassword != confirmPassword {
        _ =  changePasswordData.compactMap({$0.sectionValue.map({$0.passwordNotMatched = true})})
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        return false
    } else {
        _ =  changePasswordData.compactMap({$0.sectionValue.map({$0.passwordNotMatched = false})})
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        return true
    }
  } 
  return false
}
    
func clickToPeformAction(_ updatedFormData: [FormSection]) {
  self.view.endEditing(true)
  if !hasPasswordMatched() {
    NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
    return
  }
  if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
  }
   let currentPassword = updatedFormData.flatMap({$0.sectionValue.map({$0.fieldValue})})[0]
   let newPassword = updatedFormData.flatMap({$0.sectionValue.map({$0.fieldValue1})})[0]
   activityIndicator.updateIndicatorView(self, hidden: false)
   NetworkManager.shared.updatePassword(currentPassword: currentPassword, newPassword) { [weak self] error in
    guard let this = self else { return }
    this.activityIndicator.updateIndicatorView(this, hidden: true)
    if let error = error as? MoyaError {
       this.handleIfCurrentPasswordWrong(error)
     } else {
        this.navigationController?.popViewController(animated: true)
     }
  }
}
    
func handleIfCurrentPasswordWrong(_ error: MoyaError) {
  let statusCode = error.response?.statusCode ?? 500
  if statusCode == 409 {
      let changePasswordSection = changePasswordData.flatMap({$0.sectionValue.filter({$0.section == 0})})
      _ = changePasswordSection.map({$0.wrongCurrentPassword = true})
      _ = changePasswordSection.map({$0.shouldShowError = true})
      let errorMessage = Text.currentPasswordError.localized()
      _ = changePasswordSection.map({$0.serverError = errorMessage})
      tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
   } else {
      let toaster = Toaster(view: self.view)
      toaster.toast(message: SignUpViewText.requestError.localized())
   }
}
    
func clickToOpenTerms() {}
func clickoOpenPrivacy() {}
}
