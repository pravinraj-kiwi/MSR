//
//  MyDataHeaderSectionController.swift
//  Contributor
//
//  Created by KiwiTech on 6/17/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

protocol MyDataHeaderSectionDelegate: class {
    func getUpdatedData() -> [StatTiles]
}

class MyDataHeaderSectionController: ListSectionController {
 var categoryData: Category?
    
override init() {
  super.init()
  self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
}
    
override func numberOfItems() -> Int {
    if let data = categoryData?.statTiles {
        return data.count
    }
  return 0
}

override func cellForItem(at index: Int) -> UICollectionViewCell {
  guard let cell = collectionContext?.dequeueReusableCell(of: MyDataHeaderCollectionViewCell.self,
                                                          for: self, at: index) as? MyDataHeaderCollectionViewCell
  else {
    fatalError()
  }
  cell.index = index
  if let data = categoryData?.statTiles?[index] {
    cell.updateCellUI(animate: false, statsData: data)
  }
  return cell
}

override func sizeForItem(at index: Int) -> CGSize {
  guard let context = collectionContext else {
    return CGSize.zero
  }
  let width = context.containerSize.width
  return CGSize(width: width, height: 89)
}
    
func supportedElementKinds() -> [String] {
    return [UICollectionView.elementKindSectionHeader]
  }
}
