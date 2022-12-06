//
//  JobWidgetMediumView.swift
//  Contributor
//
//  Created by KiwiTech on 10/20/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import SwiftUI
import WidgetKit

struct JobWidgetMediumView: View {
    
var entry: Provider.Entry
@Environment(\.colorScheme) var colorScheme

func updateColor() -> Color {
  return colorScheme == .dark ? Color.white : Color.black
}

var body: some View {
  VStack(alignment: .leading, spacing: 10) {
    
    VStack(alignment: .leading, spacing: 6) {
        if entry.job?.isFromSnapShot == true {
            let defaultValue = UserDefaults(suiteName: widgetConfig.getAppGroup())
            let firstName = defaultValue?.string(forKey: SuitDefaultName.userFirstName)
            Text("Hello \(firstName ?? WidgetConstant.defaultName),")
                    .font(WidgetFont.medium.of(size: 10))
                    .foregroundColor(WidgetUtil.getRgbColor(152, 152, 152))

        } else {
            let defaultValue = UserDefaults(suiteName: widgetConfig.getAppGroup())
            let firstName = defaultValue?.string(forKey: SuitDefaultName.userFirstName)
            Text("Hello \(firstName ?? ""),")
                    .font(WidgetFont.medium.of(size: 10))
                    .foregroundColor(WidgetUtil.getRgbColor(152, 152, 152))
        }

        Text(WidgetConstant.todayJob).font(WidgetFont.bold.of(size: 19))
            .foregroundColor(updateColor())
    }.padding(.top, 22)
    
    HStack(spacing: 10) {
        let defaultValue = UserDefaults(suiteName: widgetConfig.getAppGroup())
        if let communityColor = defaultValue?.string(forKey: SuitDefaultName.userCommunity) {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(hex: communityColor))
                    .frame(width: 2, height: 58)
        } else {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(hex: "#674cfe"))
                    .frame(width: 2, height: 58)
        }
        VStack(alignment: .leading) {
            Text(entry.job?.title ?? "")
                .font(WidgetFont.bold.of(size: 14))
                .foregroundColor(updateColor())
                .lineLimit(1)
            
            Text(entry.job?.description ?? "-")
                .font(WidgetFont.regular.of(size: 14))
                .foregroundColor(updateColor())
                .lineLimit(1)

            if hasExpireDate() {
                if let minutes = WidgetData().getMinuteInInt(entry.job?.expiry_date), minutes < 60 {
                   Text("Expires in \(WidgetData().getDateInMinutes(minutes))")
                    .font(WidgetFont.regular.of(size: 10))
                    .foregroundColor(WidgetUtil.getRgbColor(255, 59, 48))
                } else {
                    if let estimatedMinutes = entry.job?.estimated_minutes_to_complete,
                       estimatedMinutes != -1 {
                      if estimatedMinutes == 1 {
                        Text(WidgetConstant.completeTimeText)
                        .font(WidgetFont.regular.of(size: 10))
                        .foregroundColor(WidgetUtil.getRgbColor(152, 152, 152))
                      } else {
                        Text("\(estimatedMinutes) minutes to complete")
                        .font(WidgetFont.regular.of(size: 10))
                        .foregroundColor(WidgetUtil.getRgbColor(152, 152, 152))
                     }
                   }
                }
            }
            if entry.job?.isFromSnapShot == true {
                if entry.job?.expiry_date == "15 minutes" {
                    Text("Expires in \(entry.job?.expiry_date ?? "")")
                    .font(WidgetFont.regular.of(size: 10))
                    .foregroundColor(WidgetUtil.getRgbColor(255, 59, 48))
                } else {
                    Text("Expires in \(entry.job?.expiry_date ?? "")")
                    .font(WidgetFont.regular.of(size: 10))
                    .foregroundColor(WidgetUtil.getRgbColor(152, 152, 152))
                }
            }
        }
        Spacer()
        Text("\(entry.job?.estimated_earnings_msr ?? 0 ) MSR")
                .font(WidgetFont.bold.of(size: 14))
                .foregroundColor(updateColor())
                .padding(.trailing, 18)
    }
    
  }.padding(.bottom)
    .padding(.leading, 18)
}

func hasExpireDate() -> Bool {
    let minutesUntilExpiry = WidgetData().getMinuteInInt(entry.job?.expiry_date)
    if minutesUntilExpiry != 0 {
       return true
   }
  return false
 }
}
