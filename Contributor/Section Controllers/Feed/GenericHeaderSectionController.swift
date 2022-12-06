//
//  GenericFeedHeaderSectionController.swift
//  Contributor
//
//  Created by John Martin on 3/24/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

class GenericHeaderSectionController: ListSectionController {
  var item: GenericHeaderItem?
  
  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    item = object as? GenericHeaderItem
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let headerItem = item else {
      fatalError()
    }
    
    guard let cell = collectionContext?.dequeueReusableCell(of: GenericHeaderCollectionViewCell.self, for: self, at: index) as? GenericHeaderCollectionViewCell else {
      fatalError()
    }
    
    cell.configure(with: headerItem)
    
    return cell
  }
    
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    
    return CGSize(width: context.containerSize.width, height: 73)
  }
}
