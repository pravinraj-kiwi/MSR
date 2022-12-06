//
//  LargeNoJobView.swift
//  Contributor
//
//  Created by KiwiTech on 10/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import SwiftUI

struct LargeNoJobView: View {
    @Environment(\.colorScheme) var colorScheme
      
    func updateColor() -> Color {
      return colorScheme == .dark ? Color.white : Color.black
    }
      
    var body: some View {
      VStack(alignment: .leading, spacing: 20) {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                let defaultValue = UserDefaults(suiteName: widgetConfig.getAppGroup())
                let firstName = defaultValue?.string(forKey: SuitDefaultName.userFirstName)
                Text("Hello \(firstName ?? WidgetConstant.defaultName),")
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
                    .padding(.trailing, 20)
                    .background(Capsule()
                                    .fill(colorScheme == .dark ?  Color(hex: communityColor) : WidgetUtil.getRgbColor(237, 237, 237))
                                    .frame(width: 79, height: 20)
                                             .padding(.trailing, 20)
                    )
            } else {
                Text("0 MSR")
                    .font(WidgetFont.bold.of(size: 12))
                    .foregroundColor(updateColor())
                    .padding(.trailing, 20)
                    .background(Capsule()
                                    .fill(colorScheme == .dark ?  Color(hex: "#674cfe") : WidgetUtil.getRgbColor(237, 237, 237))
                                    .frame(width: 79, height: 20)
                                             .padding(.trailing, 20)
                    )
            }
        }
        
        Divider()

        VStack(alignment: .center, spacing: 25) {
              Image(NoJobImageName.medLargeJob)

              Text(WidgetConstant.noJobText)
                  .font(WidgetFont.medium.of(size: 14))
                  .foregroundColor(updateColor())
                  .multilineTextAlignment(.center)
          }.padding([.trailing, .leading], 50)
        .padding(.top, 18)
        Spacer()
      }
      .padding(.bottom)
      .padding(.top, 18)
      .padding(.leading, 18)
      .padding(.trailing, 18)
    }
}
