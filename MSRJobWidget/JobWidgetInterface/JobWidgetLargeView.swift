//
//  JobWidgetLargeView.swift
//  Contributor
//
//  Created by KiwiTech on 10/20/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import SwiftUI
import WidgetKit

struct JobWidgetLargeView: View {
    
    var entry: LargeJobProvider.EntryJob

    @Environment(\.colorScheme) var colorScheme
        
    func updateColor() -> Color {
      return colorScheme == .dark ? Color.white : Color.black
    }
    
    var body: some View {
       
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    let defaultValue = UserDefaults(suiteName: widgetConfig.getAppGroup())
                    let firstName = defaultValue?.string(forKey: SuitDefaultName.userFirstName)
                    Text("Hello \(firstName ?? entry.firstName),")
                            .font(WidgetFont.medium.of(size: 10))
                            .foregroundColor(WidgetUtil.getRgbColor(152, 152, 152))
                    
                    Text(WidgetConstant.todayJob)
                        .font(WidgetFont.bold.of(size: 23))
                        .foregroundColor(updateColor())
                }
                Spacer()
                let defaultValue = UserDefaults(suiteName: widgetConfig.getAppGroup())
                if let balance = defaultValue?.string(forKey: SuitDefaultName.userBalance),
                   let communityColor = defaultValue?.string(forKey: SuitDefaultName.userCommunity) {
                    Text("\(balance) MSR")
                        .font(WidgetFont.bold.of(size: 12))
                        .foregroundColor(updateColor())
                        .padding(.trailing, 9)
                        .background(Capsule()
                                        .fill(colorScheme == .dark ?  Color(hex: communityColor) : WidgetUtil.getRgbColor(237, 237, 237))
                                        .frame(width: 79, height: 20)
                                        .padding(.trailing, 9)
                        )
                } else {
                    Text("0 MSR")
                        .font(WidgetFont.bold.of(size: 12))
                        .foregroundColor(updateColor())
                        .padding(.trailing, 18)
                        .background(Capsule()
                                        .fill(colorScheme == .dark ?  Color(hex: "#674cfe") : WidgetUtil.getRgbColor(237, 237, 237))
                                        .frame(width: 79, height: 20)
                                        .padding(.trailing, 18)
                        )
                }
            }.padding(.bottom, 2)
            Divider()
            VStack(alignment: .leading, spacing: 20) {
              ForEach(entry.jobArray ?? [], id: \.id) { item in
              
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
                        
                        Text(item.title ?? "")
                            .font(WidgetFont.bold.of(size: 14))
                            .foregroundColor(updateColor())

                        Text(item.description ?? "-")
                            .font(WidgetFont.regular.of(size: 14))
                            .foregroundColor(updateColor())

                        if let expireDate = item.expiry_date, hasExpireDate(expiryDate: expireDate) {
                            if let minutes = WidgetData().getMinuteInInt(item.expiry_date), minutes < 60 {
                               Text("Expires in \(WidgetData().getDateInMinutes(minutes))")
                                .font(WidgetFont.regular.of(size: 10))
                                .foregroundColor(WidgetUtil.getRgbColor(255, 59, 48))
                            } else {
                                if let estimatedMinutes = item.estimated_minutes_to_complete,
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
                        
                        if item.isFromSnapShot == true {
                            if item.expiry_date == "15 minutes" {
                                Text("Expires in \(item.expiry_date ?? "")")
                                .font(WidgetFont.regular.of(size: 10))
                                .foregroundColor(WidgetUtil.getRgbColor(255, 59, 48))
                            } else {
                                Text("Expires in \(item.expiry_date ?? "")")
                                .font(WidgetFont.regular.of(size: 10))
                                .foregroundColor(WidgetUtil.getRgbColor(152, 152, 152))
                            }
                        }
                    }
                    Spacer()
                    if item.estimated_earnings_msr == -1 {
                        Text("").font(WidgetFont.bold.of(size: 14))
                            .foregroundColor(updateColor())

                    } else {
                        Text("\(item.estimated_earnings_msr) MSR")
                            .font(WidgetFont.bold.of(size: 14))
                            .foregroundColor(updateColor())
                    }
                }
              }
            }.padding(.top, 18)
            Spacer()
        }.padding([.top, .bottom], 18)
        .padding(.leading, 18)
        .padding(.trailing, 18)
    }
    
    func hasExpireDate(expiryDate: String) -> Bool {
        let minutesUntilExpiry = WidgetData().getMinuteInInt(expiryDate)
        if minutesUntilExpiry != 0 {
          return true
       }
      return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let jobs = [JobOffer(id: 1, estimated_earnings_msr: 92,
                             estimated_minutes_to_complete: -1,
                             title: "Partner Survey",
                             description: "Your feedback is needed",
                             expiry_date: "15 minutes",
                             isFromSnapShot: true, noJob: false)]
        JobWidgetLargeView(entry: LargeJobEntry(date: Date(), jobCount: 1, firstName: WidgetConstant.defaultName, jobArray: jobs))
    }
}
