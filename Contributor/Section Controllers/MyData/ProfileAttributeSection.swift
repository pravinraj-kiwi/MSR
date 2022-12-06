//
//  ProfileAttributeSection.swift
//  Contributor
//
//  Created by KiwiTech on 11/6/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import IGListKit

protocol ProfileAttributeSectionDelegate: class {
  func moveToAttributeList()
}

class ProfileAttributeSection: ListSectionController {

  var profileAttributes: [ProfileAttributeModel] = []
  weak var delegate: ProfileAttributeSectionDelegate?

  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(of: DataProfileAttributesCell.self, for: self,
                                                            at: index) as? DataProfileAttributesCell else {
      fatalError()
    }
    if !profileAttributes.isEmpty {
        cell.delegate = self
        cell.updateView(profileAttributes)
    }
    return cell
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    return CGSize(width: context.containerSize.width, height: 100)
  }
}

extension ProfileAttributeSection: ProfileAttributeCellDelegate {
    func moveToAttributeList() {
        delegate?.moveToAttributeList()
    }
}
