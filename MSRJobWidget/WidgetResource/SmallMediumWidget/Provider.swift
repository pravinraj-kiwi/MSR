//
//  Provider.swift
//  Contributor
//
//  Created by KiwiTech on 10/20/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import WidgetKit

struct Provider: TimelineProvider {
    
 let resource: JobResource = JobResource()
 typealias Entry = JobEntry

 func placeholder(in context: Context) -> JobEntry {
    return JobEntry(date: Date(), jobCount: -1, job: nil)
 }

 func getSnapshot(in context: Context, completion: @escaping (JobEntry) -> ()) {
    let entry = JobEntry.mockSnapShotJobEntry()
    completion(entry)
 }

func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let currentDate = Date()
    let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
    resource.getJobOffer { result in
        var offer: JobOffer?
        var offerCount: Int = -1
        if case .success(let recentOffer) = result {
          if !recentOffer.isEmpty, let recentJob = recentOffer.first {
            offer = recentJob
          }
          offerCount = recentOffer.count
        } else {
          offer = nil
        }
        let entry = JobEntry(date: currentDate, jobCount: offerCount, job: offer)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
        print("refreshed")
     }
  }
}
