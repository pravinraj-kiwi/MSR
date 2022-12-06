//
//  StackViewController.swift
//  HTTPBot
//
//  Created by arvindh on 18/08/18.
//  Copyright © 2018 Arvindh Sukumar. All rights reserved.
//

import UIKit

protocol ViewStackable {
  var stackViewContainer: StackViewContainer { get set }
}

extension ViewStackable where Self: UIViewController {
  func addStackViewContainer() {
    view.addSubview(stackViewContainer)
    stackViewContainer.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
  }
}

protocol StackViewItem {
  func toViewController() -> UIViewController
}

extension UIView: StackViewItem {
  func toViewController() -> UIViewController {
    return WrapperViewController(view: self)
  }
}

extension UIViewController: StackViewItem {
  func toViewController() -> UIViewController {
    return self
  }
}

class WrapperViewController: UIViewController {
  init(view: UIView) {
    super.init(nibName: nil, bundle: nil)
    self.view = view
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class StackViewController: UIViewController, ViewStackable {
  var stackViewContainer: StackViewContainer = StackViewContainer(frame: CGRect.zero)

  override func viewDidLoad() {
    super.viewDidLoad()

    addStackViewContainer()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func setupViews() {
    view.clipsToBounds = true
    view.backgroundColor = Constants.backgroundColor
    view.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
  }

  func add(_ item: StackViewItem, insets: UIEdgeInsets? = nil, spacing: CGFloat = 0) {
    let viewController = item.toViewController()
    if children.contains(viewController) {
      return
    }

    viewController.willMove(toParent: self)
    stackViewContainer.add(view: viewController.view, insets: insets, spacing: spacing)
    addChild(viewController)
    viewController.didMove(toParent: self)
  }

  func remove(_ item: StackViewItem) {
    let viewController = item.toViewController()
    guard children.contains(viewController) else {
      return
    }

    viewController.willMove(toParent: nil)
    stackViewContainer.remove(view: viewController.view)
    viewController.removeFromParent()
  }
}
