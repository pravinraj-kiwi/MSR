//
//  MyAttribute+APICalling.swift
//  Contributor
//
//  Created by KiwiTech on 11/10/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

extension MyAttributeController {

func createModel(_ matchedAttributes: [ProfileAttributeListModel]) -> [ProfileAttributeListModel] {
   var attributeList = [ProfileAttributeListModel]()
   var attributeModel = ProfileAttributeListModel()
   for (_, element) in matchedAttributes.enumerated() {
      if !element.attributeTitle.isEmpty {
        if attributeList.contains(where: { $0.attributeTitle == element.attributeTitle}) {
            if let question = element.attributeItems?.label {
                let sortedAnswer = element.profileMultiAnswers.sorted(by: {$0 < $1})
                for answer in sortedAnswer {
                    let quesAns = CombineItems(item: question, answer: answer)
                    attributeModel.combineItems?.append(quesAns)
                }
                let sortedElement = attributeModel.combineItems?.sorted(by: {$0.attributeQuestions < $1.attributeQuestions})
                attributeModel.combineItems = sortedElement
            }
         } else {
            let newAttributeModel = ProfileAttributeListModel()
            newAttributeModel.attributeTitle = element.attributeTitle
            let sortedAnswer = element.profileMultiAnswers.sorted(by: {$0 < $1})
            if let question = element.attributeItems?.label {
                for answer in sortedAnswer {
                    let quesAns = CombineItems(item: question, answer: answer)
                    newAttributeModel.combineItems?.append(quesAns)
                }
                let sortedElement = newAttributeModel.combineItems?.sorted(by: {$0.attributeQuestions < $1.attributeQuestions})
                newAttributeModel.combineItems = sortedElement
            }
            attributeModel = newAttributeModel
            if attributeModel.combineItems?.isEmpty == false {
                attributeList.append(attributeModel)
             }
           }
        }
    }
    return attributeList
}
    
func createAttributedList() {
   callAttributeListApi { (attributeData, isSuccess) in
     if isSuccess {
        if let attributes = attributeData {
          ProfileAttributes().mapProfileItems(attributes) { [weak self] (matchedAttributes) in
            guard let this = self else { return }
            this.activityIndicator.updateIndicatorView(this, hidden: true)
            this.attributeDatasource.attributeData = this.createModel(matchedAttributes)
            this.createCollectionData(this.attributeDatasource.attributeData)
            this.tableView.reloadData()
          }
        }
      }
   }
}
    
func createCollectionData(_ listData: [ProfileAttributeListModel]) {
    if listData.isEmpty == true {
        colllectionModel = [AttributeCollectionModel(count: "😿", label: MyAttributes.attributesText.localized()),
                            AttributeCollectionModel(count: "😿", label: MyAttributes.categoriesText.localized())]
        collection.reloadData()
        return
    }
    let attributeCount = "\(listData.map({$0.combineItems?.count ?? 0}).reduce(0, +))"
    let categoryCount = "\(listData.count)"
    colllectionModel = [AttributeCollectionModel(count: attributeCount, label: MyAttributes.attributesText.localized()),
                        AttributeCollectionModel(count: categoryCount, label: MyAttributes.categoriesText.localized())]
    collection.reloadData()
  }
}
