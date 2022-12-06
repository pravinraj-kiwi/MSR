//
//  CircularUserCell.swift
//  Contributor
//
//  Created by Shashi Kumar on 29/04/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit
import Kingfisher

class CircularUserCell: UICollectionViewCell {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var whiteView: UIView!

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    var pulsatingLayer: CAShapeLayer!
    var pulseLayers = [CAShapeLayer]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // makeCircularViews()
    }
    func configureData(model: FeedItem) {
        if let url = model.item.imageURL {
            userImage.kf.setImage(with: url)
        }
        titleLabel.text = model.item.storyTitle
    }
    func makeCircularViews() {
//        borderView = PulsatingButton(frame: borderView.frame)
        borderView.layer.masksToBounds = true
        borderView.layer.cornerRadius = borderView.frame.size.width / 2.0
        borderView.center = self.center
       // borderView.pulse()

        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = userImage.frame.size.height / 2.0
        whiteView.layer.masksToBounds = true
        whiteView.layer.cornerRadius = whiteView.frame.size.height / 2.0
//        let pulsator = Pulsator()
//        pulsator.animationDuration = 2.0
//        pulsator.pulseInterval = 1.0
//        pulsator.backgroundColor = UIColor.gray.cgColor
//        pulsator.position = CGPoint(x: borderView.frame.size.width/2.0,
//                                    y: borderView.frame.size.height/2.0)
//        self.borderView.layer.addSublayer(pulsator)
//        pulsator.start()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            self.createPulse()
//        }
    }
}
