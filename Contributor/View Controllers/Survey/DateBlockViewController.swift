//
//  DateBlockViewController.swift
//  Contributor
//
//  Created by arvindh on 07/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit

class DateBlockViewController: BlockViewController, BlockValueContainable {
  typealias ValueType = DateBlockResponse

  struct Layout {
    static var fieldHeight: CGFloat = 58
  }
  
  var textField: MSRTextField = {
    let tf = MSRTextField(frame: CGRect.zero)
    tf.textField.placeholder = Text.enterDate.localized()
    tf.textField.isUserInteractionEnabled = false
    return tf
  }()
  
  let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale.current
    df.dateFormat = "d MMMM',' yyyy"
    df.timeZone = TimeZone.autoupdatingCurrent
    return df
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
    textField.textField.delegate = self
    
    if let value = typedValue, let date = value.value {
      textField.text = dateFormatter.string(from: date)
    }
    
    view.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.showDatePicker(_:)))
    )
  }

  @objc func showDatePicker(_ sender: UITapGestureRecognizer) {
    Router.shared.route(
      to: Route.datePicker(date: typedValue?.value, datePickerMode: UIDatePicker.Mode.date, delegate: self),
      from: self,
      presentationType: PresentationType.custom(presenterType: SemiModalPresenter.self)
    )
  }
}

extension DateBlockViewController: DatePickerDelegate {
  func datePickerDidSelectDate(date: Date?, datePickerMode: UIDatePicker.Mode) {
    if let date = date {
      let dateString = dateFormatter.string(from: date)
      textField.text = dateString
      updateValue(with: date)
    } else {
      textField.text = nil
      updateValue(with: nil)
    }
  }
  
  func updateValue(with date: Date?) {
    if let date = date {
      let newValue = DateBlockResponse()
      newValue.value = date
      value = newValue
    } else {
      value = nil
    }
  }
}

extension DateBlockViewController: UITextFieldDelegate {
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    return true 
  }
}
