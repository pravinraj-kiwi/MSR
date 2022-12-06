//
//  DataCategoryCollectionViewCell.swift
//  Contributor
//
//  Created by arvindh on 18/12/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class DataCategoryCollectionViewCell: UICollectionViewCell {
  struct Layout {
    static let titleTopMargin: CGFloat = 4
    static let titleBottomMargin: CGFloat = 9
    static let titleSideMargin: CGFloat = 0
    static let imageViewWidth: CGFloat = 45
    static let imageViewHeight: CGFloat = 45
    static let checkBoxImageViewWidth: CGFloat = 25
    static let checkBoxImageViewHeight: CGFloat = 25
    static let plusViewWidth: CGFloat = 56
    static let plusViewHeight: CGFloat = 56
  }
  
  let baseView: UIView = {
    let view = UIView()
    return view
  }()
    
  let imageContainerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 7
    view.layer.masksToBounds = true
    view.isHidden = true
    return view
  }()

  let imageView: UIImageView = {
    let imagev = UIImageView()
    imagev.contentMode = .scaleAspectFit
    imagev.clipsToBounds = true
    return imagev
  }()
    
  let checkImageView: UIImageView = {
    let checkImagev = UIImageView()
    checkImagev.contentMode = .scaleAspectFit
    checkImagev.image = Image.checkIcon.value
    checkImagev.clipsToBounds = true
    return checkImagev
  }()
    
  let plusView: UIView = {
     let view = UIView()
     view.layer.cornerRadius = 28
     view.layer.masksToBounds = true
     view.isHidden = false
     return view
  }()
    
  let addIconImageView: UIImageView = {
    let addIconv = UIImageView()
    addIconv.contentMode = .scaleAspectFit
    addIconv.image = Image.addIcon.value
    addIconv.clipsToBounds = true
    return addIconv
  }()

  let titleLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = Constants.backgroundColor
    label.font = Font.regular.of(size: 13)
    label.textAlignment = .center
    label.numberOfLines = 2
    label.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
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
    contentView.addSubview(baseView)
    baseView.snp.makeConstraints { (make) in
      make.top.equalTo(contentView).offset(Layout.titleTopMargin)
      make.left.equalTo(contentView)
      make.right.equalTo(contentView)
      make.width.equalTo(96)
      make.height.equalTo(96)
    }
    
    baseView.addSubview(plusView)
    plusView.snp.makeConstraints { (make) in
      make.centerX.equalTo(baseView)
      make.centerY.equalTo(baseView)
      make.width.equalTo(Layout.plusViewWidth)
      make.height.equalTo(Layout.plusViewHeight)
    }
        
    plusView.addSubview(addIconImageView)
    addIconImageView.snp.makeConstraints { (make) in
       make.centerX.equalTo(plusView)
       make.centerY.equalTo(plusView)
       make.width.equalTo(Layout.checkBoxImageViewWidth)
       make.height.equalTo(Layout.checkBoxImageViewHeight)
    }
    
    baseView.addSubview(imageContainerView)
    imageContainerView.snp.makeConstraints { (make) in
       make.top.equalTo(baseView).offset(5)
       make.left.equalTo(baseView).offset(5)
       make.right.equalTo(baseView).offset(-5)
       make.bottom.equalTo(baseView).offset(-5)
    }
    
    imageContainerView.addSubview(imageView)
    imageView.snp.makeConstraints { (make) in
       make.centerX.equalTo(imageContainerView)
       make.centerY.equalTo(imageContainerView)
       make.width.equalTo(Layout.imageViewWidth)
       make.height.equalTo(Layout.imageViewHeight)
    }

    imageContainerView.addSubview(checkImageView)
    checkImageView.snp.makeConstraints { (make) in
       make.right.equalTo(imageContainerView).offset(5)
       make.top.equalTo(imageContainerView.snp.top).offset(-5)
       make.width.equalTo(Layout.checkBoxImageViewWidth)
       make.height.equalTo(Layout.checkBoxImageViewHeight)
    }
    
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
       make.left.equalTo(contentView).offset(Layout.titleSideMargin)
       make.right.equalTo(contentView).offset(-Layout.titleSideMargin)
       make.top.equalTo(baseView.snp.bottom).offset(Layout.titleTopMargin)
       make.bottom.equalTo(contentView).offset(-Layout.titleBottomMargin)
    }
}

func updateCellContent(_ category: SurveyCategory, indexPath: IndexPath) {
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        if let title = category.titlePt {
            titleLabel.text = title
        } else {
            titleLabel.text = category.title
        }
    } else {
        titleLabel.text = category.title
    }

    if let url = URL(string: category.imageURLString) {
      imageView.kf.setImage(with: url)
    }
    
    baseView.dropShadow()
    plusView.isHidden = category.isCompleted
    imageContainerView.isHidden = !category.isCompleted
    if let color = category.color {
        plusView.backgroundColor =  UIColor(color)
        imageContainerView.backgroundColor = UIColor(color)
    }
   }
}

extension UIView {
    func dropShadow() {
        layer.masksToBounds = false
        layer.cornerRadius = 7.0
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderColor = UIColor.clear.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 5
    }
}
