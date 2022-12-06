//
//  ContentSectionHeaderView.swift
//  Contributor
//
//  Created by John Martin on 3/22/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SnapKit

class GenericHeaderCollectionViewCell: UICollectionViewCell {
  struct Layout {
    static var contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    static let borderHeight: CGFloat = 1
    static let borderTopMargin: CGFloat = 9
    static let borderBottomMargin: CGFloat = 14
    static let largeFont = Font.bold.of(size: 28)
    static let regularFont = Font.bold.of(size: 22)
  }

  let border: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
    return view
  }()

  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.regularFont
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }
  
  func setupViews() {
    contentView.addSubview(border)
    border.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(Layout.borderTopMargin)
      make.left.equalToSuperview().offset(Layout.contentInset.left)
      make.right.equalToSuperview().offset(-Layout.contentInset.right)
      make.height.equalTo(Layout.borderHeight)
    }

    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(border.snp.bottom).offset(Layout.borderBottomMargin)
      make.left.equalToSuperview().offset(Layout.contentInset.left)
    }
  }
  
  func configure(with headerItem: GenericHeaderItem) {
    titleLabel.text = headerItem.text
    if headerItem.useLargeFont {
      titleLabel.font = Layout.largeFont
    } else {
      titleLabel.font = Layout.regularFont
    }
  }
}
