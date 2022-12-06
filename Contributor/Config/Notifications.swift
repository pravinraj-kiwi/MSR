//
//  Notifications.swift
//  Contributor
//
//  Created by John Martin on 1/15/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation

enum VisibleNotificationType: String {
  case offer, payment, quality
}

enum BackgroundNotificationType: String {
  case proofOfProfile = "proof_of_profile"
  case checkForPendingQualifications = "check_for_pending_qualifications"
  case quality = "quality"
}
