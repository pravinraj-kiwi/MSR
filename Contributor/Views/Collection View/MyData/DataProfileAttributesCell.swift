//
//  DataProfileAttributes.swift
//  Contributor
//
//  Created by KiwiTech on 11/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import IGListKit

protocol ProfileAttributeCellDelegate: class {
  func moveToAttributeList()
}

class DataProfileAttributesCell: UICollectionViewCell {
    
struct Layout {
  static let collectionViewInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  static let borderHeight: CGFloat = 1
}

let generator = UIImpactFeedbackGenerator(style: .light)
var dataSourceArray = [ProfileAttributeListModel]()
var attributes: [ProfileAttributeModel]? = []
var activeColor: UIColor?
weak var delegate: ProfileAttributeCellDelegate?
    
let border: UIView = {
   let view = UIView()
   view.backgroundColor = Color.lightBorder.value
   return view
}()
  
let profileAttributeLabel: UILabel = {
   let label = UILabel()
    label.text = ProfileAttributeText.myAttributesText.localized()
   label.textColor = .black
   label.font = Font.bold.of(size: 24)
   label.numberOfLines = 0
   return label
}()
  
let profileSubAttributeLabel: UILabel = {
   let label = UILabel()
   label.text = ProfileAttributeText.myAttributeSubText.localized()
   label.textColor = .black
   label.font = Font.regular.of(size: 16)
   label.lineBreakMode = .byWordWrapping
   label.numberOfLines = 0
   return label
}()
    
let stackView: UIStackView = {
  let stackView = UIStackView(frame: CGRect.zero)
  stackView.axis = .vertical
  stackView.alignment = .fill
  return stackView
}()
 
let collectionView: DynamicHeightCollectionView = {
  let layout = NBCollectionViewFlowLayout()
  layout.scrollDirection = .vertical
  layout.minimumInteritemSpacing = 10
  layout.minimumLineSpacing = 10
  let cv = DynamicHeightCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
  cv.register(DataProfileAttributeCollectionCell.self,
              forCellWithReuseIdentifier: CellIdentifier.attributeCell.rawValue)
  cv.backgroundColor = Constants.backgroundColor
  cv.isScrollEnabled = false
  cv.showsVerticalScrollIndicator = false
  cv.alwaysBounceHorizontal = true
  cv.collectionViewLayout = layout
  return cv
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
    NotificationCenter.default.addObserver(self, selector: #selector(updateMyAttributeCell(_:)),
                                         name: NSNotification.Name.updateAttributeCell, object: nil)
}

func setupViews() {
 contentView.addSubview(border)
 contentView.addSubview(profileAttributeLabel)
 contentView.addSubview(profileSubAttributeLabel)
 contentView.addSubview(stackView)
 stackView.addArrangedSubview(collectionView)
    
 let contentWidth = contentView.frame.width - Layout.collectionViewInset.left - Layout.collectionViewInset.right

 border.snp.makeConstraints { (make) in
   make.top.equalTo(contentView)
   make.height.equalTo(Layout.borderHeight)
   make.width.equalTo(contentWidth)
   make.left.equalTo(contentView).offset(22)
   make.right.equalTo(contentView).offset(-22)
 }

 profileAttributeLabel.snp.makeConstraints { (make) in
   make.top.equalTo(border.snp.bottom).offset(10)
   make.left.equalTo(contentView).offset(22)
   make.right.equalTo(contentView).offset(-22)
 }

 profileSubAttributeLabel.snp.makeConstraints { (make) in
   make.top.equalTo(profileAttributeLabel.snp.bottom).offset(5)
   make.left.equalTo(contentView).offset(22)
   make.right.equalTo(contentView).offset(-22)
 }
    
 stackView.snp.makeConstraints { (make) in
    make.top.equalTo(profileSubAttributeLabel.snp.bottom).offset(17)
    make.bottom.equalTo(contentView).offset(-30)
    make.left.equalTo(contentView).offset(22)
    make.right.equalTo(contentView).offset(-22)
 }
    
 collectionView.snp.makeConstraints { (make) in
   make.top.equalTo(stackView)
   make.bottom.equalTo(stackView)
   make.left.equalTo(stackView)
   make.right.equalTo(stackView)
  }
    
  applyCommunityTheme()
  dataSourceArray.reserveCapacity(4)
  collectionView.dataSource = self
  collectionView.delegate = self
}
    
func updateView(_ attribute: [ProfileAttributeModel]) {
  dataSourceArray.removeAll()
  ProfileAttributes().mapProfileItems(attribute) { (matchedAttributes) in
    let answersData = matchedAttributes.filter({$0.profileMultiAnswers.isEmpty == false})
    dataSourceArray = Array(answersData.prefix(4))
    collectionView.reloadData()
    collectionView.layoutIfNeeded()
  }
}
    
@objc func updateMyAttributeCell(_ notification: Notification) {
    if let object = notification.object as? [ProfileAttributeModel],
       !object.isEmpty {
        updateView(object)
    }
  }
}

extension DataProfileAttributesCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  if dataSourceArray.isEmpty == false {
    return dataSourceArray.count + 1
  }
  return 0
}
  
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  let cellIdentifier = CellIdentifier.attributeCell.rawValue
  guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                        for: indexPath) as? DataProfileAttributeCollectionCell else {
    fatalError()
  }
    updateCell(indexPath, cell)
    return cell
}

func updateCell(_ indexPath: IndexPath, _ cell: DataProfileAttributeCollectionCell) {
 if indexPath.row < dataSourceArray.count,
   dataSourceArray.isEmpty == false {
   let data = dataSourceArray[indexPath.row]
   if data.profileMultiAnswers.isEmpty == false {
     cell.titleLabel.text = data.profileMultiAnswers[0].uppercased()
   }
   cell.backgroundColor = activeColor
   cell.titleLabel.textColor = .white
 } else {
   let count = getCount() - dataSourceArray.count
   cell.titleLabel.text = "+ \(count) \(Text.moreText.localized())"
   cell.backgroundColor = .clear
   cell.titleLabel.textColor = activeColor
   cell.layer.borderWidth = 1
   cell.layer.borderColor = activeColor?.cgColor
 }
}
    
func getMultiProfileItems() -> Int {
  var count = 0
    if let profileStore = UserManager.shared.profileStore {
        for profile in profileStore.values {
            if let _ = profileStore.values[profile.key] as? String {
                count+=1
            }
            if let multiValue = profileStore.values[profile.key] as? [String] {
                count+=multiValue.count
            }
        }
    }
    return count
}
    
func getCount() -> Int {
 var count = getMultiProfileItems()
 if let profileStore = UserManager.shared.profileStore {
    for extraItems in MyAttributes.extraProfileItems {
        if profileStore.values.contains(where: {$0.key == extraItems}) {
            count-=1
       }
    }
 }
 return count
}
  
func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    sizeForItemAt indexPath: IndexPath) -> CGSize {
  if indexPath.row < dataSourceArray.count,
     dataSourceArray.isEmpty == false {
    let item = dataSourceArray[indexPath.row]
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    let size = CGSize(width: 250, height: 1500)
    let estimatedFrame = NSString(string: item.profileMultiAnswers[0]).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: Font.semiBold.of(size: 11)], context: nil)
    return CGSize(width: estimatedFrame.width + 50, height: 32)
  }
  if let profileStore = UserManager.shared.profileStore {
    let count = profileStore.values.count - dataSourceArray.count
    let textWidth = "+ \(count) \(Text.moreText.localized())".width(usingFont: Font.semiBold.of(size: 11)) + 40
    return CGSize(width: textWidth, height: 32)
  }
  return CGSize(width: 0, height: 0)
}
    
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.row < dataSourceArray.count {
        return
    }
    delegate?.moveToAttributeList()
  }
}

extension DataProfileAttributesCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity,
          let colors = community.colors else {
      return
    }
    activeColor = colors.primary
  }
}
