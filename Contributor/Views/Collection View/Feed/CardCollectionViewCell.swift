//
//  CardCollectionViewCell.swift
//  Contributor
//
//  Created by John Martin on 4/7/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import CoreMotion
import Kingfisher
import SwiftyAttributes

struct CardLayout {
  static let cardInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
  static let cornerRadius: CGFloat = 10
  static let shadowTopOffset: CGFloat = 8
  static let shadowRadius: CGFloat = 14.0
  static let shadowOpacity: Float = 0.12
  static let shadowOffset = CGSize(width: 0, height: 0)
  static let touchScaleFactor: CGFloat = 0.96
  static let touchAnimationDuration: Double = 0.3
  static let touchAnimationDelay: Double = 0
  static let touchAnimationSpringDamping: CGFloat = 0.8
  static let touchAnimationInitialSpringVelocity: CGFloat = 0
}
class CardCollectionViewCell: UICollectionViewCell {

  
  private weak var shadowView: UIView?
  
  var previousWidth: CGFloat = 0
  var previousHeight: CGFloat = 0
  
  let cardView: UIView = {
    let view = UIView()
    view.backgroundColor = Constants.backgroundColor
    view.layer.cornerRadius = CardLayout.cornerRadius
    view.layer.masksToBounds = true
    view.clipsToBounds = true
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupCardView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    configureShadow()
  }
  
  func setupCardView() {
    contentView.layer.backgroundColor = UIColor.clear.cgColor
    
    contentView.addSubview(cardView)
    cardView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview().inset(CardLayout.cardInset)
    }
  }
  
  // MARK: - Shadow
  
  private func configureShadow() {
    if self.shadowView != nil && bounds.width == previousWidth &&  bounds.height == previousHeight {
      return
    }
    
    previousWidth = bounds.width
    previousHeight = bounds.height
    
    // create a new shadow view for the size
    self.shadowView?.removeFromSuperview()
    let shadowView = UIView(frame: CGRect(x: CardLayout.cardInset.left, y: CardLayout.cardInset.top + CardLayout.shadowTopOffset, width: bounds.width - CardLayout.cardInset.left - CardLayout.cardInset.right, height: bounds.height - CardLayout.cardInset.bottom))
    insertSubview(shadowView, at: 0)
    self.shadowView = shadowView

    // build the shadow
    let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: CardLayout.cornerRadius)
    shadowView.layer.masksToBounds = false
    shadowView.layer.shadowRadius = CardLayout.shadowRadius
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowOffset = CardLayout.shadowOffset
    shadowView.layer.shadowOpacity = CardLayout.shadowOpacity
    shadowView.layer.shadowPath = shadowPath.cgPath
  }
  
  // MARK: - Card depress
  
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
