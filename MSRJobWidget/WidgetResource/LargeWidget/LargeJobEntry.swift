//
//  LargeJobEntry.swift
//  Contributor
//
//  Created by KiwiTech on 10/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import WidgetKit

struct LargeJobEntry: TimelineEntry {
    var date: Date
    let jobCount: Int
    var firstName: String = ""
    var jobArray: [JobOffer]?

    static func mockLargeJobEntry() -> LargeJobEntry {
        let jobs = [JobOffer(id: 1, estimated_earnings_msr: 92,
                             estimated_minutes_to_complete: -1,
                             title: "Partner Survey",
                             description: "Your feedback is needed",
                             expiry_date: "15 minutes",
                             isFromSnapShot: true, noJob: false),
                    JobOffer(id: 2, estimated_earnings_msr: 200,
                             estimated_minutes_to_complete: -1,
                             title: "Retro Data Task",
                             description: "Share your iOS Battery Life",
                             expiry_date: "3 hours",
                             isFromSnapShot: true, noJob: false),
                    JobOffer(id: 3, estimated_earnings_msr: 60,
                             estimated_minutes_to_complete: -1,
                             title: "Profile Survey",
                             description: "Update your Extended Profile",
                             expiry_date: "24 hours",
                             isFromSnapShot: true, noJob: false)]
        return LargeJobEntry(date: Date(), jobCount: 3, firstName: WidgetConstant.defaultName, jobArray: jobs)
    }
}
