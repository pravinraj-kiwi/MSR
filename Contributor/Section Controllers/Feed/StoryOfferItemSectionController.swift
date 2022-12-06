//
//  StoryOfferItemSectionController.swift
//  Contributor
//
//  Created by Shashi Kumar on 20/05/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import Foundation
import os
import UIKit
import IGListKit

protocol StoryOfferItemSectionControllerDelegate: class {
  func didSelectStoryItemLink(_ link: Link)
    func didSelectCloseOffer()
    func navigateToExternalBrowser(url: URL?)
}

class StoryOfferItemSectionController: ListSectionController {
  var item: StoryWithContentItem!
  weak var delegate: StoryOfferItemSectionControllerDelegate?
  
  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    item = object as? StoryWithContentItem
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
//    let nibName = String(describing: StoryContentOfferCell.self)
//    guard let cell = collectionContext?.dequeueReusableCell(withNibName: nibName , bundle: nil, for: self, at: index) as? StoryContentOfferCell else
//    { return UICollectionViewCell() }
    guard let story = item.item else {return UICollectionViewCell()}

    if let storyType = story.itemType {
        if (storyType == "content-external-html" || storyType == "content-inline-html") {
            guard let cell = collectionContext?.dequeueReusableCell(of: ContentOfferHTMLCollectionViewCell.self, for: self, at: index) as? ContentOfferHTMLCollectionViewCell else {
              fatalError()
            }
            cell.delegate = self
            cell.styleUI()
            DispatchQueue.main.async {
                cell.configure(with: story)
            }
            return cell
        } else {
            guard let cell = collectionContext?.dequeueReusableCell(of: ContentOfferItemCollectionViewCell.self, for: self, at: index) as? ContentOfferItemCollectionViewCell else {
              fatalError()
            }
            cell.delegate = self
            cell.styleUI()
            DispatchQueue.main.async {
                cell.configure(with: story)
            }
            return cell
        }
    }
    return UICollectionViewCell()
  }
  
  override func didSelectItem(at index: Int) {
   // delegate?.didSelectContentItem(item)
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    guard let story = item.item else {return .zero}

    let width = context.containerSize.width
    
    let height = ContentOfferItemCollectionViewCell.calculateHeightForWidth(item: item.item, width: width)
    if let storyType = story.itemType {
        if (storyType == "content-external-html" || storyType == "content-inline-html") {
            let height = ContentOfferHTMLCollectionViewCell.calculateHeightForWidth(item: item.item, width: width)

            return CGSize(width: width, height: height)

        }
        return CGSize(width: width, height: height)
    }
    return .zero

  }
    static func calculateImageHeight(width: CGFloat, widthRatio: CGFloat, heightRatio: CGFloat) -> CGFloat {
      return width * heightRatio / widthRatio
    }
}
extension StoryOfferItemSectionController: ContentOfferItemCellDelegate {
    func closeContentOffer() {
        delegate?.didSelectCloseOffer()

    }
    
    func didSelectContentOfferLink(_ link: Link) {
        debugPrint("Selected link is ", link)
        delegate?.didSelectStoryItemLink(link)
    }
}
extension StoryOfferItemSectionController: ContentOfferHTMLCellDelegate {
    func navigateWebLinks(url: URL?) {
        delegate?.navigateToExternalBrowser(url: url)
    }
    
    func closeOffer() {
        delegate?.didSelectCloseOffer()
    }
}
