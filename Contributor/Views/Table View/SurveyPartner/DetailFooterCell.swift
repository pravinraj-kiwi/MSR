//
//  DetailFooterView.swift
//  Contributor
//
//  Created by KiwiTech on 5/6/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol DetailFooterCellDelegate: class {
 func clickToDismiss()
 func clickToDisConnectOrConnectDynata()
}

class DetailFooterCell: UITableViewCell {
 @IBOutlet weak var disconnectConnectButton: UIButton!
 @IBOutlet weak var noThanksButton: UIButton!
 weak var detailFooterCellDelegate: DetailFooterCellDelegate?

 override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    applyCommunityTheme()
 }

 @IBAction func clickToDismiss(_ sender: UIButton) {
    detailFooterCellDelegate?.clickToDismiss()
 }

 @IBAction func clickToDisConnectOrConnectDynata(_ sender: UIButton) {
   detailFooterCellDelegate?.clickToDisConnectOrConnectDynata()
 }
    func updateProfilItems(connectApp: ConnectedAppData?) {
        if connectApp?.setUpStatus == AppStatus.notConnected.rawValue {
            disconnectConnectButton.setTitle(MyDataText.connectText.localized(), for: .normal)

        } else {
            disconnectConnectButton.setTitle(MyDataText.disconnectText.localized(), for: .normal)
        }
    }
}
extension DetailFooterCell: CommunityThemeConfigurable {
 @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
        return
    }
    disconnectConnectButton.setBackgroundColor(color: colors.primary, forState: .normal)
    noThanksButton.setTitleColor(colors.primary, for: .normal)
 }
}

class DynataStausCell: UITableViewCell {
   
 @IBOutlet weak var statusTitle: UILabel!
 @IBOutlet weak var statusSubTitle: UILabel!

 override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
 }
            
func updateStatusUI(_ connectApp: ConnectedAppData?) {
    if let selectedAppData = connectApp, let app = selectedAppData.type,
          let type = ConnectedApp(rawValue: app) {
        statusTitle.text = DynataJobHistoryCell.statusTitleText.localized()
        switch type {
        case .dynata:
           statusSubTitle.text = DynataJobHistoryCell.dynataSubTitleText.localized()
        case .pollfish:
           statusSubTitle.text = DynataJobHistoryCell.pollfishSubTitleText.localized()
        case .kantar:
           statusSubTitle.text = DynataJobHistoryCell.kantarSubTitleText.localized()
        case .precision:
           statusSubTitle.text = DynataJobHistoryCell.precisionSubTitleText.localized()
        default:
            break
        }
    }
  }
}
