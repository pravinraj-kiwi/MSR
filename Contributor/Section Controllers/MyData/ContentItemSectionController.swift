//
//  ContentSectionController.swift
//  Contributor
//
//  Created by John Martin on 3/22/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

protocol ContentItemSectionControllerDelegate: class {
  func didSelectContentItem(_ item: ContentItem)
}

class ContentItemSectionController: ListSectionController {
  var item: ContentItem!
  weak var delegate: ContentItemSectionControllerDelegate?
  
  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    item = object as? ContentItem
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(of: ContentItemCollectionViewCell.self, for: self, at: index) as? ContentItemCollectionViewCell else {
      fatalError()
    }
    
    cell.configure(with: item)
    
    return cell
  }
  
  override func didSelectItem(at index: Int) {
    delegate?.didSelectContentItem(item)
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    
    let width = context.containerSize.width
    let height = ContentItemCollectionViewCell.calculateHeightForWidth(item: item, width: width)
    
    return CGSize(width: width, height: height)
  }
}
