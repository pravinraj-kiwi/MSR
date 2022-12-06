//
//  LinkedinFailureController.swift
//  Contributor
//
//  Created by KiwiTech on 3/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

/*
 This class gets the failure connected app UI.
*/
class ConnectedAppFailureController: UIViewController {

@IBOutlet var backToMydataButton: UIButton!
@IBOutlet var contactSupportButton: UIButton!
@IBOutlet var linkedinHeaderLabel: UILabel!
@IBOutlet var linkedinHeaderSubLabel: UILabel!
public let primaryColor = Constants.primaryColor
var appType: ConnectedApp = .linkedin

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
  contactSupportButton.setBackgroundColor(color: primaryColor, forState: .normal)
  backToMydataButton.setTitleColor(primaryColor, for: .normal)
  updatedHeaderLabel()
  updatedSubHeaderLabel()
}

func updateText() -> (String, String) {
    switch appType {
    case .linkedin:
        let app = appType.rawValue
        FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.appValidationFailureScreen(appName: app))
        return (ConnectingAppFailure.linkedinTitle.localized(), ConnectingAppFailure.linkedinSubTitle.localized())
    case .facebook:
        let app = appType.rawValue
        FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.appValidationFailureScreen(appName: app))
        return (ConnectingAppFailure.facebookTitle.localized(), ConnectingAppFailure.facebookSubTitle.localized())
    case .dynata, .pollfish, .kantar, .precision:
       return ("", "")
    }
}

func updatedHeaderLabel() {
  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.lineSpacing = 1.2
  paragraphStyle.alignment = .center

    let prefixString = updateText().0.withAttributes([
    .textColor(.black),
    .font(Font.bold.of(size: 24)),
    Attribute.paragraphStyle(paragraphStyle)
  ])
  let textCombination = NSMutableAttributedString()
  textCombination.append(prefixString)
  linkedinHeaderLabel.attributedText = textCombination
}

func updatedSubHeaderLabel() {
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
  linkedinHeaderSubLabel.attributedText = textCombination
}

@IBAction func clickToContactSupport(_ sender: Any) {
    Router.shared.route(to: .support(), from: self,
                                       presentationType: .modal(presentationStyle: .pageSheet,
                                                                transitionStyle: .coverVertical))
}

@IBAction func clickToGoToMyData(_ sender: Any) {
    dismissSelf()
    /*
      This notification is posted to update the UI for AppDetail and MyData Screen
      according to response on the respective screen
    */
    NotificationCenter.default.post(name: NSNotification.Name.connectingAppSuccess, object: nil, userInfo: nil)
 }
}

/*
This extension update the theme for button colors and text according the app
Example: Broccoili, Asking Canadians etc. That can be access through setting
For testing purpose
*/
extension ConnectedAppFailureController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    contactSupportButton.setBackgroundColor(color: colors.primary, forState: .normal)
    backToMydataButton.setTitleColor(colors.primary, for: .normal)
  }
}
