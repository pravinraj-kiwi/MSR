//
//  ValidationTestCell.swift
//  Contributor
//
//  Created by KiwiTech on 12/9/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class ValidationTestCell: UITableViewCell {
    
 @IBOutlet weak var validationTestImageView: UIImageView!
 @IBOutlet weak var validationTestIndex: UILabel!
 @IBOutlet weak var validationTestValidationText: UILabel!
 @IBOutlet weak var testVideoView: UIView!

 override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    testVideoView.viewShadow(color: .black)
 }

 override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
 }

    func updateCellContent(_ content: CameramanTestModel) {
        if content.extractedImage != nil {
            validationTestImageView.kf.setImage(with: content.extractedImage)
        } else {
            validationTestImageView.image = nil
        }
        if let index = content.extractedIndex {
            validationTestIndex.text = "Index: \(index)"
        }
        if content.validationPassed == true {
            if content.isNegativeMarker {
                validationTestValidationText.text = "Validation Passed -> ❌"
            } else {
                validationTestValidationText.text = "Validation Passed -> ✅"
            }
        } else {
            validationTestValidationText.text = "Validation Status -> ❌"
        }
    }
}
