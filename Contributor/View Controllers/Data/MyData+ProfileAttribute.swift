//
//  MyData+ProfileAttribute.swift
//  Contributor
//
//  Created by KiwiTech on 11/6/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class ProfileAttributes {
    
func mapProfileItems(_ attribute: [ProfileAttributeModel],
                     completion: (([ProfileAttributeListModel]) -> Void)) {
    if let profileStore = UserManager.shared.profileStore {
     let profileValues = profileStore.values
      completion(matchValueOfProfileItem(profileValues, attribute))
  }
}
    
func matchValueOfProfileItem(_ profileStoreValues: [String: AnyHashable],
                             _ attribute: [ProfileAttributeModel]) -> [ProfileAttributeListModel] {
  var valuesArray = [ProfileAttributeListModel]()
    for item in attribute {
        let values = ProfileAttributeListModel()
       if profileStoreValues.contains(where: { $0.key == item.ref}),
          let profileKey = item.ref,
          let value = profileStoreValues[profileKey] {
        if let valueChoices = item.attributeOption,
           let categoryLabel = item.categoryLabel {
            values.attributeTitle = categoryLabel
          for choice in valueChoices {
            if let singleValue = value as? String {
              if choice.value == singleValue,
                  let standAloneLabel = choice.standAloneLabel {
                  values.profileMultiAnswers.append(standAloneLabel)
                  values.attributeItems = item
              }
            }
            if (value as? [String])?.contains(where: { $0 == choice.value}) == true,
               let standAloneLabel = choice.standAloneLabel {
                values.profileMultiAnswers.append(standAloneLabel)
                values.attributeItems = item
                }
              }
            }
          }
        valuesArray.append(values)
      }
     return valuesArray
  }
}
