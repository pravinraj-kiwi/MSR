//
//  customPopUp.swift
//  Contributor
//
//  Created by Kiwitech on 22/04/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension JoinCommunityViewController {

func updateUIWithText() {
    headerLabel.text = CustomPopUpText.title.localized()
  titleLabel.text = CustomPopUpText.message.localized()
  detailLabel.text = CustomPopUpText.detail.localized()
  bulletLabel.attributedText = Utilities.makeBulletList(from: CustomPopUpText.bulletListArray)
  actionButton.setTitle(CustomPopUpText.deleteTitle.localized(), for: .normal)
  cancelButton.setTitle(CustomPopUpText.cancelTitle.localized(), for: .normal)
  actionButton.titleLabel?.font = Layout.headerFont
  actionButton.setTitleColor(.red, for: .normal)
  cancelButton.setTitleColor(.black, for: .normal)
  formStackView.spacing = 15
  actionButton.titleLabel?.textAlignment = .right
  actionButton.backgroundColor = .clear
}

func setUpCustomPopUpView() {
  view.addSubview(container)
  container.snp.makeConstraints { make in
    make.centerX.equalTo(view)
    make.centerY.equalTo(view)
    make.width.equalToSuperview().inset(Layout.containerInset)
    make.height.equalTo(260)
  }
    
  container.addSubview(formContainer)
  formContainer.snp.makeConstraints { make in
      make.edges.equalToSuperview()
  }
  formContainer.addSubview(formStackView)
    
  formStackView.snp.makeConstraints { make in
    make.top.left.right.equalToSuperview().inset(Layout.contentInset)
  }
    
  formStackView.addArrangedSubview(headerLabel)
  formStackView.addArrangedSubview(titleLabel)
  formStackView.addArrangedSubview(detailLabel)
  formStackView.addArrangedSubview(bulletLabel)
  formStackView.addSubview(loadingActivityIndicator)
  loadingActivityIndicator.bringSubviewToFront(formStackView)

  loadingActivityIndicator.snp.makeConstraints { make in
     make.centerX.equalTo(formStackView)
     make.centerY.equalTo(formStackView)
  }
  formContainer.addSubview(actionButton)
  actionButton.snp.makeConstraints { make in
    make.bottom.equalTo(formContainer).offset(-Layout.actionButtonBottomMargin)
    make.height.equalTo(Layout.actionButtonHeight)
    make.trailing.equalToSuperview().offset(-20)
  }
  actionButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)

  formContainer.addSubview(cancelButton)
  cancelButton.snp.makeConstraints { make in
    make.bottom.equalTo(formContainer).offset(-Layout.actionButtonBottomMargin)
    make.height.equalTo(Layout.actionButtonHeight)
    make.width.equalTo(Layout.actionButtonWidth)
    make.trailing.equalTo(actionButton.snp.leading).offset(Layout.actionButtonBottomMargin)
   }
   cancelButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
   loadingActivityIndicator.backgroundColor = .white
   loadingActivityIndicator.updateIndicatorView(self, hidden: true)
}

@objc func confirmAction() {
  if ConnectivityUtils.isConnectedToNetwork() == false {
     Helper.showNoNetworkAlert(controller: self)
     return
  }
  loadingActivityIndicator.updateIndicatorView(self, hidden: false)
  NetworkManager.shared.uploadProfileData(profileData: "{}", tag: TagObject.TAG_ALL.rawValue) { (_, error) in
     if error == nil {
        NetworkManager.shared.deletAccount { [weak self] (_) in
          guard let this = self else { return }
          this.loadingActivityIndicator.updateIndicatorView(this, hidden: true)
          this.dismissSelf()
          this.popupDelegate?.dismissSettingScreen()
         }
      }
    }
  }
}
