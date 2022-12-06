//
//  DynataDetailDataSource.swift
//  Contributor
//
//  Created by KiwiTech on 5/7/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

protocol DynataDetailDatasourceDelegate: class {
 func clickToReloadTableView()
 func clickToReloadMoreTableView()
 func clickToOpenTerms()
 func clickoOpenPrivacy()
 func clickToDisconnectDynata()
 func clickToGetJobDetail(_ appType: ConnectedApp, _ transaction: WalletTransaction)
}

enum DynataDetailCellType: CaseIterable {
  case dynataDetailHeader
  case dynataJobsDetail
  case dynataSharing
  case dynataSeeAll
  case dynataReadMore
  case dynataStatus
  case dynataDisconnect
    
  static func numberOfRows() -> Int {
       return self.allCases.count
   }
   static func getIndexRows(_ index: Int) -> DynataDetailCellType {
       return self.allCases[index]
   }
}

class DynataDetailDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

weak var dynataSourceDelegate: DynataDetailDatasourceDelegate?
var connectDynata: ConnectedAppData?
var jobEarnings: DynataJobDetail?

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DynataDetailCellType.numberOfRows()
}
    
func updateDynataJobDetailCell(_ cell: JobHistoryTableViewCell) {
  if let earnings = jobEarnings {
    cell.jobEarnings = earnings
    if let selectedApp = self.connectDynata, let app = selectedApp.type,
      let type = ConnectedApp(rawValue: app) {
        cell.appType = type
        cell.updateDynataEarnings(selectedApp)
      }
    }
    cell.jobHistoryDelegate = self
    cell.layoutIfNeeded()
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
switch DynataDetailCellType.getIndexRows(indexPath.row) {
case .dynataDetailHeader:
     let cell = tableView.dequeueReusableCell(with: DetailHeaderCell.self, for: indexPath)
     if let earnings = jobEarnings {
      cell.updateHeaderUI(connectDynata, earnings)
     }
     return cell
    
case .dynataJobsDetail:
    let cell = tableView.dequeueReusableCell(with: JobHistoryTableViewCell.self, for: indexPath)
    updateDynataJobDetailCell(cell)
    return cell
    
case .dynataSharing:
    let cell = tableView.dequeueReusableCell(with: DataSharingCell.self, for: indexPath)
    cell.updateSharingUI(connectDynata)
    return cell

case .dynataSeeAll:
    let cell = tableView.dequeueReusableCell(with: AppSeeAllTableViewCell.self, for: indexPath)
      if connectDynata != nil {
         cell.updateProfilItems(connectApp: connectDynata)
      }
      cell.appDetailDelegate = self
      return cell
    
case .dynataReadMore:
    let cell = tableView.dequeueReusableCell(with: AppReadMoreTableViewCell.self, for: indexPath)
    if let selectedApp = self.connectDynata, let app = selectedApp.type,
        let type = ConnectedApp(rawValue: app) {
        cell.appType = type
        cell.applyCommunityTheme()
    }
    cell.delegate = self
    return cell
    
case .dynataStatus:
    let cell = tableView.dequeueReusableCell(with: DynataStausCell.self, for: indexPath)
    cell.updateStatusUI(connectDynata)
    return cell
    
case .dynataDisconnect:
    let cell = tableView.dequeueReusableCell(with: DetailFooterCell.self, for: indexPath)
    cell.detailFooterCellDelegate = self
    return cell
    }
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

extension DynataDetailDataSource: AppDetailDelegate {
func clickToReloadRow() {
    dynataSourceDelegate?.clickToReloadTableView()
  }
}

extension DynataDetailDataSource: AppSubDetailDelegate {
func clickToOpenTerms() {
   dynataSourceDelegate?.clickToOpenTerms()
}

func clickoOpenPrivacy() {
   dynataSourceDelegate?.clickoOpenPrivacy()
}

func clickToReloadMoreRow() {
   dynataSourceDelegate?.clickToReloadMoreTableView()
  }
}

extension DynataDetailDataSource: DetailFooterCellDelegate {
    
func clickToDismiss() { }

func clickToDisConnectOrConnectDynata() {
   dynataSourceDelegate?.clickToDisconnectDynata()
 }
}

extension DynataDetailDataSource: JobHistoryCellDelegate {
func getTheJobHistoryDetail(_ appType: ConnectedApp, _ transaction: WalletTransaction) {
    dynataSourceDelegate?.clickToGetJobDetail(appType, transaction)
  }
}
