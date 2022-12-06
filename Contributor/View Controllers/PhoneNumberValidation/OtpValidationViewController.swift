//
//  OtpValidationViewController.swift
//  Contributor
//
//  Created by KiwiTech on 2/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol OtpValidationDelegate: class {
  func dismissController()
}

class OtpValidationViewController: UIViewController {
  
  @IBOutlet weak var verifyCodeButton: UIButton!
  @IBOutlet weak var resendOtpButton: UIButton!
  @IBOutlet weak var contactSupportButton: UIButton!
  @IBOutlet weak var phoneNumberLabel: UILabel!
  @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
  @IBOutlet weak var otpView: OTPInputView?
    @IBOutlet weak var enterCodeLabel: UILabel!
    @IBOutlet weak var didntSendLabel: UILabel!
    @IBOutlet weak var havingTroubleLabel: UILabel!

  public let primaryColor = Constants.primaryColor
  public var phoneNumber: String = ""
  public var enteredOtp: String = ""
  public lazy var viewModel = PhoneValidationViewModel()
  public let textFieldDefaultColor = Constants.textFieldDefaultColor
  public weak var otpValidationDelegate: OtpValidationDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    if #available(iOS 13.0, *) {
      isModalInPresentation = true
    }
    setUpUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // fire up the keyboard (almost) immediately
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      if let firstTextField = self.otpView?.viewWithTag(1) as? UITextField {
      firstTextField.becomeFirstResponder()
      }
    }
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.verifyOtpScreen)
  }
  
  func setUpUI() {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    verifyCodeButton.setDarkeningBackgroundColor(color: primaryColor)
    verifyCodeButton.setTitleColor(Color.whiteText.value, for: .normal)
    loaderIndicator.updateIndicatorView(self, hidden: true)
    updatedPhoneNumberLabel()
    updateUI()
    verifyCodeButton.setEnabled(false)
    otpView?.delegateOTP = self
    addTapGestureOnLabel()
  }

  func updateUI() {
    let resendText = Helper.updateAttributtedText(Constants.resendCode.localized())
    let contactSupportText = Helper.updateAttributtedText(Constants.contactSupport.localized())
    resendOtpButton.setAttributedTitle(resendText, for: .normal)
    contactSupportButton.setAttributedTitle(contactSupportText, for: .normal)
    applyCommunityTheme()
  }

  @IBAction func clickToOpenContactSupport(_ sender: Any) {
    Router.shared.route(to: .support(), from: self,
                                       presentationType: .modal(presentationStyle: .pageSheet,
                                                                transitionStyle: .coverVertical))
  }
  
  @IBAction func clickToVerifyOTP(_ sender: Any) {
    if enteredOtp != "" {
      if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
      }
      loaderIndicator.updateIndicatorView(self, hidden: false)
      viewModel.verifySendOtp(phoneNumber: phoneNumber, otp: enteredOtp) { [weak self] (userObject, isSuccess) in
        guard let this = self else { return }
        this.loaderIndicator.updateIndicatorView(this, hidden: true)
        if isSuccess {
          if let validationError = userObject?.phoneValidationError {
            this.resetOTPFields()
            let toaster = Toaster(view: this.view)
            toaster.toast(message: validationError)
            return
          }
          Router.shared.route(
            to: Route.confirmation,
            from: this,
            presentationType: .push())
        } else {
           let toaster = Toaster(view: this.view)
            toaster.toast(message: OtpValidationText.invalidErrorMessage.localized())
        }
      }
    }
  }
  
  func resetOTPFields() {
    otpView?.removeAllOTP()
    verifyCodeButton.setEnabled(false)
  }
  
  @IBAction func clickToResendOTP(_ sender: Any) {
    if ConnectivityUtils.isConnectedToNetwork() == false {
      Helper.showNoNetworkAlert(controller: self)
      return
    }
    resetOTPFields()
    loaderIndicator.updateIndicatorView(self, hidden: false)
    viewModel.sendOtpOnPhoneNumber(phoneNumber: phoneNumber) { [weak self] (isSuccess) in
      guard let this = self else { return }
      this.loaderIndicator.updateIndicatorView(this, hidden: true)
      if isSuccess {
        let toaster = Toaster(view: this.view)
        toaster.toast(message: OtpValidationText.validationCodeSend.localized())
      } else {
        let toaster = Toaster(view: this.view)
        toaster.toast(message: OtpValidationText.otpNotSendMessage.localized())
      }
    }
  }
  
  func clickToEditNumber() {
    self.view.endEditing(true)
    self.navigationController?.popViewController(animated: true)
  }
}

extension OtpValidationViewController: OTPViewDelegate {
  
  func didFinishEnteringOTP(otpNumber: String) {
    enteredOtp = otpNumber
    verifyCodeButton.setEnabled(true)
  }
  
  func otpNotValid() {
    verifyCodeButton.setEnabled(false)
  }
}
extension OtpValidationViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    verifyCodeButton.setDarkeningBackgroundColor(color: colors.primary)
    enterCodeLabel.text = Text.enterCode.localized()
    didntSendLabel.text = Text.didntSendCode.localized()
    verifyCodeButton.setTitle(Text.validate.localized(), for: .normal)
    havingTroubleLabel.text = Text.havingTrouble.localized()
  }
}
