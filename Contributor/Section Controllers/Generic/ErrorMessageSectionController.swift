//
//  ErrorMessageSectionController.swift
//  Contributor
//
//  Created by John Martin on 5/8/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

protocol ErrorMessageSectionControllerDelegate: class {
  func didTapActionButton()
}

class ErrorMessageSectionController: ListSectionController {
  var message: MessageHolder?
  weak var delegate: ErrorMessageSectionControllerDelegate?

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
    guard let cell = collectionContext?.dequeueReusableCell(of: ErrorMessageCollectionViewCell.self, for: self, at: index) as? ErrorMessageCollectionViewCell else {
      fatalError()
    }
    
    if let message = message {
      cell.configure(with: message)
      cell.delegate = self
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
    let height = ErrorMessageCollectionViewCell.calculateHeightForWidth(message: message, width: width)
    
    return CGSize(width: width, height: height)
  }
}

extension ErrorMessageSectionController: ErrorMessageCollectionViewCellDelegate {
  func didTapActionButton() {
    delegate?.didTapActionButton()
  }
}

class SeperatorViewItemSectionController: ListSectionController {
  var item: SeperatorItem!
    var hideTopBorder = false

  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    item = object as? SeperatorItem
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let ctx = collectionContext else {
        return UICollectionViewCell()
    }
    let nibName = String(describing: SepeatorViewCell.self)
    guard let cell = ctx.dequeueReusableCell(withNibName: nibName , bundle: nil, for: self, at: index) as? SepeatorViewCell else
    { return UICollectionViewCell() }
    if self.hideTopBorder {
        cell.seperatorView.isHidden = true
        cell.seperatorBottomConstraint.constant = 0.0
    } else {
        cell.seperatorView.isHidden = false
        cell.seperatorBottomConstraint.constant = 19.5
    }
    return cell
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    
    let width = context.containerSize.width
    if self.hideTopBorder {
        return CGSize(width: width, height: 22)
    } else {
        return CGSize(width: width, height: 44)
    }
  }
}
