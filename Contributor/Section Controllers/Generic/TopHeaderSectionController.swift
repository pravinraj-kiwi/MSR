//
//  TopFeedHeaderSectionController.swift
//  Contributor
//
//  Created by John Martin on 3/25/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

protocol TopHeaderSectionControllerDelegate: class {
  func didTapSettingsButton()
}

class TopHeaderSectionController: ListSectionController {
  var topHeaderItem: TopHeaderItem?
  weak var delegate: TopHeaderSectionControllerDelegate?

  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    topHeaderItem = object as? TopHeaderItem
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let topHeaderItem = topHeaderItem else {
      fatalError()
    }
    
    guard let cell = collectionContext?.dequeueReusableCell(of: TopHeaderViewCell.self, for: self, at: index) as? TopHeaderViewCell else {
      fatalError()
    }
    
    cell.configure(with: topHeaderItem)
    cell.delegate = self
    
    return cell
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    
    return CGSize(width: context.containerSize.width, height: 97)
  }
}

extension TopHeaderSectionController: TopHeaderCollectionViewCellDelegate {
  func didTapSettingsButton() {
    delegate?.didTapSettingsButton()
  }
}
