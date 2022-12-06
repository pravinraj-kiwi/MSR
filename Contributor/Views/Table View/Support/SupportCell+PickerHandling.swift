//
//  SupportCell+PickerHandling.swift
//  Contributor
//
//  Created by KiwiTech on 10/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension SupportFeedbackCell: UIPickerViewDelegate, UIPickerViewDataSource {
 func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
 }
    
 func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return SupportList.pickerList.count
 }
        
 func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return SupportList.pickerList[row].localized()
 }
    
 func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
   let pickerLabel = UILabel()
    pickerLabel.attributedText = NSAttributedString(string: SupportList.pickerList[row].localized(),
                                                   attributes: [NSAttributedString.Key.font: Font.regular.of(size: 16),
                                                                NSAttributedString.Key.foregroundColor: Utilities.getRgbColor(0, 0, 0)])
   pickerLabel.textAlignment = .center
   return pickerLabel
 }

 func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedRow = row
    DispatchQueue.main.async { pickerView.reloadAllComponents() }
 }
 
func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    return SupportList.pickerRowHeight
 }
}
