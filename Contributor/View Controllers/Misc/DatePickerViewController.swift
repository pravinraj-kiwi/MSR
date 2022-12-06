//
//  DatePickerViewController.swift
//  Pods
//
//  Created by Arvindh Sukumar on 18/07/16.
//
//

import UIKit

protocol DatePickerDelegate: class {
  func datePickerDidSelectDate(date: Date?, datePickerMode: UIDatePicker.Mode)
}

class DatePickerViewController: UIViewController {
  weak var delegate: DatePickerDelegate?
  var date: Date?
  var datePickerMode: UIDatePicker.Mode = .date
    
  let datePicker: UIDatePicker = {
    let dp = UIDatePicker(frame: CGRect.zero)
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        dp.locale = Locale.init(identifier: "pt_BR" )
    } else {
        dp.locale = Locale.init(identifier: "en" )
    }
    dp.timeZone = TimeZone.current
    dp.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
    dp.set18YearValidation()
    return dp
  }()
  
  let toolBar: UIToolbar = {
    let toolbar = UIToolbar(frame: CGRect.zero)
    toolbar.isTranslucent = false
    toolbar.backgroundColor = Constants.backgroundColor
    return toolbar
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let tapGR = UITapGestureRecognizer(target: self, action: #selector(DatePickerViewController.close(_:)))
    tapGR.delegate = self
    view.addGestureRecognizer(tapGR)
    setupDatePicker()
    setupToolbar()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    preferredContentSize = CGSize(width: datePicker.bounds.width, height: datePicker.bounds.size.height + 44)
  }
  
  func setupDatePicker() {
    if #available(iOS 14, *) {
        datePicker.preferredDatePickerStyle = .wheels
    }
    datePicker.backgroundColor = Constants.backgroundColor
    datePicker.datePickerMode = datePickerMode
    if let date = date {
      datePicker.setDate(date, animated: false)
    }
    view.addSubview(datePicker)
    datePicker.snp.makeConstraints { make in
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(view)
    }
  }
  
  func setupToolbar() {
    let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(DatePickerViewController.doneButtonTapped(_:)))
    
    let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(DatePickerViewController.cancelButtonTapped(_:)))
    let resetButton = UIBarButtonItem(title: "Reset", style: UIBarButtonItem.Style.plain, target: self, action: #selector(DatePickerViewController.resetButtonTapped(_:)))

    let flexiSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    
    toolBar.setItems([cancelButton, resetButton, flexiSpace, doneButton], animated: false)
    view.addSubview(toolBar)
    toolBar.snp.makeConstraints { make in
      make.height.equalTo(44)
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(datePicker.snp.top)
    }
  }
  
  @objc func close(_ sender: UITapGestureRecognizer) {
    if sender.state == .recognized {
      dismiss(animated: true, completion: nil)
    }
  }
  
  @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
     delegate?.datePickerDidSelectDate(
        date: datePicker.date,
        datePickerMode: datePickerMode
    )
    dismiss(animated: true, completion: nil)
  }
  
  @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @objc func resetButtonTapped(_ sender: UIBarButtonItem) {
    delegate?.datePickerDidSelectDate(
      date: nil,
      datePickerMode: datePickerMode
    )
    dismiss(animated: true, completion: nil)
  }
}

extension DatePickerViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view == view
  }
}
extension UIDatePicker {
func set18YearValidation() {
    let currentDate: Date = Date()
    var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    calendar.timeZone = TimeZone.autoupdatingCurrent
    var components: DateComponents = DateComponents()
    components.calendar = calendar
    components.year = Constants.dobPickerAgeLimit
    if let maxDate: Date = calendar.date(byAdding: components, to: currentDate) {
        components.year = Constants.dobPickerMaximumDate
        self.maximumDate = maxDate
    }
    if let minDate: Date = calendar.date(byAdding: components, to: currentDate) {
       self.minimumDate = minDate
    }
  }
    
func setMin18YearValidation() {
    let currentDate: Date = Date()
    self.maximumDate = currentDate
  }
}
