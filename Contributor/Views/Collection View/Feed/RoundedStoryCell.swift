//
//  RoundedStoryCell.swift
//  Contributor
//
//  Created by Shashi Kumar on 10/05/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import Foundation
import os
import UIKit
import CoreMotion
import Kingfisher
import SwiftyAttributes
class RippleView: UIView {
    
    var pulseLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        //shape.strokeColor = UIColor.red.cgColor
        shape.lineWidth = 3
        shape.fillColor = UIColor.orange.withAlphaComponent(0.3).cgColor
        shape.lineCap = .round
        return shape
    }()
    var backgroundLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        return shape
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShapes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShapes()
    }
    
    fileprivate func setupShapes() {
        setNeedsLayout()
        layoutIfNeeded()
        guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
            return
        }
        
        
        let circularPath = UIBezierPath(arcCenter: self.center,
                                        radius: bounds.size.height/2,
                                        startAngle: 0,
                                        endAngle: 2 * CGFloat.pi,
                                        clockwise: true)
        
        pulseLayer.frame = bounds
        pulseLayer.path = circularPath.cgPath
        pulseLayer.position = self.center
        self.layer.addSublayer(pulseLayer)
        
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.lineWidth = 1
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineCap = .round
        self.layer.addSublayer(backgroundLayer)
    }
    
    func pulse() {
       // pulseLayer.lineWidth = 2.15
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.0//[0.0, 0.4]
        animation.toValue = 0.4//[0.0, 1.0]
        
       // pulseLayer.lineWidth = 2.35
        let animation2 = CABasicAnimation(keyPath: "transform.scale")
        animation2.fromValue = 0.4
        animation2.toValue = 0.8
        
      //  pulseLayer.lineWidth = 2.5
        let animation3 = CABasicAnimation(keyPath: "transform.scale")
        animation3.fromValue = 0.8
        animation3.toValue = 1.1
        
        let groupedAnimation = CAAnimationGroup()
        groupedAnimation.animations = [animation, animation2, animation3]
        groupedAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        groupedAnimation.duration = 1.25
        groupedAnimation.repeatCount = Float.infinity
        groupedAnimation.autoreverses = true
        
        pulseLayer.add(groupedAnimation, forKey: "pulsing")
    }
    func removePulseanimation() {
    }
}

class RoundedStoryCell: UICollectionViewCell {
    struct Layout {
        static var cardContentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: 0,
                                                   right: 0)
        static var imageViewContentInset = UIEdgeInsets(top: 3,
                                                        left: 3,
                                                        bottom: 3,
                                                        right: 3)
        static var imageCornerRadius: CGFloat = 31
        static var imageHeight: CGFloat = 62
        static var storyViewHeight: CGFloat = 62
        static var lineSpacing = Constants.defaultLineSpacing
        static var storyTypeFont = Font.regular.of(size: 11)
    }
    let cardView: UIView = {
      let view = UIView()
      view.backgroundColor = .clear
      view.layer.masksToBounds = true
      view.clipsToBounds = true
      return view
    }()

    let titleLabel: UILabel = {
      let label = UILabel()
      label.font = Layout.storyTypeFont
      label.numberOfLines = 2
        label.textAlignment = .center
      return label
    }()
    var imageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: 62,
                                           height: 62))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = false
        iv.layer.masksToBounds = true
        return iv
    }()
    
    var storyView: RippleView = {
        let view = RippleView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: 65,
                                                 height: 65))
        return view
    }()

    override init(frame: CGRect) {
      super.init(frame: frame)
      setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    func setupViews() {
        contentView.layer.backgroundColor = UIColor.white.cgColor
        contentView.addSubview(cardView)
        cardView.backgroundColor = .white
        storyView.backgroundColor = .white
        cardView.snp.makeConstraints { (make) in
          make.edges.equalToSuperview().inset(Layout.cardContentInset)
        }
        //storyView.center = contentView.center
        cardView.addSubview(storyView)
        storyView.snp.makeConstraints { (make) in
            make.topMargin.equalTo(20)
            make.left.equalTo(5)
            make.right.equalTo(5)
        }
        storyView.addSubview(imageView)
        imageView.center = storyView.center
        cardView.addSubview(titleLabel)
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = Layout.imageCornerRadius
        imageView.backgroundColor = .white
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(90)
            make.left.equalTo(5)
            make.right.equalTo(-5)
        }
        contentView.setNeedsUpdateConstraints()

    }
    
    fileprivate func defaultCellUI(_ colors: Community.CommunityColor) {
        self.imageView.alpha = 1.0
        self.titleLabel.alpha = 1.0
        self.storyView.pulseLayer.lineWidth = 2
        self.storyView.pulseLayer.strokeColor = colors.primary.cgColor
        self.storyView.pulseLayer.fillColor = UIColor.clear.cgColor
        self.storyView.backgroundLayer.fillColor = UIColor.clear.cgColor
    }
    fileprivate func disableCellUI(_ colors: Community.CommunityColor) {
        self.storyView.pulseLayer.lineWidth = 2
        self.storyView.pulseLayer.strokeColor = colors.primary.withAlphaComponent(0.5).cgColor
        self.storyView.pulseLayer.fillColor = UIColor.clear.cgColor
        self.storyView.backgroundLayer.fillColor = UIColor.clear.cgColor
        self.imageView.alpha = 0.5
        self.titleLabel.alpha = 0.5
    }
    fileprivate func pulseAnimateCellUI(_ colors: Community.CommunityColor) {
       // self.imageView.alpha = 1.0
        self.titleLabel.alpha = 1.0
        self.storyView.pulseLayer.lineWidth = 2
        self.storyView.pulseLayer.strokeColor = colors.primary.cgColor
        self.storyView.pulseLayer.fillColor = colors.primary.cgColor
        self.storyView.backgroundLayer.fillColor = colors.primary.cgColor
        self.storyView.alpha = 1.0
        self.storyView.pulse()
    }
    fileprivate func disableWithPulsingCellUI(_ colors: Community.CommunityColor) {
        self.storyView.pulseLayer.lineWidth = 2
        self.storyView.pulseLayer.strokeColor = colors.primary.cgColor
        self.storyView.pulseLayer.fillColor = colors.primary.cgColor
        self.storyView.backgroundLayer.fillColor = colors.primary.cgColor
        self.storyView.alpha = 0.5
        self.titleLabel.alpha = 0.5
    }
    fileprivate func seenCellUI() {
        self.imageView.alpha = 1.0
        self.titleLabel.alpha = 0.3
        self.storyView.pulseLayer.lineWidth = 0
        self.storyView.pulseLayer.strokeColor = UIColor.clear.cgColor
        self.storyView.pulseLayer.fillColor = UIColor.clear.cgColor
        self.storyView.backgroundLayer.fillColor = UIColor.clear.cgColor
    }
    fileprivate func disableSeenCellUI() {
        self.imageView.alpha = 0.5
        self.titleLabel.alpha = 0.3
        self.storyView.pulseLayer.lineWidth = 0
        self.storyView.pulseLayer.strokeColor = UIColor.clear.cgColor
        self.storyView.pulseLayer.fillColor = UIColor.clear.cgColor
        self.storyView.backgroundLayer.fillColor = UIColor.clear.cgColor
    }
    func composeUI(index: IndexPath,
                   storyitem : Story,
                   selectedStory: Story?) {
        guard let community = UserManager.shared.currentCommunity,
              let colors = community.colors else {
            return
        }
        //debugPrint("item indexpath is>>>", index)
        //debugPrint("item is>>>", storyitem.item)
        self.storyView.pulseLayer.removeAllAnimations()
        titleLabel.alpha = 1.0
        imageView.alpha = 1.0
        if selectedStory == nil {
                if storyitem.item?.storySeened ?? false {
                    debugPrint("Selected story nil and seen true>>",storyitem.item?.textTitle)
                    seenCellUI()
                    storyView.alpha = 1.0
                } else {
                    if storyitem.item?.userSpecific ?? false {
                        debugPrint("Selected story nil and userspecific true>>",storyitem.item?.textTitle)
                        pulseAnimateCellUI(colors)
                    } else {
                        debugPrint("Selected story nil and userspecific false>>",storyitem.item?.textTitle)
                        defaultCellUI(colors)
                    }
                }
        } else {
            if storyitem.item?.isSelected ?? false {
                if storyitem.item?.storySeened ?? false {
                    debugPrint("Selected story  and seen true>>",storyitem.item?.textTitle)
                    if storyitem.itemType == "content-action-only" {
                        disableSeenCellUI()
                        return
                    }
                    disableSeenCellUI()
                    titleLabel.alpha = 1.0
                    imageView.alpha = 1.0
                } else {
                    if storyitem.item?.userSpecific ?? false {
                        pulseAnimateCellUI(colors)
                        storyView.pulse()
                        debugPrint("Selected story  and userspecific true>>",storyitem.item?.textTitle)
                    } else {
                        defaultCellUI(colors)
                        debugPrint("Selected story  and userspecific false>>",storyitem.item?.textTitle)
                    }
                }
            } else {
                if storyitem.item?.storySeened ?? false {
                    disableSeenCellUI()
                    debugPrint("Selected story false and seen true>",storyitem.item?.textTitle)
                } else {
                    if storyitem.item?.userSpecific ?? false {
                        debugPrint("Selected story false and userspecific true>",storyitem.item?.textTitle)
                        disableWithPulsingCellUI(colors)
                        storyView.pulse()
                    } else {
                        debugPrint("Selected story false and userspecific false>",storyitem.item?.textTitle)
                        disableCellUI(colors)
                    }
                }
            }
        }
        self.storyView.addShadowToCircularView(size: CGSize(width: 1.0, height: 1.5))
        titleLabel.text = storyitem.item?.textTitle ?? ""
       // DispatchQueue.main.async {
            self.imageView.image = Image.dummyProfile.value
            if let url = storyitem.item?.icon {
                self.imageView.kf.setImage(with: URL(string: url))
            } else {
                self.imageView.image = Image.dummyProfile.value
            }
       // }
       // contentView.setNeedsUpdateConstraints()
    }
    var isTouched: Bool = false {
      didSet {
        var transform = CGAffineTransform.identity
        if isTouched { transform = transform.scaledBy(x: CardLayout.touchScaleFactor, y: CardLayout.touchScaleFactor) }
        UIView.animate(withDuration: CardLayout.touchAnimationDuration, delay: CardLayout.touchAnimationDelay, usingSpringWithDamping: CardLayout.touchAnimationSpringDamping, initialSpringVelocity: CardLayout.touchAnimationInitialSpringVelocity, options: [], animations: {
          self.transform = transform
        }, completion: nil)
      }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      isTouched = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      isTouched = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesCancelled(touches, with: event)
      isTouched = false
    }
}

extension UIView {
    func addShadowToCircularView(size: CGSize) {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.19).cgColor
        self.layer.shadowOffset = size
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.cornerRadius = self.frame.width / 2
    }
}
