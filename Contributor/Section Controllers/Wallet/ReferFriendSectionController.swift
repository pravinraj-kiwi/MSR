//
//  ReferFriendSectionController.swift
//  Contributor
//
//  Created by John Martin on 7/29/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import IGListKit

class ReferFriendSectionController: ContainerSectionController {
  override func calculateHeightForWidth(width: CGFloat) -> CGFloat {
    return ReferFriendViewController.calculateHeightForWidth(width: width)
  }
}
