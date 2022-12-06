//
//  LayerContainerView.swift
//  Contributor
//
//  Created by John Martin on 2/17/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

class LayerContainerView: UIView {
  override public class var layerClass: Swift.AnyClass {
    return CAGradientLayer.self
  }
  
  var color1: UIColor = colorListLight[0].value {
    didSet {
      guard let gradientLayer = self.layer as? CAGradientLayer else { return }
      gradientLayer.colors = [color1.cgColor, color2.cgColor]
    }
  }
  
  var color2: UIColor = colorList[0].value {
    didSet {
      guard let gradientLayer = self.layer as? CAGradientLayer else { return }
      gradientLayer.colors = [color1.cgColor, color2.cgColor]
    }
  }
  
  override func layoutSubviews() {
    guard let gradientLayer = self.layer as? CAGradientLayer else { return }
    gradientLayer.frame = self.bounds
  }
}
