//
//  OptionSelectionIndicator.swift
//  Contributor
//
//  Created by arvindh on 07/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

enum OptionSelectionType {
  case radio, checkbox
}

class OptionSelectionIndicator: UIView {
  let outerView: UIView = {
    let view = UIView(frame: CGRect.zero)
    view.backgroundColor = Color.border.value
    view.layer.masksToBounds = true
    return view
  }()
  
  let innerView: UIView = {
    let view = UIView(frame: CGRect.zero)
    view.backgroundColor = Constants.backgroundColor
    view.layer.masksToBounds = true
    return view
  }()
  
  let selectionIndicator: UIView = {
    let view = UIView(frame: CGRect.zero)
    view.layer.masksToBounds = true
    return view
  }()
  
  var isSelected: Bool = false {
    didSet {
      selectionIndicator.isHidden = !isSelected
    }
  }
  
  var selectionType: OptionSelectionType = .radio {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if selectionType == .radio {
      outerView.layer.cornerRadius = outerView.bounds.width/2
      innerView.layer.cornerRadius = innerView.bounds.width/2
      selectionIndicator.layer.cornerRadius = selectionIndicator.bounds.width/2
    }
    else {
      outerView.layer.cornerRadius = 0
      innerView.layer.cornerRadius = 0
      selectionIndicator.layer.cornerRadius = 0
    }
  }
  
  func setupViews() {
    addSubview(outerView)
    outerView.snp.makeConstraints { (make) in
      make.edges.equalTo(self)
    }
    
    addSubview(innerView)
    innerView.snp.makeConstraints { (make) in
      make.edges.equalTo(outerView).inset(1)
    }
    
    addSubview(selectionIndicator)
    selectionIndicator.snp.makeConstraints { (make) in
      make.edges.equalTo(innerView).inset(4)
    }
    selectionIndicator.isHidden = true
    
    applyCommunityTheme()
  }
}

extension OptionSelectionIndicator: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    selectionIndicator.backgroundColor = colors.primary
  }
}

