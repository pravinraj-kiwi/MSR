//
//  LinkedinCell+UI.swift
//  Contributor
//
//  Created by KiwiTech on 9/25/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension LinkedinCollectionViewCell {
@objc func closeAd() {
  adNoButton.bounceBriefly()
  linkedinViewDelegate?.clickToCloseAdView(appType: appType)
}

@objc func clickToConnectApp() {
  adYesButton.bounceBriefly()
  linkedinViewDelegate?.clickToOpenConnectionScreen(appType: appType)
}

func showImage() {
  let contentWidth = contentView.frame.width - Layout.contentInset.left - Layout.contentInset.right
  let imageHeight = imageView.image?.calculateHeight(for: contentWidth) ?? 0
  
  imageView.snp.remakeConstraints { (make) in
    make.width.equalTo(contentWidth)
    make.height.equalTo(imageHeight)
  }
  imageView.isHidden = false
}

func hideImage() {
  imageView.isHidden = true
}

func configure(with message: MessageHolder, adData: ConnectedAppData?) {
  if let title = message.title {
      titleLabel.attributedText = title.lineSpacedAndCentered(Layout.lineSpacing)
      titleLabel.isHidden = false
  } else {
      titleLabel.isHidden = true
  }
  if let detail = message.detail {
      dashLabel.attributedText = detail.lineSpacedAndCentered(Layout.lineSpacing)
      dashLabel.isHidden = false
      dashView.isHidden = false
  } else {
      dashLabel.isHidden = true
      dashView.isHidden = true
  }
  if let image = message.image {
      imageView.image = image.value
      showImage()
  } else {
      imageView.image = nil
      hideImage()
  }
  updateLinkedinUI(adData)
}
  
@objc func updateLinkedinData(notification: NSNotification) {
   let object = notification.object as? ConnectedAppData
   updateLinkedinUI(object)
}

func updateLinkedinUI(_ adData: ConnectedAppData?) {
   if let data = adData?.displayAd, data == true {
      updateAdHeightConstraints(Layout.linkedinViewHeight, shouldHide: false)
   } else {
      updateAdHeightConstraints(0, shouldHide: true)
  }
  switch adData?.type {
  case ConnectedApp.linkedin.rawValue:
      adImageView.image = Image.linkedin.value
      adLabel.text = ConnectedAppCellText.connectedLinkedinText.localized()
      appType = .linkedin
  case ConnectedApp.facebook.rawValue:
      adImageView.image = Image.facebook.value
      adLabel.text = ConnectedAppCellText.connectedFacebookText.localized()
      appType = .facebook
  case ConnectedApp.dynata.rawValue:
      adImageView.image = Image.dynata.value
      appType = .dynata
  case ConnectedApp.pollfish.rawValue:
      adImageView.image = Image.pollfish.value
      appType = .pollfish
  case ConnectedApp.kantar.rawValue:
      adImageView.image = Image.kantar.value
      appType = .kantar
  default:
      break
  }
}

func updateAdHeightConstraints(_ height: CGFloat, shouldHide: Bool) {
  adView.isHidden = shouldHide
  adView.snp.updateConstraints({ (update) in
      update.height.equalTo(height)
  })
}
}
