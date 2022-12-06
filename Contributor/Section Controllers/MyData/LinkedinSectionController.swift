//
//  LinkedinSectionController.swift
//  Contributor
//
//  Created by KiwiTech on 3/4/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

protocol LinkedinDataSourceDelegate: class {
  func getLinkedinData() -> ConnectedAppData?
  func clickToOpenConnectionDetail(appType: ConnectedApp)
  func clickToCloseAdView(appType: ConnectedApp)
}

class LinkedinSectionController: ListSectionController {
  var message: MessageHolder?
  weak var delegate: LinkedinDataSourceDelegate?

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
    guard let cell = collectionContext?.dequeueReusableCell(of: LinkedinCollectionViewCell.self,
                                                            for: self, at: index) as? LinkedinCollectionViewCell
    else {
      fatalError()
    }
    
    cell.linkedinViewDelegate = self
    if let message = message {
        cell.configure(with: message, adData: delegate?.getLinkedinData())
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
    let height = LinkedinCollectionViewCell.calculateHeightForWidth(message: message,
                                                                    adData: delegate?.getLinkedinData(),
                                                                    width: width)
    return CGSize(width: width, height: height)
  }
}

extension LinkedinSectionController: LinkedinViewDelegate {
    func clickToOpenConnectionScreen(appType: ConnectedApp) {
      delegate?.clickToOpenConnectionDetail(appType: appType)
    }
    func clickToCloseAdView(appType: ConnectedApp) {
      delegate?.clickToCloseAdView(appType: appType)
    }
}
