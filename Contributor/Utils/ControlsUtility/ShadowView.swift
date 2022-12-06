//
//  ShadowView.swift
//  Contributor
//
//  Created by KiwiTech on 2/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowView: UIView {
    
override func awakeFromNib() {
    super.awakeFromNib()
    styleShadow()
}

private func styleShadow() {
   layer.masksToBounds = false
   layer.cornerRadius = Constants.cardCornerRadius
   layer.backgroundColor = UIColor.white.cgColor
   layer.borderColor = UIColor.clear.cgColor
   layer.shadowColor = UIColor.black.cgColor
   layer.shadowOffset = CGSize(width: 0, height: 0)
   layer.shadowOpacity = 0.1
   layer.shadowRadius = 10
  }
}
