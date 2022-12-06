//
//  SurveyPartnersDatasource.swift
//  Contributor
//
//  Created by Kiwitech on 04/05/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol DatasourceDelegate: class {
 func clickToOpenConnectionDetail(index: Int)
 func clickToOpenConnectedDetail(index: Int)
}

class AppDataDatasource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
var connectApps: [ConnectedAppData]?
var type: ConnectedDataType = .profileValidation
weak var datasourceDelegate: DatasourceDelegate?
let footerViewNib = "TableFooterView"

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let count = connectApps?.count {
       return count + 1
    }
     return 0
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(with: DataTypeHeaderTableViewCell.self, for: indexPath)
        cell.updateUI(groupType: type)
        return cell
    }
    let cell = tableView.dequeueReusableCell(with: DataTypeTableViewCell.self, for: indexPath)
    cell.delegate = self
    cell.dataTypeConnectButton.tag = indexPath.row
    cell.connectedSelectionButton.tag = indexPath.row
    if let app = connectApps?[indexPath.row - 1] {
        cell.updateUI(appData: app)
    }
    return cell
}

func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
   guard let view = tableView.dequeueReusableHeaderFooterView(
                              withIdentifier: footerViewNib)
                              as? TableFooterView else {
        return nil
    }
   return view
}

func tableView(_ tableView: UITableView,
               heightForFooterInSection section: Int) -> CGFloat {
    if type == .surveyPartners {
        return 44
    }
    return 0
  }
}
extension AppDataDatasource: DataTypeDelegate {
func clickToOpenConnectionDetail(index: Int) {
  datasourceDelegate?.clickToOpenConnectionDetail(index: index)
}
    
func clickToOpenConnectedDetail(index: Int) {
  datasourceDelegate?.clickToOpenConnectedDetail(index: index)
  }
}
