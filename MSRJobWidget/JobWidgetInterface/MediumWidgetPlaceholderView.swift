//
//  MediumWidgetPlaceholderView.swift
//  Contributor
//
//  Created by KiwiTech on 10/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import SwiftUI

struct MediumWidgetPlaceholderView: View {
    
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
        VStack(alignment: .leading, spacing: 6) {
            Image(colorScheme == .dark ? DarkModeImageName.darkMode : LightModeImageName.lightMode)
            Image(colorScheme == .dark ? DarkModeImageName.darkMode1 : LightModeImageName.lightMode1)
        }.padding(.top, 22)
        HStack(spacing: 10) {
            let defaultValue = UserDefaults(suiteName: widgetConfig.getAppGroup())
            if let communityColor = defaultValue?.string(forKey: SuitDefaultName.userCommunity) {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: communityColor))
                        .frame(width: 3, height: 58)
                } else {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: communityColor).opacity(0.30))
                        .frame(width: 3, height: 58)
                }
            } else {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: "#674cfe"))
                        .frame(width: 3, height: 58)
                } else {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: "#674cfe").opacity(0.30))
                        .frame(width: 3, height: 58)
                }
            }
            VStack(alignment: .leading) {
                Image(colorScheme == .dark ? DarkModeImageName.darkMode2 : LightModeImageName.lightMode2)
                Image(colorScheme == .dark ? DarkModeImageName.darkMode3 : LightModeImageName.lightMode3)
                Image(colorScheme == .dark ? DarkModeImageName.darkMode4 : LightModeImageName.lightMode4)
            }
            Spacer()
            Image(colorScheme == .dark ? DarkModeImageName.darkMode3 : LightModeImageName.lightMode3)
                .padding(.trailing, 18)
        }
     }
    .padding(.bottom)
    .padding(.leading, 18)
  }
}
