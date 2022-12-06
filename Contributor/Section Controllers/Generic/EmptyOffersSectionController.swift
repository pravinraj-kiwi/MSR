//
//  EmptyOffersSectionController.swift
//  Contributor
//
//  Created by John Martin on 3/24/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

class EmptyOffersSectionController: ListSectionController {
  var emptyOffersItem: EmptyOffersItem?
  weak var resizingDelegate: ListSectionNeedsResizingDelegate?

  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    emptyOffersItem = object as? EmptyOffersItem
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(of: EmptyOffersCollectionViewCell.self, for: self, at: index) as? EmptyOffersCollectionViewCell else {
      fatalError()
    }
    
    if let emptyOffersItem = emptyOffersItem {
      cell.configure(with: emptyOffersItem)
    }
    cell.resizingDelegate = self

    return cell
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    
    let width = context.containerSize.width
    let height = EmptyOffersCollectionViewCell.calculateHeightForWidth(stats: emptyOffersItem?.stats, width: width)
    
    return CGSize(width: width, height: height)
  }
}

extension EmptyOffersSectionController: ListItemNeedsResizingDelegate {
  func needsResizing() {
    resizingDelegate?.needsResizing()
  }
}
