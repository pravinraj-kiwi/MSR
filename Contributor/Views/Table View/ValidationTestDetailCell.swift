//
//  ValidationTestDetailCell.swift
//  Contributor
//
//  Created by KiwiTech on 12/10/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class ValidationTestDetailCell: UITableViewCell {
    
 @IBOutlet weak var validationDetailImageView: UIImageView!
    
 override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
 }

 override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
    
  func updateCellContent(_ content: CameramanTestModel) {
     if content.extractedImage != nil {
        validationDetailImageView.kf.setImage(with: content.extractedImage)
     } else {
        validationDetailImageView.image = nil
     }
   }
}
