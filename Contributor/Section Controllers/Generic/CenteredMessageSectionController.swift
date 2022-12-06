//
//  CenteredMessageSectionController.swift
//  Contributor
//
//  Created by John Martin on 5/6/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

class CenteredMessageSectionController: ListSectionController {
  var message: MessageHolder?
  
  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    message = object as? MessageHolder
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(of: CenteredMessageCollectionViewCell.self, for: self, at: index) as? CenteredMessageCollectionViewCell else {
      fatalError()
    }
    
    if let message = message {
      cell.configure(with: message)
    }
    
    return cell
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }

    guard let message = message else {
      return CGSize.zero
    }

    let width = context.containerSize.width
    let height = CenteredMessageCollectionViewCell.calculateHeightForWidth(message: message, width: width)
    
    return CGSize(width: width, height: height)
  }
}
