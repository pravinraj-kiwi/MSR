//
//  OfferItemSectionController.swift
//  Contributor
//
//  Created by John Martin on 5/3/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

protocol OfferItemSectionControllerDelegate: class {
  func didSelectOfferItem(_ item: OfferItem)
}

class OfferItemSectionController: ListSectionController {
  var item: FeedItem!
  weak var delegate: OfferItemSectionControllerDelegate?
  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    item = object as? FeedItem
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: OfferItemCollectionViewCell.self, for: self, at: index) as? OfferItemCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: item.item)
        return cell
    }
  
  override func didSelectItem(at index: Int) {
    delegate?.didSelectOfferItem(item.item)
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    let width = context.containerSize.width
    let height = OfferItemCollectionViewCell.calculateHeightForWidth(item: item.item, width: width)
    return CGSize(width: width, height: height)
  }
}
