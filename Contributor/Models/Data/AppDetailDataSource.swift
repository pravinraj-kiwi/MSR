//
//  AppDetailDataSource.swift
//  Contributor
//
//  Created by KiwiTech on 5/6/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

protocol AppDetailDatasourceDelegate: class {
 func clickToReloadTableView()
 func clickToReloadMoreTableView()
 func clickToOpenTerms(_ appTpe: ConnectedApp?)
 func clickoOpenPrivacy(_ appTpe: ConnectedApp?)
 func clickToDismiss()
 func clickToConnectDynata(_ appTpe: ConnectedApp?)
 func didTapLabel(_ label: UILabel, gesture: UITapGestureRecognizer, _ appTpe: ConnectedApp?)
}

enum AppDetailCellType: CaseIterable {
case appDetailHeader
case appDetailSeeAll
case appDetailReadMore
case appDetailConnect
  
static func numberOfRows() -> Int {
    return self.allCases.count
}
static func getIndexRows(_ index: Int) -> AppDetailCellType {
    return self.allCases[index]
  }
}

class AppDetailDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
var type: ConnectedApp?
var connectApps: ConnectedAppData?
weak var datasourceDelegate: AppDetailDatasourceDelegate?
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if type == .linkedin || type == .facebook {
        return 1
    }
    return AppDetailCellType.numberOfRows()
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch AppDetailCellType.getIndexRows(indexPath.row) {
    case .appDetailHeader:
        let cell = tableView.dequeueReusableCell(with: AppDetailHeaderTableViewCell.self, for: indexPath)
        cell.appDetailHeaderDelegate = self
        if let appType = type {
            cell.appType = appType
            cell.updateHeaderUI(appType)
        }
        return cell
        
    case .appDetailSeeAll:
        let cell = tableView.dequeueReusableCell(with: AppSeeAllTableViewCell.self, for: indexPath)
        if let appData = connectApps {
           cell.updateProfilItems(connectApp: appData)
        }
        cell.appDetailDelegate = self
        return cell

    case .appDetailReadMore:
        let cell = tableView.dequeueReusableCell(with: AppReadMoreTableViewCell.self, for: indexPath)
        cell.appType = type
        cell.applyCommunityTheme()
        cell.delegate = self
        return cell

    case .appDetailConnect:
        let cell = tableView.dequeueReusableCell(with: DetailFooterCell.self, for: indexPath)
        if let appData = connectApps {
           cell.updateProfilItems(connectApp: appData)
        }
        cell.detailFooterCellDelegate = self
        return cell
    }
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

extension AppDetailDataSource: AppDetailDelegate {
func clickToReloadRow() {
    datasourceDelegate?.clickToReloadTableView()
 }
}

extension AppDetailDataSource: AppSubDetailDelegate {
func clickToOpenTerms() {
    if let type = type {
     datasourceDelegate?.clickToOpenTerms(type)
    }
}

func clickoOpenPrivacy() {
    if let type = type {
        datasourceDelegate?.clickoOpenPrivacy(type)
    }
}

func clickToReloadMoreRow() {
    datasourceDelegate?.clickToReloadMoreTableView()
 }
}

extension AppDetailDataSource: DetailFooterCellDelegate {
    
func clickToDismiss() {
  datasourceDelegate?.clickToDismiss()
}

func clickToDisConnectOrConnectDynata() {
    if let type = type {
        datasourceDelegate?.clickToConnectDynata(type)
    }
  }
}

extension AppDetailDataSource: AppDetailHeaderDelegate {
    func didTapGesture(_ label: UILabel, gesture: UITapGestureRecognizer) {
        if let type = type {
            datasourceDelegate?.didTapLabel(label, gesture: gesture, type)
        }
    }
}
