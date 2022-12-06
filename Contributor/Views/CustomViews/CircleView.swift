//
//  CircleView.swift
//  Contributor
//
//  Created by arvindh on 13/07/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class CircleView: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  func setup() {
    self.layer.masksToBounds = true
  }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.bounds.width / 2
  }
}
