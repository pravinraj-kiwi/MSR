//
//  TopFeedHeaderViewCell.swift
//  Contributor
//
//  Created by John Martin on 3/25/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyUserDefaults

protocol TopHeaderCollectionViewCellDelegate: class {
  func didTapSettingsButton()
}

class TopHeaderViewCell: UICollectionViewCell {
  weak var delegate: TopHeaderCollectionViewCellDelegate?
  
  let baseStackView: UIStackView = {
   let stack = UIStackView(frame: CGRect.zero)
   stack.axis = .horizontal
   stack.distribution = .fill
   stack.spacing = 7
   return stack
  }()
    
  let dateLabel: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 13)
    label.textColor = Color.lightText.value
    return label
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.bold.of(size: 35)
    return label
  }()
  
  let settingsButton: UIButton = {
    let btn = UIButton()
    btn.setImage(Image.settingIcon.value, for: .normal)
    btn.clipsToBounds = true
    btn.showsTouchWhenHighlighted = true
    btn.adjustsImageWhenHighlighted = true
    return btn
  }()
  
  let pillView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 10
    return view
  }()
  
  let balanceLabel: UILabel = {
    let label = UILabel()
    label.font = Font.semiBold.of(size: 12)
    label.textColor = Color.whiteText.value
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    addListeners()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
    addListeners()
  }
  
  func addListeners() {
    NotificationCenter.default.addObserver(self, selector: #selector(updateBalance),
                                           name: NSNotification.Name.balanceChanged, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(updateDate),
                                           name: UIApplication.significantTimeChangeNotification, object: nil)
  }
  
  func setupViews() {
    updateBalance()
    updateDate()
    
    contentView.addSubview(dateLabel)
    dateLabel.snp.makeConstraints { (make) in
      make.width.height.equalTo(0)
    }
    
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(47)
      make.left.equalToSuperview().offset(20)
    }
    
    contentView.addSubview(baseStackView)
    baseStackView.addArrangedSubview(pillView)
    baseStackView.addArrangedSubview(settingsButton)
    
    baseStackView.snp.makeConstraints { (make) in
       make.right.equalToSuperview().offset(-22)
       make.centerY.equalTo(titleLabel)
    }
    
    pillView.snp.makeConstraints { (make) in
      make.height.equalTo(20)
    }
    
    settingsButton.snp.makeConstraints { (make) in
      make.width.height.equalTo(21)
      make.height.height.equalTo(21)
    }
    settingsButton.addTarget(self, action: #selector(self.openSettings), for: UIControl.Event.touchUpInside)
    
    pillView.addSubview(balanceLabel)
    balanceLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(7)
      make.right.equalToSuperview().offset(-7)
      make.center.equalToSuperview()
    }
    
    applyCommunityTheme()
  }
  
  func showDate() {
    dateLabel.snp.remakeConstraints { (make) in
      make.top.equalToSuperview().offset(27)
      make.left.equalToSuperview().offset(20)
      make.height.equalTo(16)
    }
  }

  func hideDate() {
    dateLabel.snp.remakeConstraints { (make) in
      make.width.height.equalTo(0)
    }
  }

  @objc func updateBalance() {
    balanceLabel.text = UserManager.shared.wallet?.balanceMSRString ?? "0 MSR"
    if let _ = Defaults[.loggedInUserRefreshToken],
        let _ = Defaults[.loggedInUserAccessToken] {
        NetworkManager.shared.reloadCurrentUser { (error) in
            if error == nil {
                self.balanceLabel.text = UserManager.shared.wallet?.balanceMSRString ?? "0 MSR"
            }
        }
    }
  }
  
  @objc func updateDate() {
    let today = Date()
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "EEEE, MMMM d"
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        dateFormat.locale = Locale.init(identifier: "pt_BR" )
    } else {
        dateFormat.locale = Locale.init(identifier: "en" )
    }
    dateLabel.text = dateFormat.string(from: today).uppercased()
  }
  
  @objc func openSettings() {
    settingsButton.bounceBriefly()
    delegate?.didTapSettingsButton()
  }
  
  func configure(with topHeaderItem: TopHeaderItem) {
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        titleLabel.font = Font.bold.of(size: 30)
    } else {
        titleLabel.font = Font.bold.of(size: 35)
    }
    titleLabel.text = topHeaderItem.text
    topHeaderItem.showDate ? showDate() : hideDate()
    contentView.setNeedsUpdateConstraints()
  }
}

extension TopHeaderViewCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    pillView.backgroundColor = colors.pill
  }
}
