//
//  SmallNoJobView.swift
//  Contributor
//
//  Created by KiwiTech on 10/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import SwiftUI

struct SmallNoJobView: View {

  @Environment(\.colorScheme) var colorScheme
    
  func updateColor() -> Color {
    return colorScheme == .dark ? Color.white : Color.black
  }
    
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
        let defaultValue = UserDefaults(suiteName: widgetConfig.getAppGroup())
        let firstName = defaultValue?.string(forKey: SuitDefaultName.userFirstName)
       Text("Hello \(firstName ?? WidgetConstant.defaultName),")
                .font(WidgetFont.medium.of(size: 10))
                .foregroundColor(WidgetUtil.getRgbColor(152, 152, 152))
        
        Text(WidgetConstant.todayJob)
            .font(WidgetFont.bold.of(size: 19))
            .foregroundColor(updateColor())
            
    }.padding(.top, 5)
    .padding(.bottom, 5)
    .padding(.leading, 18)
    .padding(.trailing, 18)

    Image(NoJobImageName.smallNoJob)
        .padding(.bottom, 10)
  }
}
