//
//  MediumNoJobView.swift
//  Contributor
//
//  Created by KiwiTech on 10/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import SwiftUI

struct MediumNoJobView: View {

  @Environment(\.colorScheme) var colorScheme
    
  func updateColor() -> Color {
    return colorScheme == .dark ? Color.white : Color.black
  }
    
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
        VStack(alignment: .leading, spacing: 6) {
        let defaultValue = UserDefaults(suiteName: widgetConfig.getAppGroup())
        let firstName = defaultValue?.string(forKey: SuitDefaultName.userFirstName)
        Text("Hello \(firstName ?? WidgetConstant.defaultName),")
                .font(WidgetFont.medium.of(size: 10))
                .foregroundColor(WidgetUtil.getRgbColor(152, 152, 152))
        
        Text(WidgetConstant.todayJob).font(WidgetFont.bold.of(size: 19))
            .foregroundColor(updateColor())
            
    }.padding(.top, 5)
        HStack(alignment: .center, spacing: 25) {
            Image(NoJobImageName.medLargeJob)

            Text(WidgetConstant.noJobText)
                .font(WidgetFont.medium.of(size: 14))
                .foregroundColor(updateColor())
        }.padding(.trailing, 18)
        
    }.padding(.bottom)
    .padding(.leading, 18)
    .padding(.trailing, 18)
  }
}
