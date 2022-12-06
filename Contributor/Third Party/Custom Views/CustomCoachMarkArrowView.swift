// Copyright (c) 2015-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit
import Instructions

internal class CustomCoachMarkArrowView: UIView, CoachMarkArrowView {

var topPlateImage = UIImage(named: "arrow-top")
var bottomPlateImage = UIImage(named: "arrow-bottom")
var plate = UIImageView()

var isHighlighted: Bool = false

private var column = UIView()

init(orientation: CoachMarkArrowOrientation) {
    super.init(frame: CGRect.zero)

    if orientation == .top {
        self.plate.image = topPlateImage
    } else if orientation == .bottom {
        self.plate.image = bottomPlateImage
    }

    self.translatesAutoresizingMaskIntoConstraints = false
    self.plate.translatesAutoresizingMaskIntoConstraints = false
    plate.backgroundColor = UIColor.clear
    self.addSubview(plate)
    plate.fillSuperviewHorizontally()

    if orientation == .top {
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[plate(==12)]-(2)-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: ["plate": plate]
            )
        )
    } else if orientation == .bottom {
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-(2)-[plate(==20)]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: ["plate": plate]
            )
        )
    }
}

required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding.")
 }
}
