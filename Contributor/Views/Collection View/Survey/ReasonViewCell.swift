//
//  ReasonViewCell.swift
//  Contributor
//
//  Created by KiwiTech on 11/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class ReasonViewCell: UICollectionViewCell {
    
 @IBOutlet weak var reasonLabel: UILabel!
 @IBOutlet weak var reasonImageView: UIImageView!
 @IBOutlet weak var baseView: UIView!
 var themeColor: UIColor = Constants.primaryColor
    
 func updateReasonCell(_ reasonModel: JobReasonModel) {
   applyCommunityTheme()
    reasonLabel.text = reasonModel.reasonName.localized()
   baseView.layer.borderWidth = 0
   baseView.layer.borderColor = UIColor.clear.cgColor
   reasonImageView.tintColor = Utilities.getRgbColor(102, 102, 102)
   reasonImageView.image = UIImage.init(named: reasonModel.reasonImage)
   if reasonModel.selection == true {
     selectedCell()
   } else {
     unSelectedCell()
   }
}
    
func selectedCell() {
 baseView.layer.borderWidth = 2
 baseView.layer.borderColor = themeColor.cgColor
 reasonImageView.tintColor = themeColor
 let color = themeColor.withAlphaComponent(0.16)
 cellShadow(color: color, view: baseView)
}
    
func unSelectedCell() {
 baseView.layer.borderWidth = 0
 baseView.layer.borderColor = UIColor.clear.cgColor
 reasonImageView.tintColor = Utilities.getRgbColor(102, 102, 102)
 reasonLabel.textColor = Utilities.getRgbColor(102, 102, 102)
 let color = Utilities.getRgbColor(0, 0, 0, 0.12)
 cellShadow(color: color, view: baseView)
}
    
func cellShadow(color: UIColor, view: UIView) {
 view.layer.masksToBounds = false
 view.layer.cornerRadius = 8.0
 view.layer.backgroundColor = UIColor.white.cgColor
 view.layer.shadowColor = color.cgColor
 view.layer.shadowOffset = CGSize.zero
 view.layer.shadowOpacity = 0.08
 view.layer.shadowRadius = 8
  }
}

extension ReasonViewCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity,
         let colors = community.colors else {
      return
    }
    themeColor = colors.primary
  }
}
