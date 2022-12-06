//
//  SettingViewCell.swift
//  Contributor
//
//  Created by KiwiTech on 9/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class SettingViewCell: UITableViewCell {

@IBOutlet weak var settingTitle: UILabel!

override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
 }
}
class LanguageViewCell: UITableViewCell {
    
    @IBOutlet weak var languageTitle: UILabel!
    @IBOutlet weak var selectedArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
