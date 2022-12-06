//
//  TableViewConstants.swift
//  Contributor
//
//  Created by KiwiTech on 10/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

struct SettingList {
 static let heightForRow: CGFloat = 56
 static let heightForFooterRow: CGFloat = 103
 static let heightForHeaderSec: CGFloat = 88
 static let heightForOtherHeaderSec: CGFloat = 70
 static let topForFirstHeaderSec: CGFloat = 38
 static let topForHeaderSec: CGFloat = 36
 static let topForFooterSec: CGFloat = 28
 static let bottomForFirstHeaderSec: CGFloat = 16
 static let bottomForHeaderSec: CGFloat = 12
 static let heightForProfileHeaderSec: CGFloat = 66
 static let topForProfileHeaderSec: CGFloat = 30
 static let zero =  0
}

struct FormList {
 static let heightForOtherHeaderSec: CGFloat = 40
 static let heightForFooterSec: CGFloat = 35
 static let heightForFooterSecondSec: CGFloat = 16
 static let zero =  0
}

enum SettingSection: Int {
 case settingSection = 0
 case settingCount = 1
}

struct WalletList {
 static let heightForRowTranSec: CGFloat = 64
 static let heightForHeaderRowSec: CGFloat = 238
 static let heightForHeaderSec: CGFloat = 70
 static let heightForFirstHeaderSec: CGFloat = 60
 static let topForFirstHeaderSec: CGFloat = 14
 static let topForHeaderSec: CGFloat = 30
 static let zero =  0
}

enum WalletListSection: Int {
 case reedemSection = 0
 case reedemCount = 1
}

struct TransactionDetails {
 static let heightForRowTranDetailSec: CGFloat = 64
 static let heightForRowReportIssue: CGFloat = 55
 static let heightForHeaderRowSec: CGFloat = 180
 static let heightForHeaderSec: CGFloat = 70
 static let heightForFirstHeaderSec: CGFloat = 60
 static let topForFirstHeaderSec: CGFloat = 14
 static let topForHeaderSec: CGFloat = 30
 static let zero =  0
}

enum TransactionDetailSection: Int {
case transForHeaderSection = 0
case detailSection = 1
}

struct SupportList {
 static let heightForHeaderCell: CGFloat = 310
 static let noOfRows = 2
 static let firstIndex = 0
 static let lastIndex = 1
 static let collectionItemWidth: CGFloat = 96
 static let collectionItemHeight: CGFloat = 150
 static let collectionLineSpacing = 12.0
 static let pickerRowHeight: CGFloat = 29
 static let supportCell = "SupportCollectionCell"
 static let pickerList = ["General Feedback", "Something Isn’t Working",
                          "Can’t Complete Registration", "Other"]
 static let reasonButtonText = "Select a category of concern"
 static let placeholderText = "Message"
 static let pickerHeightConstant: CGFloat = 130
 static let pickerRadius: CGFloat = 7.0
 static let disclaimerText = "Found a bug? Briefly explain what happened and we look into it as soon as possible."
 static let headerTitle = "Send Feedback"
 static let subTitte = "Let’s chat - We are hyper responsive"
    static let feedbackHeaderHelloTitle = "Hello,"
    static let feedbackHeaderHelloSubTitle = "how can we help?"

    static let yesPlease = "Yes, please email me a copy of this message"
}

struct ReferFriendList {
 static let heightForCell: CGFloat = 741
 static let noOfRows = 1
}
