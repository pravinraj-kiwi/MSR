//
//  CopyLabel.swift
//  Contributor
//
//  Created by KiwiTech on 10/27/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol CopyLabelDelegate: class {
  func showCopiedAlert()
}

class CopyLabel: UILabel {
 weak var delegate: CopyLabelDelegate?
 override public var canBecomeFirstResponder: Bool {
    get {
        return true
    }
 }

 override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
 }

 required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
     setup()
 }

 func setup() {
    isUserInteractionEnabled = true
    addGestureRecognizer(UILongPressGestureRecognizer(
        target: self,
        action: #selector(showCopyMenu(sender:))
    ))
 }

 override func copy(_ sender: Any?) {
    UIPasteboard.general.string = text
    UIMenuController.shared.hideMenu()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.delegate?.showCopiedAlert()
    }
 }

 @objc func showCopyMenu(sender: Any?) {
    becomeFirstResponder()
    let menu = UIMenuController.shared
    if !menu.isMenuVisible {
        menu.showMenu(from: self, rect: bounds)
    }
 }

 override func canPerformAction(_ action: Selector,
                                withSender sender: Any?) -> Bool {
    return (action == #selector(copy(_:)))
 }
}
