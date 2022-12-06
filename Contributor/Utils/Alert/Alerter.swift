//
//  Alerter.swift
//  Contributor
//
//  Created by arvindh on 22/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class Alerter: NSObject {
  var viewController: UIViewController
  
  init(viewController: UIViewController) {
    self.viewController = viewController
    super.init()
  }
  
  func alert(
    title: String,
    message: String,
    confirmButtonTitle: String?,
    cancelButtonTitle: String,
    confirmButtonStyle: UIAlertAction.Style = .default,
    cancelButtonStyle: UIAlertAction.Style = .cancel,
    onConfirm: (() -> Void)?,
    onCancel: (() -> Void)?
    ) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
    if let confirmButtonTitle = confirmButtonTitle {
      let confirmAction = UIAlertAction(title: confirmButtonTitle, style: confirmButtonStyle, handler: { _ in
        onConfirm?()
      })
      alert.addAction(confirmAction)
      alert.preferredAction = confirmAction
    }
    
    alert.addAction(UIAlertAction(title: cancelButtonTitle, style: cancelButtonStyle, handler: { _ in
      onCancel?()
    }))
    
    viewController.present(alert, animated: true, completion: nil)
  }
  
  func alert(
    messageHolder: MessageHolder,
    confirmButtonTitle: String?,
    cancelButtonTitle: String,
    onConfirm: (() -> Void)?,
    onCancel: (() -> Void)?
    ) {
    self.alert(
      title: messageHolder.title ?? "",
      message: messageHolder.detail ?? "",
      confirmButtonTitle: confirmButtonTitle,
      cancelButtonTitle: cancelButtonTitle,
      onConfirm: onConfirm,
      onCancel: onCancel
    )
  }
}
