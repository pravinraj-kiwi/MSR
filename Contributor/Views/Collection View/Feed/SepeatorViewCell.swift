//
//  SepeatorViewCell.swift
//  Contributor
//
//  Created by Shashi Kumar on 27/05/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit

class SepeatorViewCell: UICollectionViewCell {
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var seperatorBottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.seperatorView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)

    }

}
