//
//  ActivityIndicatorButton.swift
//  Contributor
//
//  Created by arvindh on 27/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class ActivityIndicatorButton: UIView {
  enum State {
    case normal, loading, error
  }
  var state: State = .normal {
    didSet {
      update(state: state)
    }
  }
  
  var isEnabled: Bool = true {
    didSet {
      button.isEnabled = isEnabled
      self.alpha = isEnabled ? 1 : Constants.buttonDisabledAlpha
    }
  }
  
  var buttonColor: UIColor = Constants.backgroundColor {
    didSet {
      self.backgroundColor = buttonColor
      button.backgroundColor = buttonColor
    }
  }
  
    var buttonTitleColor: UIColor = Constants.primaryColor {
    didSet {
      button.setTitleColor(buttonTitleColor, for: .normal)
    }
  }
  
  var spinnerColor: UIColor = Constants.primaryColor {
    didSet {
      activityIndicator.color = spinnerColor
    }
  }
  
  lazy var button: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitleColor(buttonTitleColor, for: .normal)
    button.titleLabel?.font = Font.regular.of(size: 18)
    button.titleLabel?.textAlignment = .center
    button.backgroundColor = buttonColor
    return button
  }()
  
  lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: CGRect.zero)
    indicator.color = Constants.primaryColor
    indicator.hidesWhenStopped = true
    return indicator
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  func setup() {
    setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    layer.cornerRadius = Constants.buttonCornerRadius
    layer.masksToBounds = true
    backgroundColor = buttonColor
    
    addSubview(button)
    button.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
    
    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.center.equalTo(self)
      make.width.equalTo(20)
      make.height.equalTo(activityIndicator.snp.width)
    }
    applyCommunityTheme()
  }
  
  func addTarget(_ target: Any?, action: Selector, for events: UIControl.Event) {
    button.addTarget(target, action: action, for: events)
  }
  
  func setTitle(_ title: String?, for state: UIControl.State) {
    button.setTitle(title, for: state)
  }
  
  func setBackgroundColor(color: UIColor, forState: UIControl.State) {
    button.setBackgroundColor(color: color, forState: forState)
  }

  func setDarkeningBackgroundColor(color: UIColor) {
    button.setDarkeningBackgroundColor(color: color)
  }

  fileprivate func update(state: State) {
    switch state {
    case .normal, .error:
      activityIndicator.stopAnimating()
      button.isHidden = false
    case .loading:
      activityIndicator.startAnimating()
      button.isHidden = true
    }
  }
}
extension ActivityIndicatorButton: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    activityIndicator.color = colors.primary
    button.backgroundColor = colors.primary
  }
}
