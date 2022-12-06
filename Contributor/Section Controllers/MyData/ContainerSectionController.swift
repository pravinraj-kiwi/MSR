//
//  ContainerSectionController.swift
//  Contributor
//
//  Created by arvindh on 18/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import IGListKit

class ContainerSectionController: ListSectionController {
  var contentViewController: UIViewController!
  
  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    contentViewController = object as? UIViewController
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    
    let width = context.containerSize.width
    let height = calculateHeightForWidth(width: width)
    return CGSize(width: width, height: height)
  }
  
  func calculateHeightForWidth(width: CGFloat) -> CGFloat {
    return 240 // default
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(of: ContainerCollectionViewCell.self, for: self, at: index) as? ContainerCollectionViewCell else {
      fatalError()
    }
    
    contentViewController.willMove(toParent: viewController)
    viewController?.addChild(contentViewController)
    cell.add(contentViewController: contentViewController)
    contentViewController.didMove(toParent: viewController)
    
    return cell
  }
}
