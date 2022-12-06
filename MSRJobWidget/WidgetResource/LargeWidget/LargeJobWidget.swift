//
//  LargeJobWidget.swift
//  Contributor
//
//  Created by KiwiTech on 10/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import WidgetKit
import SwiftUI

struct LargeJobWidgetEntryView: View {
    
    var entry: LargeJobProvider.EntryJob

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemLarge:
          if entry.jobArray == nil && entry.jobCount == 0 {
             LargeNoJobView()
          } else {
            if entry.jobArray == nil {
               let entry = LargeJobEntry.mockLargeJobEntry()
               LargeWidgetPlaceholderView(entry: entry)
            } else {
               JobWidgetLargeView(entry: entry)
            }
          }
            
        default:
            fatalError()

        }
    }
}

struct LargeJobWidget: Widget {
    let kind: String = "LargJobWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeJobProvider()) { entry in
            LargeJobWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MSR Widget")
        .description("Get notified of new offers.")
        .supportedFamilies([.systemLarge])
    }
}
