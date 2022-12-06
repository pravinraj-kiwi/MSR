//
//  LinkedinSuccessController.swift
//  Contributor
//
//  Created by KiwiTech on 3/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

/*
 This class gets the successfully connected app UI.
*/
class ConnectedAppSuccessController: UIViewController {
    
@IBOutlet var okButton: UIButton!
@IBOutlet var linkedinSuccessHeaderLabel: UILabel!
@IBOutlet var descriptionView: UIView!
@IBOutlet var descriptionLabel: UILabel!
@IBOutlet var linkedinSuccessLabel: UILabel!
var appType: ConnectedApp?
public let primaryColor = Constants.primaryColor

override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    if #available(iOS 13.0, *) {
      isModalInPresentation = true
    }
    setUpUI()
    applyCommunityTheme()
}

func setUpUI() {
  self.navigationController?.setNavigationBarHidden(true, animated: true)
  okButton.setBackgroundColor(color: primaryColor, forState: .normal)
  linkedinSuccessHeaderLabel.text = updateText().0
  updatedLabel()
    switch appType {
    case .dynata:
        descriptionView.isHidden = false
        descriptionLabel.text = ConnectingAppSuccess.dynataDescriptionText.localized()
        okButton.setTitle(ConnectingAppSuccess.okTitle.localized(), for: .normal)
    case .pollfish:
        descriptionView.isHidden = false
        descriptionLabel.text = ConnectingAppSuccess.pollfishDescriptionText.localized()
        okButton.setTitle(ConnectingAppSuccess.okTitle.localized(), for: .normal)
    case .kantar:
       descriptionView.isHidden = false
       descriptionLabel.text = ConnectingAppSuccess.kantarDescriptionText.localized()
        okButton.setTitle(ConnectingAppSuccess.okTitle.localized(), for: .normal)
    case .precision:
        descriptionView.isHidden = false
        descriptionLabel.text = ConnectingAppSuccess.precisionDescriptionText.localized()
        okButton.setTitle(ConnectingAppSuccess.okTitle.localized(), for: .normal)
    default:
      descriptionView.isHidden = true
        okButton.setTitle(ConnectingAppSuccess.doneTitle.localized(), for: .normal)
      if let app = appType?.rawValue {
       FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.appValidationSuccessScreen(appName: app))
     }
   }
}

func updateText() -> (String, String) {
    switch appType {
    case .linkedin:
        return (ConnectingAppSuccess.linkedinTitle.localized(), ConnectingAppSuccess.linkedinSubTitle.localized())
    case .facebook:
        return (ConnectingAppSuccess.facebookTitle.localized(), ConnectingAppSuccess.facebookSubTitle.localized())
    case .dynata:
        return (ConnectingAppSuccess.dynataTitle.localized(), ConnectingAppSuccess.dynataSubTitle.localized())
    case .pollfish:
        return (ConnectingAppSuccess.pollfishTitle.localized(), ConnectingAppSuccess.pollfishSubTitle.localized())
    case .kantar:
        return (ConnectingAppSuccess.kantarTitle.localized(), ConnectingAppSuccess.kantarSubTitle.localized())
    case .precision:
        return (ConnectingAppSuccess.precisionTitle.localized(), ConnectingAppSuccess.precisionSubTitle.localized())
    default:
        return ("", "")
    }
}

/*
  This notification is posted to update the UI for AppDetail and MyData Screen
  to show tick
*/
func updatedLabel() {
   let paragraphStyle = NSMutableParagraphStyle()
   paragraphStyle.lineSpacing = 1.2
   paragraphStyle.alignment = .center

    let prefixString = updateText().1.withAttributes([
     .textColor(UIColor(white: 156.0 / 255.0, alpha: 1.0)),
     .font(Font.regular.of(size: 16)),
     Attribute.paragraphStyle(paragraphStyle)
   ])
   let textCombination = NSMutableAttributedString()
   textCombination.append(prefixString)
   linkedinSuccessLabel.attributedText = textCombination
}

@IBAction func clickToGoToMyData(_ sender: Any) {
    dismissSelf()
    /*
     This notification is posted to update the UI for AppDetail and MyData Screen
     according to response on the respective screen
     */
    NotificationCenter.default.post(name: NSNotification.Name.connectingAppSuccess,
                                    object: nil, userInfo: nil)
  }
}

/*
This extension update the theme for button colors and text according the app
Example: Broccoili, Asking Canadians etc. That can be access through setting
For testing purpose
*/
extension ConnectedAppSuccessController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    okButton.setBackgroundColor(color: colors.primary, forState: .normal)
  }
}
