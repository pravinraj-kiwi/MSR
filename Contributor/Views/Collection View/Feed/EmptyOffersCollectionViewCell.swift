//
//  EmptyOffersViewCell.swift
//  Contributor
//
//  Created by John Martin on 3/24/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyUserDefaults

protocol ListItemNeedsResizingDelegate: class {
  func needsResizing()
}

class EmptyOffersCollectionViewCell: UICollectionViewCell {
  struct Layout {
    static var emojiFont = Font.regular.of(size: 64)
    static var mainLabelFont = Font.bold.of(size: 20)
    static var subLabelFont = Font.regular.of(size: 16)
    static var historyFont = Font.regular.of(size: 16)
    static var borderInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    static var contentInset = UIEdgeInsets(top: 0, left: 40, bottom: 40, right: 40)
    static let lineSpacing = Constants.defaultLineSpacing
    static let borderHeight: CGFloat = 1
    static let maxContentWidth: CGFloat = 280
    static let emojiTopMargin: CGFloat = 40
    static let subLabelTopMargin: CGFloat = 4
    static let historyContainerTopMargin: CGFloat = 25
    static let historyContainerWidth: CGFloat = 164
    static let historyContainerPadding: CGFloat = 10
    static let historyContainerSpacing: CGFloat = 5
  }
  
  static func calculateHeightForWidth(stats: UserStats?, width: CGFloat) -> CGFloat {
    let maxPossibleContentWidth = width - Layout.contentInset.left - Layout.contentInset.right
    let contentWidth = maxPossibleContentWidth < Layout.maxContentWidth ? maxPossibleContentWidth : Layout.maxContentWidth
    
    let i = UserManager.shared.selectedEmptyMessageIndex
    
    let emojiHeight = TextSize.calculateHeight(EmptyOffersCollectionViewCell.emptyMessages[i].0, font: Layout.emojiFont, width: contentWidth)
    let mainLabelHeight = TextSize.calculateHeight(EmptyOffersCollectionViewCell.emptyMessages[i].1, font: Layout.mainLabelFont, width: contentWidth, lineSpacing: Layout.lineSpacing)
    
    var subLabelHeight: CGFloat = 0
    if shouldShowFirstTimeMessage(stats: stats) {
      subLabelHeight = TextSize.calculateHeight(firstTimeMessage.2, font: Layout.subLabelFont, width: contentWidth, lineSpacing: Layout.lineSpacing)
    } else {
      subLabelHeight = TextSize.calculateHeight(emptyMessages[i].2, font: Layout.subLabelFont, width: contentWidth, lineSpacing: Layout.lineSpacing)
    }
    
    var historyContainerHeight: CGFloat = 0
    if shouldShowHistory(stats: stats) {
      historyContainerHeight = Layout.historyContainerTopMargin
        + 2 * Layout.historyContainerPadding
        + 2 * TextSize.calculateSingleLineHeight(font: Layout.historyFont, width: Layout.historyContainerWidth)
        + Layout.historyContainerSpacing
    }
    
    let height: CGFloat = Layout.borderHeight
      + Layout.emojiTopMargin
      + emojiHeight
      + mainLabelHeight
      + Layout.subLabelTopMargin
      + subLabelHeight
      + historyContainerHeight
      + Layout.contentInset.bottom
    
    return height
  }
  
  static func shouldShowFirstTimeMessage(stats: UserStats?) -> Bool {
    if let stats = stats, stats.totalCompletedJobs == 0 && !Defaults[.shownFirstTimeEmptyOffersMessage] {
      return true
    }
    return false
  }

  static func shouldShowHistory(stats: UserStats?) -> Bool {
    if let stats = stats, stats.totalCompletedJobs > 0 {
      return true
    }
    return false
  }

  static let emptyMessages = [
    ("🚀", FeedEmptyOffer.jobCompletedText, FeedEmptyOffer.searchingText),
    ("🙌", FeedEmptyOffer.jobCompletedText, FeedEmptyOffer.findMoreText),
    ("🐾", FeedEmptyOffer.jobCompletedText, FeedEmptyOffer.trackMoreText),
    ("🍿", FeedEmptyOffer.jobCompletedText, FeedEmptyOffer.lookingMoreText),
  ]
  
    static let firstTimeMessage = ("👏", FeedEmptyOffer.niceWorkText, FeedEmptyOffer.searchingJobText)

  weak var resizingDelegate: ListItemNeedsResizingDelegate?
  var emptyOffersItem: EmptyOffersItem?
  var selectedMessageIndex = 0
  
  let border1: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBorder.value
    return view
  }()

  let emojiLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.emojiFont
    label.textColor = Color.text.value
    label.numberOfLines = 0
    return label
  }()

  let mainLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.mainLabelFont
    label.textColor = Color.text.value
    label.numberOfLines = 0
    return label
  }()

  let subLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.subLabelFont
    label.textColor = Color.text.value
    label.numberOfLines = 0
    return label
  }()
  
  let historyContainer: UIView = {
    let view = UIView()
    view.backgroundColor = Color.lightBackground.value
    view.layer.cornerRadius = 3
    return view
  }()
  
  let totalCompletedJobsLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.historyFont
    label.numberOfLines = 1
    label.textColor = Color.text.value
    return label
  }()
  
  let totalEarningsLabel: UILabel = {
    let label = UILabel()
    label.font = Layout.historyFont
    label.numberOfLines = 1
    label.textColor = Color.text.value
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    addListeners()
    selectedMessageIndex = Int.random(in: 0 ..< EmptyOffersCollectionViewCell.emptyMessages.count)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addListeners() {
    NotificationCenter.default.addObserver(self, selector: #selector(onManualFeedRefresh), name: NSNotification.Name.manualFeedRefresh, object: nil)
  }
  
  func setupViews() {
    contentView.addSubview(border1)
    border1.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.height.equalTo(Layout.borderHeight)
      make.left.right.equalToSuperview().inset(Layout.borderInset)
    }
    
    contentView.addSubview(emojiLabel)
    emojiLabel.snp.makeConstraints { (make) in
      make.top.equalTo(border1).offset(Layout.emojiTopMargin)
      make.centerX.equalToSuperview()
    }
    
    contentView.addSubview(mainLabel)
    mainLabel.snp.makeConstraints { (make) in
      make.top.equalTo(emojiLabel.snp.bottom)
      make.centerX.equalToSuperview()
      make.width.lessThanOrEqualTo(Layout.maxContentWidth)
      make.width.lessThanOrEqualTo(contentView).inset(Layout.contentInset)
    }
    
    contentView.addSubview(subLabel)
    subLabel.snp.makeConstraints { (make) in
      make.top.equalTo(mainLabel.snp.bottom).offset(Layout.subLabelTopMargin)
      make.centerX.equalToSuperview()
      make.width.lessThanOrEqualTo(Layout.maxContentWidth)
      make.width.lessThanOrEqualTo(contentView).inset(Layout.contentInset)
    }
    
    historyContainer.addSubview(totalCompletedJobsLabel)
    totalCompletedJobsLabel.snp.makeConstraints { (make) in
      make.top.equalTo(historyContainer).offset(Layout.historyContainerPadding)
      make.centerX.equalTo(historyContainer)
    }
    
    historyContainer.addSubview(totalEarningsLabel)
    totalEarningsLabel.snp.makeConstraints { (make) in
      make.top.equalTo(totalCompletedJobsLabel.snp.bottom).offset(Layout.historyContainerSpacing)
      make.centerX.equalTo(historyContainer)
      make.bottom.equalTo(historyContainer).offset(-Layout.historyContainerPadding)
    }
  }

  func showHistory() {
    contentView.addSubview(historyContainer)
    historyContainer.snp.remakeConstraints { (make) in
      make.top.equalTo(subLabel.snp.bottom).offset(Layout.historyContainerTopMargin)
      make.centerX.equalToSuperview()
      make.width.equalTo(Layout.historyContainerWidth)
    }
    setNeedsUpdateConstraints()
  }
  
  func hideHistory() {
    historyContainer.snp.removeConstraints()
    historyContainer.removeFromSuperview()
    setNeedsUpdateConstraints()
  }
  
  func updateEmptyMessage() {
    var selectedMessage: (String, String, String)
    if EmptyOffersCollectionViewCell.shouldShowFirstTimeMessage(stats: emptyOffersItem?.stats) {
      
      // delay this setting for several seconds so that the first time message is seen
      DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
        Defaults[.shownFirstTimeEmptyOffersMessage] = true
      }

      selectedMessage = EmptyOffersCollectionViewCell.firstTimeMessage
    } else {
        selectedMessage = EmptyOffersCollectionViewCell.emptyMessages[UserManager.shared.selectedEmptyMessageIndex]
    }
    
    emojiLabel.text = selectedMessage.0
    mainLabel.attributedText = selectedMessage.1.localized().lineSpacedAndCentered(Layout.lineSpacing)
    subLabel.attributedText = selectedMessage.2.localized().lineSpacedAndCentered(Layout.lineSpacing)
  }
  
  func updateHistory() {
    if let stats = emptyOffersItem?.stats, EmptyOffersCollectionViewCell.shouldShowHistory(stats: stats) {
      if stats.totalCompletedJobs == 1 {
        totalCompletedJobsLabel.text = "\(stats.totalCompletedJobs)" + " " + "completed job".localized()
      } else {
        totalCompletedJobsLabel.text = "\(stats.totalCompletedJobs)" + " " + "completed jobs".localized()
      }
        totalEarningsLabel.text = "\(stats.totalEarningsMSRString)" + " " + "total".localized()
      showHistory()
    } else {
      hideHistory()
    }
  }
  
  func configure(with emptyOffersItem: EmptyOffersItem) {
    self.emptyOffersItem = emptyOffersItem
    updateEmptyMessage()
    updateHistory()
  }
  
  @objc func onManualFeedRefresh() {
    var newMessageIndex: Int
    repeat {
      newMessageIndex = Int.random(in: 0 ..< EmptyOffersCollectionViewCell.emptyMessages.count)
    } while newMessageIndex == UserManager.shared.selectedEmptyMessageIndex
    UserManager.shared.selectedEmptyMessageIndex = newMessageIndex
    updateEmptyMessage()
    resizingDelegate?.needsResizing()
  }
}
