//
//  UserStats.swift
//  Contributor
//
//  Created by John Martin on 4/3/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import ObjectMapper
import SwiftyJSON
import IGListKit

class UserStats: NSObject, Mappable {
  var totalEarningsMSR: Int = 0
  var totalCompletedJobs: Int = 0
  var totalOfferedJobs: Int = 0
  var previousDayOfferedJobs: Int = 0
  var previous2DaysOfferedJobs: Int = 0
  var previous3DaysOfferedJobs: Int = 0
  var previous7DaysOfferedJobs: Int = 0
  var previous30DaysOfferedJobs: Int = 0
  var previousDayCompletedJobs: Int = 0
  var previous2DaysCompletedJobs: Int = 0
  var previous3DaysCompletedJobs: Int = 0
  var previous7DaysCompletedJobs: Int = 0
  var previous30DaysCompletedJobs: Int = 0
  var offersFinishedWithin2Hours: Int = 0
  var offersFinishedWithin1Day: Int = 0
  var offersFinishedWithin2Days: Int = 0
  var offersFinishedWithin3Days: Int = 0
  var offersFinishedWithin7Days: Int = 0
  var offersFinishedWithin30Days: Int = 0
  
  required init?(map: Map) {
    super.init()
  }
  
  var totalEarningsMSRString: String {
    return "\(totalEarningsMSR.stringWithCommas) MSR"
  }

  private func ratioTo1DecimalPoint(_ n: Int, _ d: Int) -> Double {
    if n > 0 && d > 0 {
      return (Double(n) / Double(d) * 10.0).rounded() / 10.0
    }
    return 0.0
  }
  
  var totalOffersCompletedRatio: Double {
    return ratioTo1DecimalPoint(totalCompletedJobs, totalOfferedJobs)
  }
  
  var offersFinishedWithin2HoursRatio: Double {
    return ratioTo1DecimalPoint(offersFinishedWithin2Hours, totalOfferedJobs)
  }

  var offersFinishedWithin1DayRatio: Double {
    return ratioTo1DecimalPoint(offersFinishedWithin1Day, totalOfferedJobs)
  }

  var offersFinishedWithin2DaysRatio: Double {
    return ratioTo1DecimalPoint(offersFinishedWithin2Days, totalOfferedJobs)
  }

  var offersFinishedWithin3DaysRatio: Double {
    return ratioTo1DecimalPoint(offersFinishedWithin3Days, totalOfferedJobs)
  }

  var offersFinishedWithin7DaysRatio: Double {
    return ratioTo1DecimalPoint(offersFinishedWithin7Days, totalOfferedJobs)
  }

  var offersFinishedWithin30DaysRatio: Double {
    return ratioTo1DecimalPoint(offersFinishedWithin30Days, totalOfferedJobs)
  }

  func mapping(map: Map) {
    totalEarningsMSR <- map["total_earnings_msr"]
    totalOfferedJobs <- map["total_offered_jobs"]
    totalCompletedJobs <- map["total_completed_jobs"]
    previousDayOfferedJobs <- map["previous_day_offered_jobs"]
    previous2DaysOfferedJobs <- map["previous_2_days_offered_jobs"]
    previous3DaysOfferedJobs <- map["previous_3_days_offered_jobs"]
    previous7DaysOfferedJobs <- map["previous_7_days_offered_jobs"]
    previous30DaysOfferedJobs <- map["previous_30_days_offered_jobs"]
    previousDayCompletedJobs <- map["previous_day_completed_jobs"]
    previous2DaysCompletedJobs <- map["previous_2_days_completed_jobs"]
    previous3DaysCompletedJobs <- map["previous_3_days_completed_jobs"]
    previous7DaysCompletedJobs <- map["previous_7_days_completed_jobs"]
    previous30DaysCompletedJobs <- map["previous_30_days_completed_jobs"]
    offersFinishedWithin2Hours <- map["offers_finished_within_2_hours"]
    offersFinishedWithin1Day <- map["offers_finished_within_1_day"]
    offersFinishedWithin2Days <- map["offers_finished_within_2_days"]
    offersFinishedWithin3Days <- map["offers_finished_within_3_days"]
    offersFinishedWithin7Days <- map["offers_finished_within_7_days"]
    offersFinishedWithin30Days <- map["offers_finished_within_30_days"]
  }
  
  public override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let rhs = object as? UserStats else {
      return false
    }
    
    if totalEarningsMSR != rhs.totalEarningsMSR || totalCompletedJobs != rhs.totalCompletedJobs {
      return false
    }
    
    return true
  }
}
