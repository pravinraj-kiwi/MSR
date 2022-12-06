//
//  PayPalDataSource.swift
//  Contributor
//
//  Created by Shashi Kumar on 09/03/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit
import UIKit
import AFDateHelper
import EmailValidator

protocol PayPalDataSourceDelegate: class {
    func clickToPeformAction(_ updatedFormData: [FormSection])
    func clickToOpenTerms()
}
class PayPalDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: PayPalDataSourceDelegate?
    var formData = [FormSection]()
    var hasStartedTyping: Bool = false
    var tableView: UITableView?
    let tagOne = TextFieldTag.one.rawValue
    let tagTwo = TextFieldTag.two.rawValue
    let extraRow = SettingSection.settingCount.rawValue
    var extraSec: Int = 2
    let initialSection = SettingSection.settingSection.rawValue
    let initialRow = SettingSection.settingSection.rawValue
    var hideAllRows : Bool = false
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if hideAllRows {
            return 0
        }
        return  formData.count + extraSec
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hideAllRows {
            return 0
        }
        if section < formData.count {
            return 1
        }
        return extraRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section < formData.count {
            let sectionRow = formData[indexPath.section]
            return updateCell(tableView, sectionRow, indexPath)
        }
        if extraSec == 2 && indexPath.section == tableView.numberOfSections - extraSec {
            let cell = tableView.dequeueReusableCell(with: FormAcceptanceCell.self,
                                                     for: indexPath)
            cell.screenType = .redeemScreen
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
        let cell = tableView.dequeueReusableCell(with: PayPalInputCell.self, for: indexPath)
        getPlaceHolderCell(tableView, cell, indexPath)
        return cell
    }
    func getPlaceHolderCell(_ tableView: UITableView,
                            _ cell: PayPalInputCell,
                            _ indexPath: IndexPath) {
        let section = formData[indexPath.section]
        let personalData = section.sectionValue[indexPath.row]
        cell.delegate = self
        cell.cellType = section.cellType
        cell.formModelData = section.sectionValue
        cell.formData = personalData
        cell.updateUI(personalData)
    }
    func updateFooterCell(_ cell: FooterCell) {
        cell.backgroundColor = .clear
        cell.updateButton.setTitle(Text.redeemButtonTitleText.localized().capitalized, for: .normal)
        if cell.hasNoError {
            cell.updateButton.isUserInteractionEnabled = true
            cell.updateButton.layer.opacity = 1.0
        } else {
            cell.updateButton.isUserInteractionEnabled = false
            cell.updateButton.layer.opacity = 0.5
        }
    }
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.tintColor = .red
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return WalletList.topForFirstHeaderSec
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < formData.count {
            return UITableView.automaticDimension
        }
        return SettingList.heightForRow
    }
}
extension PayPalDataSource: FooterCellDelegate {
    func clickToPerformAction() {
        delegate?.clickToPeformAction(formData)
    }
}

extension PayPalDataSource: FormAcceptanceDelegate {
    func clickToOpenTerms() {
        delegate?.clickToOpenTerms()
    }
    
    func clickoOpenPrivacy() {
        debugPrint("No Action needed")
    }
    
    func acceptedTermsCondition(_ isSelected: Bool) {
        _ = formData.compactMap({$0.isTermsConditionAccepted = isSelected})
        NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton,
                                        object: nil)
        if validateFieldsForPayPalAccount() {
            NotificationCenter.default.post(name: NSNotification.Name.updateButton,
                                            object: nil)
        }
    }
    func payPalAmountSelected(_ isSelected: Bool) {
        _ = formData.compactMap({$0.isPayPalAmountSelected = isSelected})
        NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton,
                                        object: nil)
        if validateFieldsForPayPalAccount() {
            NotificationCenter.default.post(name: NSNotification.Name.updateButton,
                                            object: nil)
        }
    }
}
extension PayPalDataSource {
    func reloadDoubleCell(_ textField: UITextField,
                          _ formModel: [FormModel],
                          _ cell: PayPalInputCell) {
        DispatchQueue.main.async {
            self.tableView?.beginUpdates()
            cell.updateDoubleFormError(textField, formModel)
            self.tableView?.endUpdates()
        }
    }
}
extension PayPalDataSource: PayPalInputCellDelegate {
    
    func getDoublePlaceholderTextField(fieldType: TextFieldType, _ textField: UITextField, _ cell: PayPalInputCell, _ section: Int) {
        let model = formData.filter({$0.section == section})[0].sectionValue
        if textField.tag == tagOne {
            _ = model.map({$0.fieldValue = textField.text ?? ""})
            _ = model.map({$0.shouldShowError = false})
        }
        if textField.tag == tagTwo {
            _ = model.map({$0.fieldValue1 = textField.text ?? ""})
            _ = model.map({$0.shouldShowError1 = false})
        }
        handleButtonEnableDisable(model)
        reloadDoubleCell(textField, model, cell)
        NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
        if validateFieldsForPayPalAccount() {
            
            NotificationCenter.default.post(name: NSNotification.Name.updateButton, object: nil)
        }
    }
    func handleButtonEnableDisable(_ formModel: [FormModel]) {
        NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
        if validateFieldsForPayPalAccount() {
            NotificationCenter.default.post(name: NSNotification.Name.updateButton, object: nil)
        }
    }
    
    
    func startedDoubleTyping(fieldType: TextFieldType,
                             _ textField: UITextField,
                             _ section: Int,
                             _ cell: PayPalInputCell) {
        let model = formData.filter({$0.section == section})[0].sectionValue
        if textField.tag == tagOne {
            _ = model.map({$0.fieldValue = textField.text ?? ""})
            _ = model.map({$0.shouldShowError = false})
        }
        if textField.tag == tagTwo {
            _ = model.map({$0.fieldValue1 = textField.text ?? ""})
            _ = model.map({$0.shouldShowError1 = false})
        }
        reloadDoubleCell(textField, model, cell)
        NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
        if validateFieldsForPayPalAccount() {
            NotificationCenter.default.post(name: NSNotification.Name.updateButton, object: nil)
        }
    }
    
    func changedDoubleText(fieldType: TextFieldType, _ textField: UITextField,
                           _ cell: PayPalInputCell, _ section: Int) { }
    func validateFieldsForPayPalAccount() -> Bool {
        if validateFields() {
            let isTermAccepted = formData.compactMap({$0.isTermsConditionAccepted == true})[0]
            let isAmounntSelected = formData.compactMap({$0.isPayPalAmountSelected == true})[0]
            if isTermAccepted && isAmounntSelected{
                return true
            }
        }
        return false
    }
    func validateFields() -> Bool {
        let section = formData.flatMap({$0.sectionValue.filter({$0.section == 0})})
        let email = section.map({$0.fieldValue})[0]
        let confEmail = section.map({$0.fieldValue1})[0]
        if (!email.isEmpty )
            && (!confEmail.isEmpty ) {
            return true
        }
        return false
    }
}
