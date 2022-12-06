//
//  PayPalInputCell.swift
//  Contributor
//
//  Created by Shashi Kumar on 09/03/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit
protocol PayPalInputCellDelegate: class {
    func getDoublePlaceholderTextField(fieldType: TextFieldType,
                                       _ textField: UITextField,
                                       _ cell: PayPalInputCell,
                                       _ section: Int)
    func startedDoubleTyping(fieldType: TextFieldType,
                             _ textField: UITextField,
                             _ section: Int,
                             _ cell: PayPalInputCell)
    func changedDoubleText(fieldType: TextFieldType,
                           _ textField: UITextField,
                           _ cell: PayPalInputCell,
                           _ section: Int)
}
class PayPalInputCell: UITableViewCell {
    @IBOutlet weak var placeHolderText: UILabel!
    @IBOutlet weak var formTextField: UITextField!
    @IBOutlet weak var placeHolder1: UILabel!
    @IBOutlet weak var formTextField1: UITextField!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var borderView1: UIView!
    @IBOutlet weak var hintText: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    weak var delegate: PayPalInputCellDelegate?
    var formData: FormModel?
    var formModelData: [FormModel]?
    var cellType: CellType? = .singleCell
    var activeBorderColor: UIColor = Constants.primaryColor
    let defaultColor = Utilities.getRgbColor(229, 229, 229)
    let errorColor = Utilities.getRgbColor(255, 59, 48)
    let tagOne = TextFieldTag.one.rawValue
    let tagTwo = TextFieldTag.two.rawValue

    override func awakeFromNib() {
        super.awakeFromNib()
        formTextField.delegate = self
        formTextField1.delegate = self
        applyCommunityTheme()
        borderView.layer.cornerRadius = 8
        borderView.layer.borderWidth = 2.0
        borderView.layer.borderColor = defaultColor.cgColor
        borderView1.layer.cornerRadius = 8
        borderView1.layer.borderWidth = 2.0
        borderView1.layer.borderColor = defaultColor.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUI(_ personalData: FormModel) {
        errorLabel.isHidden = true
        formTextField.placeholder = personalData.placeholderValue
        placeHolderText.isHidden = false
        placeHolderText.text = personalData.placeholderKey
        formTextField.keyboardType = .emailAddress
        
        formTextField1.placeholder = personalData.placeholderValue1
        placeHolder1.isHidden = false
        placeHolder1.text = personalData.placeholderKey1
        formTextField1.keyboardType = .emailAddress
        
        borderView.layer.borderWidth = 2.0
        borderView1.layer.borderWidth = 2.0
        if personalData.shouldShowError == true {
            borderView.layer.borderColor = errorColor.cgColor
            borderView1.layer.borderColor = errorColor.cgColor
        } else {
            borderView.layer.borderColor = defaultColor.cgColor
            borderView1.layer.borderColor = defaultColor.cgColor
        }
        if personalData.emailsNotMatched {
          errorLabel.isHidden = false
          errorLabel.text = Utilities.getErrorAccToType(.misMatchEmails)
            borderView.layer.borderColor = errorColor.cgColor
            borderView1.layer.borderColor = errorColor.cgColor
         }
        formTextField.text = personalData.fieldValue
        formTextField1.text = personalData.fieldValue1
        if !handleAllFieldError([personalData]) {
            handleOtherTagError([personalData])
       }
    }
    func updateDoubleFormError(_ textField: UITextField, _ formModel: [FormModel]) {
        errorLabel.isHidden = true
      _ = formModel.map({$0.wrongCurrentPassword = false})
      if textField.tag == tagOne {
        if !handleAllFieldError(formModel) {
            handleOtherTagError(formModel)
       }
      }
        
      if textField.tag == tagTwo {
        if !handleAllFieldError(formModel) {
            handleOtherTagError(formModel)
       }
      }
        
    }
}
extension PayPalInputCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
      switch textField.tag {
      case tagOne:
        guard let cellType = formData?.textFieldType else { return }
        stopEditingFields(textField, dividerView: borderView, cellType)
      case tagTwo:
        guard let cellType = formData?.textFieldType1 else { return }
        stopEditingFields(textField, dividerView: borderView1, cellType)
      default: break
        }
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField == formTextField {
        textField.resignFirstResponder()
        formTextField1.becomeFirstResponder()
      } else if textField == formTextField1 {
        textField.resignFirstResponder()
      }
      return true
      }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let text = textField.text as NSString?
        var newText: String? = text?.replacingCharacters(in: range, with: string)
        if let txtStr = newText, txtStr.isEmpty {
          newText = nil
        }
        let whitespaceSet = NSCharacterSet.whitespaces
        if let _ = string.rangeOfCharacter(from: whitespaceSet) {
          return false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        switch textField.tag {
        case self.tagOne:
          guard let cellType = self.formData?.textFieldType else { return }
            self.updateChangeInFields(textField, dividerView: self.borderView, cellType)
        case self.tagTwo:
          guard let cellType = self.formData?.textFieldType1 else { return }
            self.updateChangeInFields(textField, dividerView: self.borderView1, cellType)
        default: break
          }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case tagOne:
            guard let cellType = formData?.textFieldType else { return }
            startEditingFields(textField, dividerView: borderView, cellType)
        case tagTwo:
            guard let cellType = formData?.textFieldType1 else { return }
            startEditingFields(textField, dividerView: borderView1, cellType)
        default: break
        }
    }
    func startEditingFields(_ textField: UITextField, dividerView: UIView,
                            _ cellType: TextFieldType) {
        dividerView.layer.borderColor = activeBorderColor.cgColor
        guard let multiCellSection = formData?.section else { return }
        delegate?.startedDoubleTyping(fieldType: cellType,
                                            textField,
                                            multiCellSection, self)
    }
    func updateChangeInFields(_ textField: UITextField, dividerView: UIView,
                              _ cellType: TextFieldType) {
        dividerView.layer.borderColor = activeBorderColor.cgColor
      guard let multiCellSection = formData?.section else { return }
      delegate?.changedDoubleText(fieldType: cellType,
                                        textField,
                                        self,
                                        multiCellSection)
    }
    func stopEditingFields(_ textField: UITextField, dividerView: UIView,
                           _ cellType: TextFieldType) {
        dividerView.layer.borderColor = defaultColor.cgColor
      guard let multiCellSection = formData?.section else { return }
      delegate?.getDoublePlaceholderTextField(fieldType: cellType,
                                                    textField,
                                                    self,
                                                    multiCellSection)
    }

}
extension PayPalInputCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity,
          let colors = community.colors else {
        activeBorderColor = Color.primary.value
        formTextField.tintColor = Color.primary.value
        formTextField1.tintColor = Color.primary.value
        return
    }
    activeBorderColor = colors.primary
    formTextField.tintColor = colors.primary
    formTextField1.tintColor = colors.primary
  }
}
extension PayPalInputCell {
    func handleAllFieldError(_ formModel: [FormModel]) -> Bool {
        if !formModel.filter({$0.shouldShowError == true
                                && $0.shouldShowError1 == true}).isEmpty {
            errorLabel.isHidden = false
            let type = formModel.compactMap({$0.textFieldType})[0]
            let email = formModel.compactMap({$0.fieldValue})[0]
            let confEmail = formModel.compactMap({$0.fieldValue1})[0]
            if (email.isEmpty && confEmail.isEmpty) {
                errorLabel.text = Utilities.getErrorAccToType(.currentNewConfirmPassword)
            } else {
                errorLabel.text = Utilities.getErrorAccToType(.email)
            }
            borderView.layer.borderColor = errorColor.cgColor
            borderView1.layer.borderColor = errorColor.cgColor
            return true
        }
        return false
    }
    
    func handleOtherTagError(_ formModel: [FormModel]) {
        if !formModel.filter({$0.shouldShowError == true}).isEmpty {
            let type1 = formModel.compactMap({$0.textFieldType})[0]
            let value1 = formModel.compactMap({$0.fieldValue})[0]
            updateErrorUI(type1, value1, dividerView: borderView)
        } else if !formModel.filter({$0.shouldShowError1 == true}).isEmpty {
            let type2 = formModel.compactMap({$0.textFieldType1})[0]
            let value2 = formModel.compactMap({$0.fieldValue1})[0]
            updateErrorUI(type2, value2, dividerView: borderView1)
        }
    }
    func updateErrorUI(_ type: TextFieldType, _ value: String, dividerView: UIView) {
      errorLabel.isHidden = false
        errorLabel.text = Utilities.getErrorAccToType(type, value)
        dividerView.layer.borderColor = errorColor.cgColor
    }
}
