//
//  SingleLineTextBlockViewController.swift
//  Contributor
//
//  Created by arvindh on 06/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class SingleLineTextBlockViewController: BlockViewController, BlockValueContainable {
  typealias ValueType = SingleLineTextBlockResponse
  struct Layout {
    static var fieldHeight: CGFloat = 58
  }
  
  var textField: MSRTextField = {
    let tf = MSRTextField(frame: CGRect.zero)
    tf.textField.placeholder = Text.enterValue.localized()
    tf.textField.autocorrectionType = .no
    tf.textField.autocapitalizationType = .allCharacters  // this should not be hardcoded!
    return tf
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupViews()
  }

  override func setupViews() {
    view.addSubview(textField)
    textField.snp.makeConstraints { (make) in
      make.edges.equalTo(view)
      make.height.equalTo(Layout.fieldHeight)
    }
    
    textField.onTextChange = {
      [weak self] tf, text in
      guard let this = self else {
        return
      }
      
      if let text = text {
        let newValue = SingleLineTextBlockResponse()
        newValue.value = text
        this.value = newValue
      } else {
        this.value = nil
      }
    }
    
    if let value = typedValue {
      textField.text = value.value
    }
    
    if let exampleText = block.exampleText {
      textField.textField.placeholder = exampleText
    }
  }
}
