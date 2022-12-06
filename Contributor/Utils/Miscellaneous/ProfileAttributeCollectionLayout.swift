//
//  ProfileAttributeCollectionLayout.swift
//  Contributor
//
//  Created by KiwiTech on 11/5/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class NBCollectionViewFlowLayout: UICollectionViewFlowLayout {
 let spacing = 10
 open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let answer = super.layoutAttributesForElements(in: rect) else {
        return nil
    }
   let count = answer.count
   for i in 1..<count {
     let currentLayoutAttributes = answer[i]
     let prevLayoutAttributes = answer[i-1]
     let origin = prevLayoutAttributes.frame.maxX
     if (origin + CGFloat(spacing) + currentLayoutAttributes.frame.size.width) < self.collectionViewContentSize.width && currentLayoutAttributes.frame.origin.x > prevLayoutAttributes.frame.origin.x {
        var frame = currentLayoutAttributes.frame
        frame.origin.x = origin + CGFloat(spacing)
        currentLayoutAttributes.frame = frame
      }
    }
   return answer
}

override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
   return true
  }
}
