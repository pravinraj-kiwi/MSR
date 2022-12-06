//
//  ProfileAttributeCollectionCell.swift
//  Contributor
//
//  Created by KiwiTech on 11/9/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class ProfileAttributeCollectionCell: UICollectionViewCell {
    
 @IBOutlet weak var detailType: UILabel!
 @IBOutlet weak var outerView: UIView!
 @IBOutlet weak var innerView: UIView!
 @IBOutlet weak var detailCount: UILabel!
 @IBOutlet weak var labelHeightConstriant: NSLayoutConstraint!

 override func awakeFromNib() {
   super.awakeFromNib()
   // Initialization code
   applyCommunityTheme()
   innerView.layer.cornerRadius = innerView.frame.size.width/2
   outerView.layer.cornerRadius = outerView.frame.size.width/2
   outerView.applyCircleShadow(shadowOpacity: 1)
  }
}

extension ProfileAttributeCollectionCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity,
          let colors = community.colors else {
       return
     }
    detailCount.textColor = colors.primary
  }
}

extension UIView {
    func applyCircleShadow(shadowRadius: CGFloat = 2.0,
                           shadowOpacity: Float = 1,
                           shadowColor: CGColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.09).cgColor,
                           shadowOffset: CGSize = CGSize.zero) {
        layer.cornerRadius = frame.size.height / 2
        layer.masksToBounds = false
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
}
