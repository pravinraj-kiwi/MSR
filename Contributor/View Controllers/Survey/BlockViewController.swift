//
//  BlockViewController.swift
//  Contributor
//
//  Created by arvindh on 30/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

protocol BlockValueContainable {
  associatedtype ValueType: BlockResponseComponent
  var typedValue: ValueType? {get}
  var value: BlockResponseComponent? {get set}
  
  func didUpdateValue()
}

extension BlockValueContainable {
  var typedValue: ValueType? {
    return value as? ValueType
  }
}

class BlockViewController: UIViewController {
  var block: SurveyBlock
  var value: BlockResponseComponent? {
    didSet {
      didUpdateValue()
    }
  }
  
  fileprivate weak var containerViewController: BlockContainerViewController?
  
  init(block: SurveyBlock, value: BlockResponseComponent? = nil) {
    self.block = block
    self.value = value
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func didUpdateValue() {
    containerViewController?.didUpdateValue(value, forBlock: block)
  }  
}

protocol BlockContainerDelegate: class {
  func didUpdateValue(_ value: BlockResponseComponent?, forBlock block: SurveyBlock)
}

enum BlockContainerError: Error {
  case widgetNotSupported
}

class BlockContainerViewController: StackViewController {
  weak var delegate: BlockContainerDelegate?
  
  var block: SurveyBlock
  var blockViewController: BlockViewController!
  var value: BlockResponseComponent? {
    didSet {
      delegate?.didUpdateValue(value, forBlock: block)
    }
  }
  
  var titleView: UILabel!
  
  init(block: SurveyBlock) {
    self.block = block
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }

  func setupQuestionViewController() throws {
    guard let widget = block.widgetTypeString, let widgetType = BlockType(rawValue: widget) else {
      throw BlockContainerError.widgetNotSupported
    }
    
    var controller: BlockViewController?
    switch widgetType {
    case .radio:
      let radioBlockViewController = RadioBlockViewController(block: block, value: value)
      radioBlockViewController.options = block.choices ?? []
      controller = radioBlockViewController
    case .checkbox:
      let checkboxBlockViewController = CheckboxBlockViewController(block: block, value: value)
      checkboxBlockViewController.options = block.choices ?? []
      controller = checkboxBlockViewController
    case .singleLineText:
      let blockViewController = SingleLineTextBlockViewController(block: block, value: value)
      controller = blockViewController
    case .date:
      let blockViewController = DateBlockViewController(block: block, value: value)
      controller = blockViewController
    }
    
    blockViewController = controller
    blockViewController.value = value
    blockViewController.containerViewController = self
  }
  
  func setupTitleView() {
    titleView = UILabel()
    titleView.numberOfLines = 0
    titleView.font = Font.semiBold.of(size: 18)
    titleView.backgroundColor = Constants.backgroundColor
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        if let question = block.questionPt {
          titleView.attributedText = question.lineSpaced(1.2)
        } else {
            if let question = block.question {
              titleView.attributedText = question.lineSpaced(1.2)
            }
        }
    } else {
        if let question = block.question {
          titleView.attributedText = question.lineSpaced(1.2)
        }
    }
    titleView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    titleView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
  }
  
  override func setupViews() {
    do {
      setupTitleView()
      add(
        titleView,
        insets: UIEdgeInsets(top: 0, left: 26, bottom: 10, right: 26),
        spacing: 10
      )
      
      try setupQuestionViewController()
      let questionControllerWrapper = CardContainerViewController(contentViewController: blockViewController)
      questionControllerWrapper.container.cornerRadius = 2
      questionControllerWrapper.insets = UIEdgeInsets.zero
      
      add(
        questionControllerWrapper,
        insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15),
        spacing: 0
      )
    }
    catch {
      print(error)
    }
  }
  
  func didUpdateValue(_ value: BlockResponseComponent?, forBlock block: SurveyBlock) {
    self.value = value
  }
}
