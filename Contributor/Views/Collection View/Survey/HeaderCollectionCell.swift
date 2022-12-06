//
//  HeaderCollectionCell.swift
//  Contributor
//
//  Created by KiwiTech on 11/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class HeaderCollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
        titleLabel.text = CompletedSurveyText.jobExitHeaderText.localized()
   }
}
