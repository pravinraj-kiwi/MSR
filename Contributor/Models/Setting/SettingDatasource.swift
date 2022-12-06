//
//  SettingDatasource.swift
//  Contributor
//
//  Created by KiwiTech on 9/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol SettingDataSourceDelegate: class {
  func clickToNavigate(_ section: Setting)
  func clickToHandleLogoutAction()
}

class SettingDatasource: NSObject, UITableViewDelegate, UITableViewDataSource {
var settingsData = [SettingsSection]()
let settingCount = SettingSection.settingCount.rawValue
let settingSection = SettingSection.settingSection.rawValue
weak var dataSourceDelegate: SettingDataSourceDelegate?

func numberOfSections(in tableView: UITableView) -> Int {
   return settingsData.map({$0.title}).count + settingCount
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   if section == settingsData.count {
     return settingCount
   }
   let data = settingsData[section]
   return data.items.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == settingsData.count {
        let cell = tableView.dequeueReusableCell(with: FooterCell.self, for: indexPath)
        cell.delegate = self
        cell.hasNoError = false
        updateSettingFooterCell(cell)
        return cell
    }
   let cell = tableView.dequeueReusableCell(with: SettingViewCell.self, for: indexPath)
   updateSettingCell(cell, indexPath)
   return cell
}
  
func updateSettingCell(_ cell: SettingViewCell, _ indexPath: IndexPath) {
   let section = settingsData[indexPath.section]
   let settingData = section.items[indexPath.row]
   if settingData.title == Text.deleteAcount.localized() {
     cell.settingTitle.textColor = Utilities.getRgbColor(255, 59, 48)
   } else {
     cell.settingTitle.textColor = .black
   }
   cell.settingTitle.text = settingData.title
}
    
func updateSettingFooterCell(_ cell: FooterCell) {
   cell.backgroundColor = .clear
   cell.updateButton.setTitle(Text.logoutText.localized(), for: .normal)
   let version = "\(Bundle.main.releaseVersionNumber ?? "?").\(Bundle.main.buildVersionNumber ?? "?")"
   cell.footerLabel.text = "\(Text.appVersionText.localized())\(version)"
   cell.updateButtonWithoutError()
}
    
func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
  guard let view = tableView.dequeueReusableHeaderFooterView(
                               withIdentifier: Constants.sectionViewNib)
                               as? SectionView else { return nil }
  if section == settingsData.count {
    view.divider.isHidden = true
    return view
  }
  updateHeaderSection(section, view)
  return view
}
    
func updateHeaderSection(_ section: Int, _ view: SectionView) {
  view.divider.isHidden = false
  if section == settingSection {
    view.topConstraint.constant = SettingList.topForFirstHeaderSec
    view.bottomConstraint.constant = SettingList.bottomForFirstHeaderSec
    view.dateLabel.font = Font.bold.of(size: 32)
  } else {
    view.topConstraint.constant = SettingList.topForHeaderSec
    view.bottomConstraint.constant = SettingList.bottomForHeaderSec
    view.dateLabel.font = Font.bold.of(size: 21)
  }
  let data = settingsData[section]
    view.dateLabel.text = data.title.localized()
}
    
func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == settingSection {
        return SettingList.heightForHeaderSec
    }
    if section == settingsData.count {
        return SettingList.topForFooterSec
    }
    return SettingList.heightForOtherHeaderSec
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == settingsData.count {
        return SettingList.heightForFooterRow
    }
    return SettingList.heightForRow
}
    
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == settingsData.count {
     return
   }
   let section = settingsData[indexPath.section]
   let setting = section.items[indexPath.row]
    dataSourceDelegate?.clickToNavigate(setting)
  }
}

extension SettingDatasource: FooterCellDelegate {
  func clickToPerformAction() {
    dataSourceDelegate?.clickToHandleLogoutAction()
  }
}
