//
//  RoundedStoriesItemSectionController.swift
//  Contributor
//
//  Created by Shashi Kumar on 20/05/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit

protocol RoundedStoriesSectionControllerDelegate: class {
    func didSelectStoryOfferItem(_ item: Story, indexPath: Int)
    func markStoryOfferItemAsSeen(_ item: Story, indexPath: Int)
}

class RoundedStoriesSectionController: ListSectionController {
  var item: StoryListItem!
  weak var delegate: RoundedStoriesSectionControllerDelegate?
  var selectedIndex = 0
  var selectedStory: Story?
  var hideTopBorder = false

  override init() {
    super.init()
    self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  override func didUpdate(to object: Any) {
    item = object as? StoryListItem
  }
  
  override func numberOfItems() -> Int {
    return 1
  }
  
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let ctx = collectionContext else {
            return UICollectionViewCell()
        }
        let nibName = String(describing: StoryCell.self)
        guard let cell = ctx.dequeueReusableCell(withNibName: nibName , bundle: nil, for: self, at: index) as? StoryCell else
        { return UICollectionViewCell() }
        
        debugPrint("Story item selected")
        
        cell.feedItem = item.stories ?? []
        cell.selectedStory = self.selectedStory
        //cell.feedItem = object
        cell.delegate = self
        cell.contentView.backgroundColor = .white
        
        if self.selectedIndex > -1 {
            cell.seperatorView.isHidden = true
           // DispatchQueue.main.async {
                cell.collectionView.scrollToItem(at: IndexPath(item: self.selectedIndex,
                                                               section: 0),
                                                 at: [.centeredVertically, .centeredHorizontally],
                                                 animated: false)


           // }
        } else {
            if self.hideTopBorder {
                cell.seperatorView.isHidden = true
                cell.seperatorBottomConstraint.constant = 0.0
            } else {
                cell.seperatorView.isHidden = false
                cell.seperatorBottomConstraint.constant = 19.5
            }
        }
        cell.collectionView.reloadData()

        return cell
        
    }
  override func didSelectItem(at index: Int) {
   // delegate?.didSelectOfferItem(item.item)
  }
  
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else {
      return CGSize.zero
    }
    let width = context.containerSize.width
    return CGSize(width: width, height: 148)

  }
}
extension RoundedStoriesSectionController: StoryCellDelegate {
    func didSelectContentOfferItem(_ item: Story,
                                   indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        delegate?.didSelectStoryOfferItem(item, indexPath: indexPath.row)

    }
    func currentVisibleStoryItem(_ item: Story,
                                 indexPath: IndexPath) {
        delegate?.markStoryOfferItemAsSeen(item, indexPath: indexPath.row)
    }
}
