//
//  DataToggleSectionController.swift
//  Contributor
//
//  Created by arvindh on 13/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import IGListKit

class DataSourceToggleSectionController: ListSectionController {
  var itemsHolder: DataSourceHolder?
  
  override init() {
    super.init()
  }
  
  override func didUpdate(to object: Any) {
    self.itemsHolder = object as? DataSourceHolder
  }
  
  override func numberOfItems() -> Int {
    return itemsHolder?.items.count ?? 0
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(of: DataSourceToggleCollectionViewCell.self, for: self, at: index) as? DataSourceToggleCollectionViewCell else {
      fatalError()
    }
    
    if let item = itemsHolder?.items[index] {
      cell.configure(with: item)
    }
    
    cell.toggleSwitch.tag = index
    cell.toggleSwitch.addTarget(self, action: #selector(self.toggleStatus(_:)), for: UIControl.Event.valueChanged)
    
    return cell
  }
  
  @objc func toggleStatus(_ sender: UISwitch) {
    guard let item = itemsHolder?.items[sender.tag] else {
      return
    }
    
    UserManager.shared.toggle(dataSource: item) { (error) in
      if let _ = error {
        // Revert
        sender.isOn = !sender.isOn
      }
      else {
        if sender.isOn {
          let alerter = Alerter(viewController: self.viewController!)
          alerter.alert(title: item.title, message: "Thank you for your interest. This feature is not released yet but when it is the app will alert you and walk you through the required configuration steps.", confirmButtonTitle: nil, cancelButtonTitle: "OK", onConfirm: nil, onCancel: nil)
        }
      }
    }
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    
    return CGSize(width: context.containerSize.width, height: 150)
  }
  
  func supportedElementKinds() -> [String] {
    return [UICollectionView.elementKindSectionHeader]
  }
}
