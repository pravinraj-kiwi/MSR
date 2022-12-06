//
//  DataTypeHeaderTableViewCell.swift
//  Contributor
//
//  Created by Kiwitech on 05/05/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

class DataTypeHeaderTableViewCell: UITableViewCell {

@IBOutlet weak var headerTitle: UILabel!
@IBOutlet weak var headerImageView: UIImageView!
@IBOutlet weak var headerLabel: UILabel!
@IBOutlet weak var headerSubLabel: UILabel!

override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
}

func updateUI(groupType: ConnectedDataType) {
    switch groupType {
    case .profileValidation:
        headerTitle.text = MyDataAppsDetail.ProfileValidationsHeaderText.localized()
        headerImageView.image = Image.profileValidate.value
        headerLabel.text = MyDataAppsDetail.ProfileValidationsTitleText.localized()
        headerSubLabel.text = MyDataAppsDetail.ProfileValidationsDescriptionText.localized()
    case .surveyPartners:
        headerTitle.text = MyDataAppsDetail.SurveyPartnersHeaderText.localized()
        headerImageView.image = Image.bitmap.value
        headerLabel.text = MyDataAppsDetail.SurveyPartnersTitleText.localized()
        headerSubLabel.text = MyDataAppsDetail.SurveyPartnersDescriptionText.localized()
       }
   }
}

protocol AppDetailHeaderDelegate: class {
    func didTapGesture(_ label: UILabel, gesture: UITapGestureRecognizer)
}

class AppDetailHeaderTableViewCell: UITableViewCell {
   
@IBOutlet var connecteAppImage: UIImageView!
@IBOutlet var connecteAppTitle: UILabel!
@IBOutlet var linkedinConnectionHeaderLabel: UILabel!
@IBOutlet var linkedinConnectionHeaderSubLabel: EdgeInsetLabel!
@IBOutlet var dashView: UIView!

weak var appDetailHeaderDelegate: AppDetailHeaderDelegate?
let privacyPolicy = "Privacy Policy"
let terms = "Terms & Conditions"
var communityColor: UIColor = Constants.primaryColor
var appType: ConnectedApp?
    
override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    addTapGestureOnLabel()
}
    
func getApp(_ appType: ConnectedApp) -> String {
    switch appType {
    case .linkedin:
        return AppTypeHeaderCell.linkedin.localized()
    case .facebook:
        return AppTypeHeaderCell.facebook.localized()
    case .dynata, .pollfish, .kantar, .precision:
        return AppTypeHeaderCell.dynata.localized()
    }
}
        
func updateHeaderUI(_ appType: ConnectedApp) {
 let app = getApp(appType)
 updatedHeaderLabel(app)
 connecteAppTitle.text = app
  if appType == .dynata {
    connecteAppImage.image = Image.dynataLogo.value
    dashView.isHidden = true
    updateDynataDetail()
  } else if appType == .linkedin {
    connecteAppImage.image = Image.linkedInLogo.value
    dashView.isHidden = false
    updatedSubHeaderLabel(app)
  } else if appType == .facebook {
    connecteAppImage.image = Image.fbLogo.value
    dashView.isHidden = false
    updatedSubHeaderLabel(app)
  } else if appType == .pollfish {
    connecteAppImage.image = Image.pollfishLogo.value
    dashView.isHidden = true
    updatePollfishDetail()
  } else if appType == .kantar {
    connecteAppImage.image = Image.kantarLogo.value
    dashView.isHidden = true
    updateKantarDetail()
  } else if appType == .precision {
    connecteAppImage.image = Image.precisionSampleLogo.value
    dashView.isHidden = true
    updatePrecisionDetail()
  }
 }
    
 func updatedHeaderLabel(_ appType: String) {
  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.lineSpacing = 1.2
  paragraphStyle.alignment = .left

    let prefix = "Measure uses".localized() + "\(appType)" + " to verify that you are a real, ".localized()
    let sufix = "unique person. Connect your account to qualify for more and better jobs.".localized()
  let prefixString = (prefix + sufix).withAttributes([
     .textColor(UIColor(white: 17.0 / 255.0, alpha: 1.0)),
     .font(Font.regular.of(size: 16)),
     Attribute.paragraphStyle(paragraphStyle)
  ])
  let textCombination = NSMutableAttributedString()
  textCombination.append(prefixString)
  linkedinConnectionHeaderLabel.attributedText = textCombination
 }
        
 func updatedSubHeaderLabel(_ appType: String) {
  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.lineSpacing = 1.2
  paragraphStyle.alignment = .center

    let prefix = "None of your".localized() +  "\(appType)" + "data or network ".localized()
    let sufix = "connections will be collected by Measure.".localized()
  let prefixString = (prefix + sufix).withAttributes([
     .textColor(UIColor(white: 75.0 / 255.0, alpha: 1.0)),
     .font(Font.regular.of(size: 14)),
     Attribute.paragraphStyle(paragraphStyle)
  ])
  let textCombination = NSMutableAttributedString()
  textCombination.append(prefixString)
  linkedinConnectionHeaderSubLabel.attributedText = textCombination
 }
        
 func updateDynataDetail() {
   applyCommunityTheme()
}
    
func updatePollfishDetail() {
   applyCommunityTheme()
}
    
func updateKantarDetail() {
   applyCommunityTheme()
}
    
func updatePrecisionDetail() {
   applyCommunityTheme()
}
    
func addTapGestureOnLabel() {
  let tap = UITapGestureRecognizer(target: self,
                                   action: #selector(tapLabel(tap:)))
  linkedinConnectionHeaderLabel.addGestureRecognizer(tap)
  linkedinConnectionHeaderLabel.isUserInteractionEnabled = true
}
    
 @objc func tapLabel(tap: UITapGestureRecognizer) {
    appDetailHeaderDelegate?.didTapGesture(linkedinConnectionHeaderLabel, gesture: tap)
  }
}

extension AppDetailHeaderTableViewCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
        return
    }
    var prefixString = DynataHeaderCell.dynataText.localized()
    if appType == .pollfish {
       prefixString = DynataHeaderCell.pollfishText.localized()
    }
    if appType == .kantar {
       prefixString = DynataHeaderCell.kantarText.localized()
    }
    if appType == .precision {
       prefixString = DynataHeaderCell.precisionText.localized()
    }
    let termsAttributedText = prefixString.lineSpaced(1.2, with: Font.regular.of(size: 16))
    let linkFontAttributes = [
           Attribute.textColor(colors.primary),
           Attribute.underlineColor(colors.primary),
           Attribute.underlineStyle(.single)
       ]
     termsAttributedText.addAttributesToTerms(linkFontAttributes, to: [privacyPolicy, terms])
     linkedinConnectionHeaderLabel.attributedText = termsAttributedText
  }
}
