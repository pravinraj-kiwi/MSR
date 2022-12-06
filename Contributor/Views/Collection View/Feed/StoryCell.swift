//
//  StoryCell.swift
//  Contributor
//
//  Created by Shashi Kumar on 29/04/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit
protocol StoryCellDelegate: class {
    func didSelectContentOfferItem(_ item: Story, indexPath: IndexPath)
    func currentVisibleStoryItem(_ item: Story, indexPath: IndexPath)
}
class StoryCell: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var seperatorView: UIView!
    var feedItem = [Story]()
    weak var delegate: StoryCellDelegate?
    var selectedStory: Story?

    @IBOutlet weak var seperatorBottomConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      updateInitialCollection()
       
    }
   
    func updateInitialCollection() {
        self.collectionView.register(RoundedStoryCell.self, forCellWithReuseIdentifier: "RoundedStoryCell")

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 75,
                                     height: 130)
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 8.0;
        self.collectionView.contentInset.left = 20.0
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .white
        self.seperatorView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)
    }
    var isTouched: Bool = false {
      didSet {
        var transform = CGAffineTransform.identity
        if isTouched { transform = transform.scaledBy(x: CardLayout.touchScaleFactor, y: CardLayout.touchScaleFactor) }
        UIView.animate(withDuration: CardLayout.touchAnimationDuration, delay: CardLayout.touchAnimationDelay, usingSpringWithDamping: CardLayout.touchAnimationSpringDamping, initialSpringVelocity: CardLayout.touchAnimationInitialSpringVelocity, options: [], animations: {
          self.transform = transform
        }, completion: nil)
      }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      isTouched = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      isTouched = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesCancelled(touches, with: event)
      isTouched = false
    }
}
extension StoryCell : UICollectionViewDelegate,
                      UICollectionViewDataSource,
                      UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        feedItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoundedStoryCell", for: indexPath) as? RoundedStoryCell
        else {
          fatalError()
        }
        cell.composeUI(index: indexPath,
                       storyitem: feedItem[indexPath.row],
                       selectedStory: self.selectedStory)
        cell.contentView.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectContentOfferItem(self.feedItem[indexPath.row], indexPath: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        debugPrint("The visible index path is ", indexPath.row)
        delegate?.currentVisibleStoryItem(self.feedItem[indexPath.row], indexPath: indexPath)
    }
}
