//
//  MyAttribute+Search.swift
//  Contributor
//
//  Created by KiwiTech on 11/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension MyAttributeController {

@IBAction func clickToSearch(_ sender: Any) {
  searchButton.isHidden = true
  searchView.isHidden = false
  searchView.isUserInteractionEnabled = true
  showAndAnimateSearchButton()
}
    
func showAndAnimateSearchButton() {
  self.searchConstraint.constant = 22
  UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn], animations: {
    self.searchView.layoutIfNeeded()
    UIView.animate(withDuration: 0.1) {
        self.headerText.isHidden = true
        self.setUpNavBar(backArrowImage: Image.crossWhite.value,
                             ProfileAttributeText.attributesText.localized(), titleColor: .white)
        self.searchBar.becomeFirstResponder()
    }
   }, completion: nil)
}
    
func closeAndAnimateSearchButton() {
  self.searchConstraint.constant = 250
  UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn], animations: {
    self.searchView.layoutIfNeeded()
    UIView.animate(withDuration: 0.1) {
        self.headerText.isHidden = false
        self.headerText.slideInFromLeft(transationType: .fromBottom)
        self.setUpNavBar(backArrowImage: Image.crossWhite.value)
        self.searchBar.resignFirstResponder()
    }
   }, completion: nil)
}
    
@IBAction func clickToCancel(_ sender: Any) {
  searchButton.isHidden = false
  searchView.isHidden = true
  searchView.isUserInteractionEnabled = true
  closeAndAnimateSearchButton()
  resetSearch()
}
    
func resetSearch() {
 self.tableView.restore()
 searchBar.text = nil
 attributeDatasource.isSearching = false
 attributeDatasource.filteredData = []
 createCollectionData(attributeDatasource.attributeData)
 tableView.reloadData()
  }
}

extension UIView {
func slideInFromLeft(duration: TimeInterval = 0.5,
                     transationType: CATransitionSubtype = CATransitionSubtype.fromLeft,
                     completionDelegate: CAAnimationDelegate? = nil) {
    let slideInFromLeftTransition = CATransition()
    slideInFromLeftTransition.type = CATransitionType.push
    slideInFromLeftTransition.subtype = transationType
    slideInFromLeftTransition.delegate = completionDelegate
    slideInFromLeftTransition.duration = duration
    slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
    self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
   }
}

extension UITextField {
func setLeftPaddingPoints(_ amount: CGFloat) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
    self.leftView = paddingView
    self.leftViewMode = .always
}
func setRightPaddingPoints(_ amount: CGFloat) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
    self.rightView = paddingView
    self.rightViewMode = .always
  }
}
