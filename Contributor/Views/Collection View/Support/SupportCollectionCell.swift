//
//  SupportCollectionCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class SupportCollectionCell: UICollectionViewCell {
  
 @IBOutlet weak var supportView: UIView!
 @IBOutlet weak var supportImage: UIImageView!
 @IBOutlet weak var supportLabel: UILabel!

 func updateSupportCell(_ model: SupportModel) {
    applyCommunityTheme()
    supportImage.image = UIImage(named: model.supportImage)
    supportLabel.text = model.supportName.localized()
 }
}

extension SupportCollectionCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.currentCommunity,
         let colors = community.colors else {
      return
    }
    supportView.backgroundColor = colors.primary
  }
}
