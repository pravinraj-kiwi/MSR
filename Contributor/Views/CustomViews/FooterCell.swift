//
//  FooterCell.swift
//  Contributor
//
//  Created by KiwiTech on 9/29/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol FooterCellDelegate: class {
  func clickToPerformAction()
}

class FooterCell: UITableViewCell {
    
@IBOutlet weak var updateButton: UIButton!
@IBOutlet weak var footerLabel: UILabel!
weak var delegate: FooterCellDelegate?
let notifName = NSNotification.Name.updateButton
let notifErrorName = NSNotification.Name.errorUpdateButton
var hasNoError = false
    
override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    NotificationCenter.default.addObserver(self, selector: #selector(updateFormButton(_:)),
                                           name: notifName, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(updateErrorFormButton(_:)),
                                           name: notifErrorName, object: nil)
    applyCommunityTheme()
}

@objc func updateFormButton(_ notification: Notification) {
  updateButtonWithoutError()
}
    
@objc func updateErrorFormButton(_ notification: Notification) {
  DispatchQueue.main.async {
    self.updateButton.isUserInteractionEnabled = false
    self.updateButton.layer.opacity = 0.5
    self.hasNoError = false
  }
}
    
func updateButtonWithoutError() {
  DispatchQueue.main.async {
    self.updateButton.isUserInteractionEnabled = true
    self.updateButton.layer.opacity = 1.0
    self.hasNoError = true
  }
}
    
@IBAction func clickPerformAction(_ sender: Any) {
  delegate?.clickToPerformAction()
 }
}

extension FooterCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.currentCommunity,
         let colors = community.colors else {
      updateButton.setBackgroundColor(color: Color.primary.value, forState: .normal)
      return
    }
    updateButton.setBackgroundColor(color: colors.primary, forState: .normal)
  }
}
