//
//  PersonalEditDatasource.swift
//  Contributor
//
//  Created by KiwiTech on 9/29/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol FormDatasourceDelegate: class {
 func clickToPeformAction(_ updatedFormData: [FormSection])
 func clickToOpenTerms()
 func clickoOpenPrivacy()
}

class FormDatasource: NSObject, UITableViewDelegate, UITableViewDataSource {
var formData = [FormSection]()
var extraSec: Int = 0
let extraRow = SettingSection.settingCount.rawValue
let initialSection = SettingSection.settingSection.rawValue
let secondSection = SettingSection.settingCount.rawValue
let initialRow = SettingSection.settingSection.rawValue
weak var delegate: FormDatasourceDelegate?
var hasStartedTyping: Bool = false
var tableView: UITableView?
let tagOne = TextFieldTag.one.rawValue
let tagTwo = TextFieldTag.two.rawValue
let tagThree = TextFieldTag.three.rawValue
var screenType: ScreenType = .personalDetail

func numberOfSections(in tableView: UITableView) -> Int {
   return extraRow + formData.count + extraSec
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  if section == initialRow {
   return extraRow
  }
  if section <= formData.count {
    let sectionRow = formData[section - extraRow]
    return sectionRow.sectionValue.count
  }
  return extraRow
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  if indexPath.section == initialSection {
    let cell = tableView.dequeueReusableCell(with: SectionViewCell.self, for: indexPath)
    updateFirstCellSection(indexPath.section, cell)
    return cell
  }
  if indexPath.section <= formData.count {
    let sectionRow = formData[indexPath.section - extraRow]
    return updateCell(tableView, sectionRow, indexPath)
  }
  if extraSec == 2 && indexPath.section == tableView.numberOfSections - extraSec {
    let cell = tableView.dequeueReusableCell(with: FormAcceptanceCell.self, for: indexPath)
    cell.updateUI()
    cell.acceptanceDelegate = self
    return cell
  }
  let cell = tableView.dequeueReusableCell(with: FooterCell.self, for: indexPath)
  cell.delegate = self
  updateFooterCell(cell)
  return cell
}

func updateCell(_ tableView: UITableView, _ sectionRow: FormSection,
                _ indexPath: IndexPath) -> UITableViewCell {
 if sectionRow.cellType == .multiCell {
   let cell = tableView.dequeueReusableCell(with: PlaceHolderMultiCell.self, for: indexPath)
   let personalData = sectionRow.sectionValue[indexPath.row]
   cell.formMultiData = personalData
   cell.multiDelegate = self
   cell.formModel = sectionRow.sectionValue
   cell.updateMultiUI(personalData)
   if screenType == .personalDetail {
     cell.formFieldLastName.returnKeyType = .done
   } else {
     cell.formFieldLastName.returnKeyType = .next
   }
   return cell
 }
 if sectionRow.cellType == .tripleCell {
   let cell = tableView.dequeueReusableCell(with: TripleTextFieldsCell.self, for: indexPath)
   let personalData = sectionRow.sectionValue[indexPath.row]
   cell.formTripleData = personalData
   cell.tripleDelegate = self
   cell.updateTripleUI(personalData)
   return cell
  }
  let cell = tableView.dequeueReusableCell(with: PlaceholderFormCell.self, for: indexPath)
  cell.screenType = screenType
  getPlaceHolderCell(tableView, cell, indexPath)
  return cell
}

func updateFooterCell(_ cell: FooterCell) {
  cell.backgroundColor = .clear
  cell.delegate = self
  if screenType == .changePassword || screenType == .createAccount {
    cell.updateButton.isUserInteractionEnabled = false
    cell.updateButton.layer.opacity = 0.5
  } else {
    cell.updateButton.isUserInteractionEnabled = true
    cell.updateButton.layer.opacity = 1.0
  }
  if screenType == .changePassword || screenType == .personalDetail {
    cell.updateButton.setTitle(Text.updateText.localized(), for: .normal)
  } else {
    cell.updateButton.setTitle(Text.accountText.localized(), for: .normal)
  }
 if screenType != .personalDetail {
    if cell.hasNoError {
        cell.updateButton.isUserInteractionEnabled = true
        cell.updateButton.layer.opacity = 1.0
     } else {
        cell.updateButton.isUserInteractionEnabled = false
        cell.updateButton.layer.opacity = 0.5
      }
    }
}

func getPlaceHolderCell(_ tableView: UITableView,
                        _ cell: PlaceholderFormCell,
                        _ indexPath: IndexPath) {
  let section = formData[indexPath.section - extraRow]
  let personalData = section.sectionValue[indexPath.row]
  cell.placeholderDelegate = self
  cell.cellType = section.cellType
  cell.formModelData = section.sectionValue
  cell.formData = personalData
  cell.updateUI(personalData)
}
    
func updateFirstCellSection(_ section: Int,
                            _ view: SectionViewCell) {
  view.dateLabel.font = Font.bold.of(size: 32)
  switch screenType {
  case .changePassword: view.dateLabel.text = SettingViewText.changePassword.localized()
  case .personalDetail: view.dateLabel.text = SettingViewText.personalDetail.localized()
  case .createAccount: view.dateLabel.text = Text.createAccount.localized()
  default:
    debugPrint("No Action needed")
  }
}
    
func tableView(_ tableView: UITableView,
               viewForHeaderInSection section: Int) -> UIView? {
  let view = UIView()
  view.tintColor = .clear
  return view
}

func tableView(_ tableView: UITableView,
               heightForHeaderInSection section: Int) -> CGFloat {
  if section == initialSection {
    return CGFloat(FormList.zero)
  }
  if section == secondSection {
    return FormList.heightForFooterSecondSec
  }
  return FormList.heightForOtherHeaderSec
}
    
func tableView(_ tableView: UITableView,
               heightForRowAt indexPath: IndexPath) -> CGFloat {
  if indexPath.section == initialRow {
    return FormList.heightForFooterSec
  }
  if indexPath.section <= formData.count {
    return UITableView.automaticDimension
  }
 return SettingList.heightForRow
  }
}

extension FormDatasource {
func reloadCell(_ formModel: [FormModel],
                _ cell: PlaceholderFormCell) {
  DispatchQueue.main.async {
    self.tableView?.beginUpdates()
    cell.updateFormError(formModel)
    self.tableView?.endUpdates()
   }
}
    
func reloadMultiCell(_ textField: UITextField,
                     _ formModel: [FormModel],
                     _ cell: PlaceHolderMultiCell) {
  DispatchQueue.main.async {
    self.tableView?.beginUpdates()
    cell.updateMultiFormError(formModel)
    self.tableView?.endUpdates()
  }
}
    
func reloadTripleCell(_ textField: UITextField,
                      _ formModel: [FormModel],
                      _ cell: TripleTextFieldsCell) {
  DispatchQueue.main.async {
    self.tableView?.beginUpdates()
    cell.updateTripleFormError(textField, formModel)
    self.tableView?.endUpdates()
  }
 }
}

extension FormDatasource: FooterCellDelegate {
func clickToPerformAction() {
   delegate?.clickToPeformAction(formData)
  }
}

extension FormDatasource: FormAcceptanceDelegate {
func clickToOpenTerms() {
  delegate?.clickToOpenTerms()
}

func clickoOpenPrivacy() {
  delegate?.clickoOpenPrivacy()
}
 
func acceptedTermsCondition(_ isSelected: Bool) {
    self.tableView?.endEditing(true)
 _ = formData.compactMap({$0.isTermsConditionAccepted = isSelected})
 NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton,
                                 object: nil)
 if validateFieldsForCreateAccount() {
    NotificationCenter.default.post(name: NSNotification.Name.updateButton,
                                    object: nil)
  }
 }
}
