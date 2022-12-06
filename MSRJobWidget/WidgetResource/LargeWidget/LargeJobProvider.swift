//
//  LargeJobProvider.swift
//  Contributor
//
//  Created by KiwiTech on 10/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import WidgetKit

struct LargeJobProvider: TimelineProvider {
    
  let resource: JobResource = JobResource()
  typealias EntryJob = LargeJobEntry

  func placeholder(in context: Context) -> LargeJobEntry {
    return LargeJobEntry(date: Date(), jobCount: -1, jobArray: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (LargeJobEntry) -> ()) {
    let entry = LargeJobEntry.mockLargeJobEntry()
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<EntryJob>) -> ()) {
    let currentDate = Date()
    let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
    resource.getJobOffer { result in
        var offer: [JobOffer]?
        var offerCount: Int = -1
        if case .success(let recentOffer) = result {
          if !recentOffer.isEmpty {
            offer = Array(recentOffer.prefix(3))
          }
          offerCount = recentOffer.count
        } else {
          offer = nil
        }
        let entry = LargeJobEntry(date: currentDate, jobCount: offerCount, jobArray: offer)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
     }
  }
}
