//
//  MSRJobWidget.swift
//  MSRJobWidget
//
//  Created by KiwiTech on 10/20/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import WidgetKit
import SwiftUI

struct MSRJobWidgetEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            if entry.job == nil && entry.jobCount == 0 {
                SmallNoJobView()
            } else {
              if entry.job == nil {
                SmallWidgetPlaceholderView()
              } else {
                JobWidgetSmallView(entry: entry)
              }
            }
        case .systemMedium:
            if entry.job == nil && entry.jobCount == 0 {
                MediumNoJobView()
            } else {
              if entry.job == nil {
                MediumWidgetPlaceholderView()
              } else {
                JobWidgetMediumView(entry: entry)
              }
           }
        default:
            fatalError()
        }
    }
}

struct MSRJobWidget: Widget {
    let kind: String = "MSRJobWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MSRJobWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MSR Widget")
        .description("Get notified of new offers.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
