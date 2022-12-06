//
//  Tabbable.swift
//  Contributor
//
//  Created by arvindh on 05/09/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import Foundation

protocol Tabbable: class {
  var tabName: String {get}
  var tabImage: Image {get}
  var tabHighlightedImage: Image {get}
}
