//
//  ConnectedAppsSectionController.swift
//  Contributor
//
//  Created by KiwiTech on 3/6/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

protocol ConnectedAppsDataSourceDelegate: class {
  func clickToOpenProfileValidations(dataType: ConnectedDataType)
  func clickToOpenPatnersScreen(dataType: ConnectedDataType)
}

class ConnectedAppsSectionController: ListSectionController {
  weak var connectedAppsDelegate: ConnectedAppsDataSourceDelegate?
  var data: [ConnectedAppData]?
    
  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(of: ConnectedAppsCollectionCell.self,
                                                            for: self, at: index) as? ConnectedAppsCollectionCell
    else {
      fatalError()
    }
    cell.connectedViewDelegate = self
    if let data = data {
        cell.updateCellUI(data)
    }
    return cell
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    let width = context.containerSize.width
    return CGSize(width: width, height: 200)
  }
}

extension ConnectedAppsSectionController: ConnectedAppsDelegate {
  func clickToOpenProfileValidations(dataType: ConnectedDataType) {
     connectedAppsDelegate?.clickToOpenProfileValidations(dataType: dataType)
  }

  func clickToOpenPatnersScreen(dataType: ConnectedDataType) {
    connectedAppsDelegate?.clickToOpenPatnersScreen(dataType: dataType)
  }
}
