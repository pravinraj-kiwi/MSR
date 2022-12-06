//
//  FormStackViewController.swift
//
//  Created by arvindh on 19/07/18.
//

import UIKit
import SnapKit

class FormStackViewController: UIViewController, FormDelegate {
  var form: Form = Form()
  
  let scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.alwaysBounceVertical = true
    sv.backgroundColor = Constants.backgroundColor
    return sv
  }()
  
  let stackView: UIStackView = {
    let sv = UIStackView()
    sv.alignment = .fill
    sv.axis = .vertical
    sv.spacing = 0
    sv.distribution = .fill
    sv.backgroundColor = Constants.backgroundColor
    sv.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    return sv
  }()
  
  var keyboardWrapper: KeyboardWrapper!
  var bottomConstraint: Constraint!
  
  override open func viewDidLoad() {
    super.viewDidLoad()

    keyboardWrapper = KeyboardWrapper(delegate: self)
    
    setupViews()
    setupForm()
  }

  override open func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  override func setupViews() {
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { (make) in
      make.top.equalTo(view)
      make.left.equalTo(view)
      make.right.equalTo(view)
      self.bottomConstraint = make.bottom.equalTo(view).constraint
    }
    
    scrollView.addSubview(stackView)
    stackView.snp.makeConstraints { (make) in
      make.edges.equalTo(scrollView)
      make.left.equalTo(view)
      make.right.equalTo(view)
    }
  }
  
  open func setupForm() {
    form.delegate = self
  }
  
  public func reloadData() {
    stackView.removeAllArrangedSubviews()
    
    for row in form.rows {
      let containerView = UIView()
      containerView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
      
      row.attach(to: containerView)
      
      stackView.addArrangedSubview(containerView)
    }
  }

  open func onValidation(errors: [FormValidationError]) {
    let errorMessage = errors.reduce("") { (result: String, error: FormValidationError) -> String in
      var result = result
      result += (error.errorDescription ?? "") + "\n"
      return result
    }
    
    let alert = UIAlertController(title: Text.error.localized(), message: errorMessage,
                                  preferredStyle: UIAlertController.Style.alert)
    present(alert, animated: true, completion: nil)
  }
  
  public func rowsDidChange() {
    reloadData()
  }
}

extension FormStackViewController: KeyboardWrapperDelegate {
  public func keyboardWrapper(_ wrapper: KeyboardWrapper, didChangeKeyboardInfo info: KeyboardInfo) {
    if info.state == .willHide || info.state == .hidden {
      bottomConstraint.update(offset: 0)
    } else {
      bottomConstraint.update(offset: -info.endFrame.height)
    }
    
    UIView.animate(withDuration: info.animationDuration, delay: 0, options: info.animationOptions, animations: {
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    }, completion: { (_) in
      
    })
  }
}
