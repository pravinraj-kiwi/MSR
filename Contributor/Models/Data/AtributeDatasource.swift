//
//  AtributeDatasource.swift
//  Contributor
//
//  Created by KiwiTech on 11/9/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class AtributeDatasource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
var attributeData = [ProfileAttributeListModel]()
var filteredData = [ProfileAttributeListModel]()
let attributeCount = SettingSection.settingCount.rawValue
let attributeSection = SettingSection.settingSection.rawValue
var isSearching = false

func numberOfSections(in tableView: UITableView) -> Int {
    if isSearching {
        return filteredData.map({$0.attributeTitle}).count
    }
    return attributeData.map({$0.attributeTitle}).count
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isSearching {
        let data = filteredData[section]
        return data.combineItems?.count ?? 0
    }
    let data = attributeData[section]
    return data.combineItems?.count ?? 0
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(with: SettingViewCell.self, for: indexPath)
    cell.backgroundColor = .clear
    if isSearching {
        updateSearchAttributeCell(cell, indexPath)
        return cell
    }
   updateAttributeCell(cell, indexPath)
   return cell
}
  
func updateAttributeCell(_ cell: SettingViewCell, _ indexPath: IndexPath) {
   let section = attributeData[indexPath.section]
   let combine = section.combineItems?[indexPath.row]
   if let question = combine?.attributeQuestions,
      let answer = combine?.attributeAnswers {
      let valueString = "\(question) | \(answer)"
      cell.settingTitle.text = valueString
   }
}
    
func updateSearchAttributeCell(_ cell: SettingViewCell, _ indexPath: IndexPath) {
   let section = filteredData[indexPath.section]
   let combine = section.combineItems?[indexPath.row]
   if let question = combine?.attributeQuestions,
      let answer = combine?.attributeAnswers {
      let valueString = "\(question) | \(answer)"
      cell.settingTitle.text = valueString
   }
}
    
func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
  guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: Constants.sectionViewNib)
            as? SectionView else { return nil }
  updateHeaderSection(section, view)
  return view
}
    
func updateHeaderSection(_ section: Int, _ view: SectionView) {
  view.divider.isHidden = false
  if section == attributeSection {
    view.topConstraint.constant = SettingList.topForProfileHeaderSec
    view.bottomConstraint.constant = SettingList.bottomForHeaderSec
  } else {
    view.topConstraint.constant = SettingList.topForHeaderSec
    view.bottomConstraint.constant = SettingList.bottomForHeaderSec
  }
  if isSearching {
    let data = filteredData[section]
    view.dateLabel.font = Font.bold.of(size: 21)
    view.dateLabel.text = data.attributeTitle
  } else {
    let data = attributeData[section]
    view.dateLabel.font = Font.bold.of(size: 21)
    view.dateLabel.text = data.attributeTitle
  }
}
    
func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == attributeSection {
        return SettingList.heightForProfileHeaderSec
    }
    if !isSearching, section == attributeData.count {
        return SettingList.topForFooterSec
    } else {
        if section == filteredData.count {
            return SettingList.topForFooterSec
        }
    }
    return SettingList.heightForOtherHeaderSec
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
   return UITableView.automaticDimension
  }
}
