//
//  GiftCardsSectionController.swift
//  Contributor
//
//  Created by arvindh on 16/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import IGListKit
import Kingfisher

class GiftCardsSectionController: ListSectionController {
  var itemsHolder: GiftCardHolder?
  
  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
    self.minimumLineSpacing = 10
  }
  
  override func didUpdate(to object: Any) {
    self.itemsHolder = object as? GiftCardHolder
  }
  
  override func numberOfItems() -> Int {
    return itemsHolder?.items.count ?? 0
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(of: GiftCardCollectionViewCell.self, for: self, at: index) as? GiftCardCollectionViewCell else {
      fatalError()
    }
    
    guard let giftCard = itemsHolder?.items[index] else {
      fatalError()
    }
    
    if let urlString = giftCard.images?.card, let url = URL(string: urlString) {
      cell.imageView.kf.setImage(with: url)
    }
    else {
      cell.imageView.image = nil
    }
    
    cell.configure(with: giftCard, options: giftCard.redeemOptions)
    
    return cell
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    
    let numberOfColumns: CGFloat = 2
    let itemMargin: CGFloat = 10
    let width = (context.containerSize.width - (itemMargin * (numberOfColumns + 1)))/2
    return CGSize(width: width, height: 170)
  }
}
