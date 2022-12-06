//
//  DetailHeaderCell.swift
//  Contributor
//
//  Created by KiwiTech on 5/7/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

class DetailHeaderCell: UITableViewCell {

@IBOutlet weak var headerImagView: UIImageView!
@IBOutlet weak var headerTitle: UILabel!
@IBOutlet weak var headerDescription: UILabel!

override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
}

func updateHeaderUI(_ connectApp: ConnectedAppData?, _ jobEarnings: DynataJobDetail?) {
    if let selectedAppData = connectApp, let app = selectedAppData.type,
        let type = ConnectedApp(rawValue: app) {
        var text = ""
        switch type {
        case .dynata:
           text = Constants.withText + Constants.dynata
           headerImagView.image = Image.dynataLogo.value
        case .pollfish:
          text = Constants.withText + Constants.pollfish
          headerImagView.image = Image.walletpollfish.value
        case .kantar:
          text = Constants.withText + Constants.kantar
          headerImagView.image = Image.kantarLogo.value
        case .precision:
          text = Constants.withText + Constants.precisionSample
          headerImagView.image = Image.precisionSampleLogo.value
        default:
           break
       }
    if let earnedMsrPoints = jobEarnings?.earnedMsr {
      headerTitle.text = "\(earnedMsrPoints) MSR"
    }
    headerDescription.text = text
  }
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
 }
}
