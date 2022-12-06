//
//  ConfirmationViewController.swift
//  Contributor
//
//  Created by Kiwitech on 01/03/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var phoneValidatedLabel: UILabel!
    @IBOutlet weak var phoneValidatedInfoLabel: UILabel!
    public let primaryColor = Constants.primaryColor

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        doneButton.setDarkeningBackgroundColor(color: primaryColor)
        doneButton.setTitleColor(Color.whiteText.value, for: .normal)
        AnalyticsManager.shared.logOnce(event: .validatedPhone)
        applyCommunityTheme()
    }
    
    @IBAction func clickToGoBack(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
extension ConfirmationViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    doneButton.setTitle("Done".localized(), for: .normal)
    doneButton.setDarkeningBackgroundColor(color: colors.primary)
    phoneValidatedLabel.text = Text.phoneValidated.localized()
    phoneValidatedInfoLabel.text = Text.phoneValidatedMessage.localized()
  }
}
