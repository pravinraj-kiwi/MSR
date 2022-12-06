//
//  MyDataHeaderCollectionViewCell.swift
//  Contributor
//
//  Created by KiwiTech on 6/17/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes
import UICountingLabel

class MyDataHeaderCollectionViewCell: UICollectionViewCell, SelfSizeableCell {
  
 var index: Int = 0
    
struct Layout {
   static let baseViewTopMargin: CGFloat = 16
   static let titleFont = Font.regular.of(size: 16)
   static var labelInset = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
 }

let baseView: UIView = {
  let view = UIView()
  view.layer.cornerRadius = 6.0
  return view
}()
    
let stackView: UIStackView = {
  let stack = UIStackView(frame: CGRect.zero)
  stack.axis = .vertical
  stack.distribution = .fill
  stack.spacing = 1
  return stack
}()
    
let headerLabel: EdgeInsetLabel = {
  let label = EdgeInsetLabel()
  label.font = Font.bold.of(size: 19)
  label.textColor = .white
  label.numberOfLines = 0
  label.topTextInset = 0
  label.lineBreakMode = .byWordWrapping
  return label
}()

let subHeaderLabel: UILabel = {
  let label = UILabel()
  label.font = Font.regular.of(size: 14)
  label.textColor = UIColor.white.withAlphaComponent(1.0)
  label.numberOfLines = 0
  label.lineBreakMode = .byWordWrapping
  return label
}()
    
let progressView: UIProgressView = {
  let progressView = UIProgressView()
  progressView.layer.cornerRadius = 4
  progressView.clipsToBounds = true
  progressView.layer.sublayers![1].cornerRadius = 4
  progressView.subviews[1].clipsToBounds = true
  progressView.progressTintColor = .white
  progressView.trackTintColor = UIColor("#66FFFFFF").withAlphaComponent(0.41)
  progressView.barHeight = 4.0
  return progressView
}()

let percentageLabel: UICountingLabel = {
  let label = UICountingLabel()
  label.font = Font.light.of(size: 45)
  label.textColor = .white
  label.textAlignment = .right
  label.numberOfLines = 1
  label.contentMode = .bottom
  return label
}()
    
let percentLabel: UILabel = {
  let label = UILabel()
  label.font = Font.bold.of(size: 17)
  label.text = " %"
  label.textColor = .white
  label.numberOfLines = 0
  label.contentMode = .bottom
  return label
}()

override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    addObserver()
}
  
required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
    addObserver()
}

func addObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(updateProgressBar(_:)),
                                           name: NSNotification.Name.updateStats, object: nil)
}
    
func setupViews() {
    setupContentView()
    contentView.addSubview(baseView)

    baseView.snp.makeConstraints { (make) in
      make.top.equalTo(contentView)
      make.left.equalTo(contentView).offset(22)
      make.right.equalTo(contentView).offset(-22)
      make.bottom.equalTo(contentView)
    }
    
    baseView.addSubview(stackView)
    baseView.addSubview(percentageLabel)
    baseView.addSubview(percentLabel)
    baseView.addSubview(progressView)

    stackView.addArrangedSubview(headerLabel)
    stackView.addArrangedSubview(subHeaderLabel)
    
    stackView.snp.makeConstraints { (make) in
      make.top.equalTo(baseView)
      make.leading.equalTo(baseView).offset(15)
      make.trailing.equalTo(percentageLabel.snp.leading).offset(-20)
      make.bottom.equalTo(progressView.snp.top).offset(-20)
    }
    
    progressView.snp.makeConstraints { (make) in
        make.leading.equalTo(baseView).offset(13)
        make.trailing.equalTo(baseView).offset(-13)
        make.bottom.equalTo(baseView).offset(-15)
    }
    
    headerLabel.snp.makeConstraints { (make) in
      make.top.equalTo(stackView).offset(12)
    }
    
    subHeaderLabel.snp.makeConstraints { (make) in
      make.bottom.equalTo(stackView)
    }

    percentageLabel.snp.makeConstraints { (make) in
       make.centerY.equalTo(stackView).offset(5)
       make.trailing.equalTo(percentLabel.snp.leading).offset(1)
       make.width.greaterThanOrEqualTo(41)
       make.height.equalTo(54)
    }
    
    percentLabel.snp.makeConstraints { (make) in
       make.bottom.equalTo(percentageLabel).offset(-10)
       make.trailing.equalTo(baseView).offset(-13)
       make.width.equalTo(20)
       make.height.equalTo(20)
    }
}
  
override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    return selfSizingLayoutAttributes(layoutAttributes)
}
  
func updateCellUI(animate: Bool, statsData: StatTiles) {
  headerLabel.text = statsData.title
  subHeaderLabel.text = statsData.subtitle
  if let value = statsData.progressBarPercentage {
    updatePercentage(animate, value)
  }
  if let backViewColor = statsData.color {
    baseView.backgroundColor = UIColor(backViewColor)
  }
}
    
func updatePercentage(_ animate: Bool, _ progressBarPercentage: Int) {
    let value = Float(progressBarPercentage)
    progressView.setProgress(value/100, animated: animate)
    if animate {
        let updatedValue = UserDefaults.standard.integer(forKey: Constants.percentageDefault)
        percentageLabel.count(from: CGFloat(updatedValue), to: CGFloat(progressBarPercentage), withDuration: 1.0)
        percentageLabel.format = "%d"
        percentageLabel.method = .easeOut
    } else {
        percentageLabel.text = "\(progressBarPercentage)"
        UserDefaults.standard.set(progressBarPercentage, forKey: Constants.percentageDefault)
    }
    self.layoutIfNeeded()
}

@objc func updateProgressBar(_ notification: Notification) {
    let object = notification.object as? [StatTiles]
    if let stats = object?[index] {
        updateCellUI(animate: true, statsData: stats)
    }
  }
}
