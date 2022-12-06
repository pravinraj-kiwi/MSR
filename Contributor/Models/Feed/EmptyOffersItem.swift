//
//  EmptyOffersItem.swift
//  Contributor
//
//  Created by John Martin on 5/13/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import IGListKit

class EmptyOffersItem: NSObject {
  var stats: UserStats?

  init(stats: UserStats?) {
    self.stats = stats
    super.init()
  }
  
  public override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let rhs = object as? EmptyOffersItem else {
      return false
    }
    
    if stats != rhs.stats {
      return false
    }
    
    return true
  }
}
