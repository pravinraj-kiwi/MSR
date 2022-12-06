//
//  JobEntry.swift
//  Contributor
//
//  Created by KiwiTech on 10/20/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import WidgetKit

struct JobEntry: TimelineEntry {
  let date: Date
  let jobCount: Int
  let job: JobOffer?

  static func mockSnapShotJobEntry() -> JobEntry {
    return JobEntry(date: Date(), jobCount: 1,
                    job: JobOffer(id: -1, estimated_earnings_msr: 200,
                                   estimated_minutes_to_complete: -1,
                                   title: "Retro Data Task",
                                   description: "Share your iOS Battery Life",
                                   expiry_date: "15 minutes", isFromSnapShot: true, noJob: false))
  }
}
