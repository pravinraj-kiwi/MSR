//
//  OnboardingItemSectionController.swift
//  Contributor
//
//  Created by John Martin on 5/14/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

protocol ListSectionNeedsResizingDelegate: class {
  func needsResizing()
}

protocol OnboardingItemSectionControllerDelegate: class {
  func didTapStartPhoneNumberSurveyButton()
  func didTapStartBasicProfileSurveyButton()
  func didTapStartLocationValidationButton()
  func didTapContactSupportButton()
}

class OnboardingItemSectionController: ListSectionController {
  var item: OnboardingItem!
  weak var onboardingItemDelegate: OnboardingItemSectionControllerDelegate?
  weak var resizingDelegate: ListSectionNeedsResizingDelegate?
  
  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    item = object as? OnboardingItem
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(of: OnboardingItemCollectionViewCell.self,
                                                            for: self, at: index) as? OnboardingItemCollectionViewCell
    else {
      fatalError()
    }
    
    cell.configure(with: item)
    cell.onboardingItemDelegate = self
    cell.resizingDelegate = self
    return cell
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    
    let width = context.containerSize.width
    let height = OnboardingItemCollectionViewCell.calculateHeightForWidth(item: item, width: width)
    return CGSize(width: width, height: height)
  }
}

extension OnboardingItemSectionController: OnboardingItemCollectionViewCellDelegate {
   func didTapContactSupportButton() {
    onboardingItemDelegate?.didTapContactSupportButton()
   }
    
   func didTapStartPhoneNumberSurveyButton() {
    onboardingItemDelegate?.didTapStartPhoneNumberSurveyButton()
  }
    
  func didTapStartLocationValidationButton() {
    onboardingItemDelegate?.didTapStartLocationValidationButton()
  }
  
  func didTapStartBasicProfileSurveyButton() {
    onboardingItemDelegate?.didTapStartBasicProfileSurveyButton()
  }
}

extension OnboardingItemSectionController: ListItemNeedsResizingDelegate {
  func needsResizing() {
    resizingDelegate?.needsResizing()
  }
}
