//
//  RadioOptionTableViewCell.swift
//  Contributor
//
//  Created by arvindh on 06/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class RadioOptionTableViewCell: UITableViewCell {
  struct Layout {
    static var labelLeftMargin: CGFloat = 16
    static var labelRightMargin: CGFloat = 16
    static var labelTopMargin: CGFloat = 20
    static var labelBottomMargin: CGFloat = 20
    static var borderHeight: CGFloat = 1
    static var selectionIndicatorWidth: CGFloat = 18
    static var selectionIndicatorLeftMargin: CGFloat = 16
  }
  
  let label: UILabel = {
    let label = UILabel()
    label.backgroundColor = Constants.backgroundColor
    label.numberOfLines = 0
    label.font = Font.regular.of(size: 15)
    label.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    return label
  }()
  
  let border: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
    return view
  }()
  
  let selectionIndicator: OptionSelectionIndicator = {
    let view = OptionSelectionIndicator(frame: CGRect.zero)
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func setupViews() {
    contentView.backgroundColor = Constants.backgroundColor
    contentView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    
    contentView.addSubview(selectionIndicator)
    selectionIndicator.snp.makeConstraints { (make) in
      make.width.equalTo(Layout.selectionIndicatorWidth)
      make.height.equalTo(selectionIndicator.snp.width)
      make.left.equalTo(contentView).offset(Layout.selectionIndicatorLeftMargin)
      make.centerY.equalTo(contentView)
    }
    
    contentView.addSubview(label)
    label.snp.makeConstraints { (make) in
      make.top.equalTo(contentView).offset(Layout.labelTopMargin)
      make.bottom.equalTo(contentView).offset(-Layout.labelBottomMargin)
      make.left.equalTo(selectionIndicator.snp.right).offset(Layout.labelLeftMargin)
      make.right.equalTo(contentView).offset(-Layout.labelRightMargin)
      make.height.greaterThanOrEqualTo(24)
    }
    
    addSubview(border)
    border.snp.makeConstraints { (make) in
      make.height.equalTo(Layout.borderHeight)
      make.left.equalTo(self)
      make.right.equalTo(self)
      make.bottom.equalTo(self)
    }
    
    applyCommunityTheme()
  }
  
  func setSelected(_ selected: Bool) {
    selectionIndicator.isSelected = selected
    applyCommunityTheme()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
}

extension RadioOptionTableViewCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }

    let selected = selectionIndicator.isSelected
    
    let backgroundColor = selected ? colors.primary.withAlphaComponent(0.1) : colors.background
    let labelColor = selected ? UIColor.clear : colors.background // To prevent mixing of colors with alpha < 1
    
    contentView.backgroundColor = backgroundColor
    label.backgroundColor = labelColor
  }
}
