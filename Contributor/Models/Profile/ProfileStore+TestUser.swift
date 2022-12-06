//
//  ProfileStore+TestUser.swift
//  Contributor
//
//  Created by KiwiTech on 6/2/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import os
import UIKit

extension ProfileStore {

func dumpKeysAndValuesToConsole() {
    for (key, value) in values {
        let valueString = "\(value)"
    }
}

func dumpKeysAndValuesToHTMLString() -> String {
    var valuesString = "<table style='width:100%'><tbody>\n"
    var valuesCount = 0
    for key in values.keys.sorted() {
        if let valueOfUnknownType = values[key] {
            var valuesList: [AnyHashable]
            if valueOfUnknownType is [AnyHashable] {
                valuesList = valueOfUnknownType as? [AnyHashable] ?? [AnyHashable]()
            } else {
                valuesList = [valueOfUnknownType]
            }
            valuesCount += valuesList.count
            valuesString += "<tr><td><b>\(key)</b><br>\n"
            let sortedValuesList = valuesList.sorted {"\($0)".localizedStandardCompare("\($1)") == .orderedAscending}
            for value in sortedValuesList {
                valuesString += "\(value)<br>\n"
            }
            valuesString += "</tr></td>\n"
        }
    }
    valuesString += "</tbody></table>\n"
    let headerString = "Total keys: \(values.count)<br>Total values: \(valuesCount)<br>\n"
    return headerString + valuesString
  }
}
