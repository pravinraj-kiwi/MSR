//
//  Tabs.swift
//  Contributor
//
//  Created by arvindh on 12/02/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import UIKit

struct Tabs {
  enum Tab {
    case feed, data, wallet
    
    var route: Route {
      switch self {
      case .feed: return Route.feed
      case .data: return Route.myData
      case .wallet: return Route.wallet
      }
    }
    
    var usesNavigationController: Bool {
      switch self {
      case .feed: return false
      case .data: return false
      case .wallet: return true
      }
    }
    
    var viewController: UIViewController {
      return Router.shared.destinationViewController(for: route)
    }
  }
  
  var order: [Tab] = [Tab.feed, Tab.data, Tab.wallet]
  var viewControllers: [Tab: UIViewController] = [:]
  
  var feedViewController: FeedViewController? {
    return viewControllers[Tab.feed] as? FeedViewController
  }
  var dataViewController: MyDataViewController? {
    return viewControllers[Tab.data] as? MyDataViewController
  }
  var walletViewController: WalletListViewController? {
    return viewControllers[Tab.wallet] as? WalletListViewController
  }
}
