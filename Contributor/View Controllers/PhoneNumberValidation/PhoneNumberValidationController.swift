//
//  PhoneNumberValidationController.swift
//  Contributor
//
//  Created by KiwiTech on 2/25/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

enum PlaceHolderText: String {
   case unitedKingdom = "E.g. 163 296 0073"
   case unitedStates = "E.g. 202 555 0195"
   case australia = "E.g. 190 065 4321"
}

class PhoneNumberValidationController: UIViewController {

@IBOutlet weak var phoneNumberTextField: UITextField!
@IBOutlet weak var countryCodeButton: UIButton!
@IBOutlet weak var countryPickerView: UIPickerView!
@IBOutlet weak var pickerStackView: UIStackView!
@IBOutlet weak var otpSendButton: UIButton!
@IBOutlet weak var countryLineView: UIView!
@IBOutlet weak var phoneNumberLineView: UIView!
@IBOutlet weak var phoneNumberErrorLabel: UILabel!
@IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    @IBOutlet weak var validateYourPhoneLabel: UILabel!
    @IBOutlet weak var enterPhoneLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!


public let primaryColor = Constants.primaryColor
private lazy var countryDataSource = CountryPickerViewDataSource()
public var phoneValidationModel = CountryData()
public lazy var viewModel = PhoneValidationViewModel()
public let textFieldDefaultColor = Constants.textFieldDefaultColor
private let userDefaultKey = "pickerViewRow"

override func viewDidLoad() {
    super.viewDidLoad()
   setUpUI()
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.phoneValidationScreen)
}

func setUpUI() {
    UserDefaults.standard.removeObject(forKey: userDefaultKey)
    setupNavbar()
    loaderIndicator.updateIndicatorView(self, hidden: true)
    phoneNumberErrorLabel.isHidden = true
    otpSendButton.setDarkeningBackgroundColor(color: primaryColor)
    otpSendButton.setTitleColor(Color.whiteText.value, for: .normal)
    countryLineView.backgroundColor = primaryColor
    phoneNumberTextField.placeholder = PlaceHolderText.unitedStates.rawValue
    phoneNumberTextField.tintColor = primaryColor
    initiaLogic()
    applyCommunityTheme()
}

func setupNavbar() {
     if let _ = self.presentingViewController {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: Text.close.localized(),
                                                           style: UIBarButtonItem.Style.plain,
                                                           target: self, action: #selector(close))
       navigationItem.leftBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 17), for: .normal)
     }
}
   
@objc func close() {
    dismissSelf()
}

func initiaLogic() {
    countryDataSource.getCountryDetail()
    countryPickerView.delegate = countryDataSource
    countryPickerView.dataSource = countryDataSource
    countryDataSource.pickerDelegate = self
    let selectedCountry = countryDataSource.countryCodeArray[0]
    let selectedCountryCode = "\(selectedCountry.country) (\(selectedCountry.countryCode))"
    countryCodeButton.setTitle(selectedCountryCode, for: .normal)
    phoneValidationModel.countryCode = selectedCountry.countryCode
    otpSendButton.setEnabled(false)
    countryPickerView.reloadAllComponents()
}

@IBAction func clickToOpenCountryPicker(_ sender: Any) {
    phoneNumberTextField.resignFirstResponder()
    pickerStackView.isHidden = false
    let defaults = UserDefaults.standard
    if defaults.integer(forKey: userDefaultKey) != nil {
        countryPickerView.selectRow(defaults.integer(forKey: userDefaultKey),
                                    inComponent: 0, animated: true)
    } else {
        countryPickerView.selectRow(0, inComponent: 0, animated: true)
    }
}

@IBAction func clickToGetOtp(_ sender: Any) {
    phoneNumberTextField.resignFirstResponder()
    if let phoneNumber = phoneNumberTextField.text {
        let number = "\(phoneValidationModel.countryCode)\(phoneNumber)"
        let isValidNumber = Helper.isNumberValidWithSelectedCountryCode(number)
        if isValidNumber {
            phoneValidationModel.phoneNumber = phoneNumber
            phoneNumberLineView.backgroundColor = textFieldDefaultColor
            phoneNumberErrorLabel.text = ""
        } else {
            updatePhoneTextFieldError()
            return
        }
    }
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    loaderIndicator.updateIndicatorView(self, hidden: false)
    let param = "\(phoneValidationModel.countryCode)\(phoneValidationModel.phoneNumber ?? "")"
    viewModel.sendOtpOnPhoneNumber(phoneNumber: param) { [weak self] (isSuccess) in
        guard let this = self else { return }
        this.loaderIndicator.updateIndicatorView(this, hidden: true)
        if isSuccess {
            //Move to next screen
            Router.shared.route(to: Route.otpValidation(phoneNumber: param, delegate: this),
                                from: this,
                                presentationType: .push())
        } else {
            let toaster = Toaster(view: this.view)
            toaster.toast(message: PhoneValidationText.usedNumber.localized())
        }
    }
}

func updatePhoneTextFieldError() {
    phoneNumberErrorLabel.isHidden = false
    phoneNumberLineView.backgroundColor = .red
    phoneNumberErrorLabel.text = PhoneValidationText.invalidNumber.localized()
    phoneNumberTextField.resignFirstResponder()
}

@IBAction func cancel(_ sender: Any) {
    pickerStackView.isHidden = true
}

@IBAction func done(_ sender: Any) {
    pickerStackView.isHidden = true
    let row = self.countryPickerView.selectedRow(inComponent: 0)
    self.countryPickerView.selectRow(row, inComponent: 0, animated: false)
    phoneValidationModel = countryDataSource.countryCodeArray[row]
    let defaults = UserDefaults.standard
    defaults.set(row, forKey: userDefaultKey)
    let selectedCountry = "\(phoneValidationModel.country) (\(phoneValidationModel.countryCode))"
    countryCodeButton.setTitle(selectedCountry, for: .normal)
}

@IBAction func clickToGoBack(_ sender: Any) {
  self.view.endEditing(true)
  self.dismiss(animated: true, completion: nil)
}
}

extension PhoneNumberValidationController: PickerDatasourceDelegate, OtpValidationDelegate {
    func dismissController() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    func getSelectedCountryCode(_ countryData: CountryData) {
        if countryData.country == "United States" ||
            countryData.country == "Canada" {
            phoneNumberTextField.placeholder = PlaceHolderText.unitedStates.rawValue
        }
        if countryData.country == "United Kingdom" {
            phoneNumberTextField.placeholder = PlaceHolderText.unitedKingdom.rawValue
        }
        if countryData.country == "Australia" {
            phoneNumberTextField.placeholder = PlaceHolderText.australia.rawValue
        }
        if countryData.country == "Brazil" {
            phoneNumberTextField.placeholder = PlaceHolderText.australia.rawValue
        }
    }
}

extension PhoneNumberValidationController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    otpSendButton.setTitle(Constants.sendCode.localized(), for: .normal)
    otpSendButton.setDarkeningBackgroundColor(color: colors.primary)
    countryLineView.backgroundColor = colors.primary
    phoneNumberTextField.tintColor = colors.primary
    validateYourPhoneLabel.text = Text.phoneNumberValidationText.localized()
    enterPhoneLabel.text = Text.enterPhoneInfo.localized()
    countryLabel.text = Text.countryText.localized()
    phoneNumberLabel.text = Text.phoneNumberText.localized()
  }
}
