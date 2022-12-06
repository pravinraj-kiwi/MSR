//
//  ConnectedAppsCollectionCell.swift
//  Contributor
//
//  Created by KiwiTech on 3/6/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol ConnectedAppsDelegate: class {
 func clickToOpenProfileValidations(dataType: ConnectedDataType)
 func clickToOpenPatnersScreen(dataType: ConnectedDataType)
}

struct Layout {
 static var contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
 static var labelInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
 static var subTitleTextColor = UIColor.init(red: 132.0/255.0, green: 132.0/255.0, blue: 132.0/255.0, alpha: 1.0)
 static let titleFont = Font.regular.of(size: 16)
 static let subTitleFont = Font.regular.of(size: 13)
 static let buttonFont = Font.semiBold.of(size: 12)
 static let headerFont = Font.bold.of(size: 22)
 static var validationButtonHeight: CGFloat = 30
 static var validationButtonWidth: CGFloat = 84
 static var validationButtonCornerRadius: CGFloat = validationButtonHeight / 2
 static let titleLabelBottomMargin: CGFloat = 5
 static var lineSpacing = Constants.defaultLineSpacing
 static var defaultStackSpacing: CGFloat = 2
 static let borderHeight: CGFloat = 1
 static let borderBottomMargin: CGFloat = 14
 static let linkedinImageHeight: CGFloat = 40
 static let linkedinImageWidth: CGFloat = 40
 static let linkedinImageTrailing: CGFloat = 0
 static let linkedinButtonsWidth: CGFloat = 95
 static let linkedinButtonsHeight: CGFloat = 40
}

class ConnectedAppsCollectionCell: UICollectionViewCell {

weak var connectedViewDelegate: ConnectedAppsDelegate?

let border1: UIView = {
 let view = UIView()
 view.backgroundColor = Color.lightBorder.value
 return view
}()

let headerLabel: UILabel = {
 let label = UILabel()
 label.font = Layout.headerFont
    label.text = ConnectedAppCellText.connectedDataHeaderText.localized()
 label.textColor = .black
 label.numberOfLines = 0
 return label
}()

let connectedAppLabel: UILabel = {
 let label = UILabel()
 label.font = Layout.titleFont
 label.text = ConnectedAppCellText.connectedDataLabelText.localized()
 label.textColor = .black
 label.numberOfLines = 0
 return label
}()

let baseStackView: UIStackView = {
 let stack = UIStackView(frame: CGRect.zero)
 stack.axis = .vertical
 stack.distribution = .fill
 stack.spacing = 10
 return stack
}()

let profileValidationView: UIView = {
 let view = UIView()
 return view
}()
    
let profileValidationImageView: UIImageView = {
 let validImage = UIImageView()
 validImage.contentMode = .scaleAspectFit
 validImage.image = Image.profileValidation.value
 validImage.clipsToBounds = true
 return validImage
}()
 
let profileValidationLabel: UILabel = {
 let label = UILabel()
 label.font = Layout.titleFont
 label.text = ConnectedAppCellText.connectedDataProfileText.localized()
 label.textColor = .black
 label.numberOfLines = 0
 return label
}()

let profileValidationArrowImage: UIImageView = {
 let arrowImage = UIImageView()
 arrowImage.contentMode = .scaleAspectFit
 arrowImage.image = Image.arrow.value
 arrowImage.clipsToBounds = true
 return arrowImage
}()

let profileValidationTickImage: UIImageView = {
 let tickImage = UIImageView()
 tickImage.contentMode = .scaleAspectFit
 tickImage.image = Image.checkmark.value
 tickImage.clipsToBounds = true
 return tickImage
}()
  
let profileValidationButton: UIButton = {
 let button = UIButton()
 return button
}()

let border2: UIView = {
 let view = UIView()
 view.backgroundColor = Color.lightBorder.value
 return view
}()

let surveyPartnerView: UIView = {
 let view = UIView()
 return view
}()
    
let surveyPartnerImageView: UIImageView = {
 let partnerImage = UIImageView()
 partnerImage.contentMode = .scaleAspectFit
 partnerImage.image = Image.surveyPartner.value
 partnerImage.clipsToBounds = true
 return partnerImage
}()
 
let surveyPartnerLabel: UILabel = {
 let label = UILabel()
 label.font = Layout.titleFont
 label.text = ConnectedAppCellText.connectedDataPartnerText.localized()
 label.textColor = .black
 label.numberOfLines = 0
 return label
}()

let surveyPartnerArrowImage: UIImageView = {
 let partnerArrowImage = UIImageView()
 partnerArrowImage.contentMode = .scaleAspectFit
 partnerArrowImage.image = Image.arrow.value
 partnerArrowImage.clipsToBounds = true
 return partnerArrowImage
}()

let surveyPartnerTickImage: UIImageView = {
 let partnerTickImage = UIImageView()
 partnerTickImage.contentMode = .scaleAspectFit
 partnerTickImage.image = Image.checkmark.value
 partnerTickImage.clipsToBounds = true
 return partnerTickImage
}()
  
let surveyPartnerButton: UIButton = {
 let button = UIButton()
 return button
}()

override init(frame: CGRect) {
 super.init(frame: frame)
 setupViews()
}

required init?(coder aDecoder: NSCoder) {
 super.init(coder: aDecoder)
 setupViews()
}
    
func surveyPartnerConstraint(_ contentWidth: CGFloat) {
    surveyPartnerView.snp.makeConstraints { (make) in
       make.width.equalTo(contentWidth)
       make.height.equalTo(44)
    }

    surveyPartnerView.addSubview(surveyPartnerImageView)
    surveyPartnerImageView.snp.makeConstraints { (make) in
       make.leading.equalTo(Layout.linkedinImageTrailing)
       make.width.equalTo(25)
       make.height.equalTo(25)
       make.centerY.equalTo(surveyPartnerView)
    }

    surveyPartnerView.addSubview(surveyPartnerLabel)
    surveyPartnerLabel.snp.makeConstraints { (make) in
       make.centerY.equalToSuperview()
       make.leading.equalTo(surveyPartnerImageView.snp.trailing).offset(15)
    }
       
    surveyPartnerView.addSubview(surveyPartnerArrowImage)
    surveyPartnerArrowImage.snp.makeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.trailing.equalTo(surveyPartnerView)
      make.width.equalTo(8)
      make.height.equalTo(13)
    }

    surveyPartnerView.addSubview(surveyPartnerTickImage)
    surveyPartnerTickImage.snp.makeConstraints { (make) in
       make.centerY.equalToSuperview()
       make.trailing.equalTo(surveyPartnerArrowImage.snp.leading).offset(-15)
       make.width.equalTo(13)
       make.height.equalTo(10)
    }

    surveyPartnerView.addSubview(surveyPartnerButton)
    surveyPartnerButton.snp.makeConstraints { (make) in
       make.width.equalTo(contentWidth)
       make.height.equalTo(44)
    }
}
    
func profileValidationConstraint(_ contentWidth: CGFloat) {
    profileValidationView.snp.makeConstraints { (make) in
       make.width.equalTo(contentWidth)
       make.height.equalTo(44)
    }

    profileValidationView.addSubview(profileValidationImageView)
    profileValidationImageView.snp.makeConstraints { (make) in
       make.leading.equalTo(Layout.linkedinImageTrailing)
       make.width.equalTo(25)
       make.height.equalTo(28)
       make.centerY.equalTo(profileValidationView)
    }

    profileValidationView.addSubview(profileValidationLabel)
    profileValidationLabel.snp.makeConstraints { (make) in
        make.centerY.equalToSuperview()
        make.leading.equalTo(profileValidationImageView.snp.trailing).offset(15)
    }

    profileValidationView.addSubview(profileValidationArrowImage)
    profileValidationArrowImage.snp.makeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.trailing.equalTo(profileValidationView)
      make.width.equalTo(8)
      make.height.equalTo(13)
   }

    profileValidationView.addSubview(profileValidationTickImage)
    profileValidationTickImage.snp.makeConstraints { (make) in
       make.centerY.equalToSuperview()
       make.trailing.equalTo(profileValidationArrowImage.snp.leading).offset(-15)
       make.width.equalTo(13)
       make.height.equalTo(10)
    }

    profileValidationView.addSubview(profileValidationButton)
    profileValidationButton.snp.makeConstraints { (make) in
       make.width.equalTo(contentWidth)
       make.height.equalTo(44)
    }
    profileValidationButton.addTarget(self, action: #selector(clickToOpenProfileValidations),
                                      for: UIControl.Event.touchUpInside)
}

func setupViews() {
 let contentWidth = contentView.frame.width - Layout.contentInset.left - Layout.contentInset.right
 let labelWidth = contentWidth - Layout.labelInset.left - Layout.labelInset.right

 contentView.addSubview(border1)
 border1.snp.makeConstraints { (make) in
    make.top.equalToSuperview()
    make.height.equalTo(Layout.borderHeight)
    make.width.equalTo(contentWidth)
    make.centerX.equalToSuperview()
 }

 contentView.addSubview(headerLabel)
 headerLabel.snp.makeConstraints { (make) in
    make.top.equalTo(border1.snp.bottom).offset(Layout.borderBottomMargin)
    make.leading.equalTo(20)
    make.height.equalTo(26)
    make.width.equalTo(contentWidth)
 }

 contentView.addSubview(connectedAppLabel)
 let labelHeight = TextSize.calculateHeight(connectedAppLabel.text ?? "", font: Layout.titleFont,
                                           width: labelWidth, lineSpacing: Layout.lineSpacing)
 connectedAppLabel.snp.makeConstraints { (make) in
    make.top.equalTo(headerLabel.snp.bottom).offset(Layout.titleLabelBottomMargin)
    make.leading.equalTo(headerLabel.snp.leading)
    make.width.equalTo(contentWidth)
    make.height.equalTo(labelHeight)
 }

 contentView.addSubview(baseStackView)
 baseStackView.snp.makeConstraints { (make) in
    make.leading.equalTo(connectedAppLabel.snp.leading)
    make.top.equalTo(connectedAppLabel.snp.bottom).offset(15)
    make.width.equalTo(contentWidth)
 }
 profileValidationConstraint(contentWidth)
 border2.snp.makeConstraints { (make) in
   make.height.equalTo(Layout.borderHeight)
   make.width.equalTo(contentWidth)
 }
 surveyPartnerConstraint(contentWidth)
 surveyPartnerButton.addTarget(self, action: #selector(self.clickToOpenSurveysPartners),
                               for: UIControl.Event.touchUpInside)
 baseStackView.addArrangedSubview(profileValidationView)
 baseStackView.addArrangedSubview(border2)
 baseStackView.addArrangedSubview(surveyPartnerView)
}

/*
 This update my data connected cell section
 If in profile validation all apps are connected then tick will be visible.
 If in survey partner section all apps are connected then tick will be visible
 */
func updateCellUI(_ data: [ConnectedAppData]) {
 profileValidationTickImage.isHidden = true
 surveyPartnerTickImage.isHidden = true

 if let profileData = data.filter({$0.group == ConnectedDataType.profileValidation.rawValue}) as? [ConnectedAppData] {
    if profileData.allSatisfy({$0.setUpStatus == AppStatus.connected.rawValue}) {
        profileValidationTickImage.isHidden = false
    }
 }

 if let partnerData = data.filter({$0.group == ConnectedDataType.surveyPartners.rawValue}) as? [ConnectedAppData] {
    if partnerData.allSatisfy({$0.setUpStatus == AppStatus.connected.rawValue}) {
        surveyPartnerTickImage.isHidden = false
    }
  }
}

@objc func clickToOpenSurveysPartners() {
 connectedViewDelegate?.clickToOpenPatnersScreen(dataType: .surveyPartners)
}

@objc func clickToOpenProfileValidations() {
 connectedViewDelegate?.clickToOpenProfileValidations(dataType: .profileValidation)
}

deinit {
 NotificationCenter.default.removeObserver(self)
 }
}
