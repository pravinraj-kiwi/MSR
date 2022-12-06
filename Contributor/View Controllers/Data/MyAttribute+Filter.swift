//
//  MyAttribute+Filter.swift
//  Contributor
//
//  Created by KiwiTech on 11/13/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension MyAttributeController: UITextFieldDelegate {
@objc func searchTextChanged(_ sender: UITextField) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    if sender.text?.isEmpty == false, let seachKeyword = sender.text {
        self.updateUIAfterSearch(seachKeyword)
    } else {
        self.attributeDatasource.filteredData.removeAll()
        self.attributeDatasource.filteredData = []
        self.createCollectionData(self.attributeDatasource.attributeData)
        self.attributeDatasource.isSearching = false
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
      }
   }
}
    
func updateUIAfterSearch(_ seachKeyword: String) {
 self.attributeDatasource.isSearching = true
 let filterAttributeArray = self.filterContentForSearchText(seachKeyword)
 self.attributeDatasource.filteredData = filterAttributeArray
 self.createCollectionData(self.attributeDatasource.filteredData)
 DispatchQueue.main.async {
    self.tableView.reloadData()
    if filterAttributeArray.isEmpty == true {
        self.tableView.setEmptyView(title: ProfileAttributeText.emptySearchHeaderText.localized(),
                                        message: ProfileAttributeText.emptySearchSubHeaderText.localized(),
                                        subColor: self.themeColor ?? Constants.primaryColor)
    } else {
        self.tableView.restore()
    }
  }
}
    
func filterContentForSearchText(_ searchText: String) -> [ProfileAttributeListModel] {
  var filteredData = [ProfileAttributeListModel]()
  let originalArray = attributeDatasource.attributeData
  for data in originalArray {
    var match = false
    var filteredCombineData = [CombineItems]()
    let newAttributeModel = ProfileAttributeListModel()
    if data.attributeTitle.localizedCaseInsensitiveContains(searchText) {
        match = true
    }
    if let combinedData = data.combineItems {
        for items in combinedData {
            if items.attributeQuestions.localizedCaseInsensitiveContains(searchText) || items.attributeAnswers.localizedCaseInsensitiveContains(searchText) {
                filteredCombineData.append(items)
                match = true
            }
        }
    }
    if match {
        if !filteredCombineData.isEmpty {
            newAttributeModel.combineItems = filteredCombineData
        } else {
            newAttributeModel.combineItems = data.combineItems
        }
      newAttributeModel.attributeTitle = data.attributeTitle
      filteredData.append(newAttributeModel)
     }
   }
  return filteredData
}
  
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
