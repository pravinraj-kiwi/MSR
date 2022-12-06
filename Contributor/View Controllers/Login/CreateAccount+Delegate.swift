//
//  CreateAccount+Delegate.swift
//  Contributor
//
//  Created by KiwiTech on 10/5/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import Moya

extension CreateAccountViewController: FormDatasourceDelegate {
    
func handleMatchingOfPassword() -> Bool {
  let passwordSection = accountData.flatMap({$0.sectionValue.filter({$0.section == 3})})
  let newPassword = passwordSection.map({$0.fieldValue})[0]
  let confirmPassword = passwordSection.map({$0.fieldValue1})[0]
  if !newPassword.isEmpty && !confirmPassword.isEmpty {
    if  newPassword != confirmPassword {
       _ =  passwordSection.map({$0.passwordNotMatched = true})
        tableView.reloadRows(at: [IndexPath(row: 0, section: 4)], with: .none)
       return false
    } else {
       _ =  passwordSection.map({$0.passwordMatched = true})
        tableView.reloadRows(at: [IndexPath(row: 0, section: 4)], with: .none)
       return true
    }
  }
  return false
}
    
func clickToPeformAction(_ updatedFormData: [FormSection]) {
  self.view.endEditing(true)
  if !handleMatchingOfPassword() || updatedFormData.map({$0.isTermsConditionAccepted })[0] == false {
     NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
     return
  }
  activityIndicator.updateIndicatorView(self, hidden: false)
  let formValues = getSignUpParam(updatedFormData)
  callSignUpApi(params: formValues, updatedFormData)
}
    
func clickToOpenTerms() {
  Helper.clickToOpenUrl(Constants.termsURL, controller: self, shouldPresent: true)
}
func clickoOpenPrivacy() {
  Helper.clickToOpenUrl(Constants.privacyURL, controller: self, shouldPresent: true)
}
    
func getSignUpParam(_ updatedFormData: [FormSection]) -> SignupParams {
 let section = updatedFormData.flatMap({$0.sectionValue.filter({$0.section == 0})})
 let email = section.map({$0.fieldValue})[0]
 let sectionoOne = updatedFormData.flatMap({$0.sectionValue.filter({$0.section == 1})})
 let firstName = sectionoOne.map({$0.fieldValue})[0]
 let lastName = sectionoOne.map({$0.fieldValue1})[0]
 let passwordSection = updatedFormData.flatMap({$0.sectionValue.filter({$0.section == 3})})
 let newPassword = passwordSection.map({$0.fieldValue})[0]
 let isTermAccepted = updatedFormData.map({$0.isTermsConditionAccepted })[0]
    
 let params = SignupParams(firstName: firstName, lastName: lastName,
                           email: email, password: newPassword, timezone: TimeZone.current.identifier,
                           inviteCode: UserManager.shared.deepLinkInviteCode,
                           communitySlug: UserManager.shared.deepLinkCommunitySlug,
                           communityUserID: UserManager.shared.deepLinkCommunityUserID,
                           joinURLString: UserManager.shared.deepLinkURLString, hasAcceptedTerms: isTermAccepted
    )
    return params
}
    
func updateDateOfBirth(_ updatedFormData: [FormSection]) {
  let dobDateBlock = DateBlockResponse()
  let dobSection = updatedFormData.flatMap({$0.sectionValue.filter({$0.section == 2})})
  let dob = dobSection.map({$0.datePickerDate})[0]
  dobDateBlock.value = dob
  if let profileStore = UserManager.shared.profileStore,
     let jsonValue = dobDateBlock.jsonValue {
    profileStore.set(values: ["dob": jsonValue])
    _ = profileStore.updateAgeFromDOB()
  }
}
    
func callSignUpApi(params: SignupParams, _ updatedFormData: [FormSection]) {
 if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
 }
 NetworkManager.shared.signup(params) { [weak self] (error) in
    guard let this = self else { return }
    this.activityIndicator.updateIndicatorView(this, hidden: true)
    if let error = error as? MoyaError {
       this.handleIfAlreadySignedUp(error)
     } else {
       NotificationCenter.default.post(name: .signUpFinished, object: nil)
       AnalyticsManager.shared.log(event: .signUpFormCompleted)
       this.updateDateOfBirth(updatedFormData)
       NetworkManager.shared.addProfileEvent(source: "basic", itemRefs: ["dob"]) { _ in }
       Router.shared.route(to: Route.notificationPermission, from: this,
                           presentationType: PresentationType.push()
          )
      }
    }
}
    
func handleIfAlreadySignedUp(_ error: MoyaError) {
  let statusCode = error.response?.statusCode ?? 500
  if statusCode == 409 {
      let emailSection = accountData.flatMap({$0.sectionValue.filter({$0.section == 0})})
      _ = emailSection.map({$0.accountAlreadyExist = true})
      _ = emailSection.map({$0.shouldShowError = true})
      let errorMessage = Helper.getErrorMessage(error)
      _ = emailSection.map({$0.serverError = errorMessage})
      tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
      tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
    } else {
      let toaster = Toaster(view: self.view)
      toaster.toast(message: SignUpViewText.requestError.localized())
    }
  }
}
