//
//  OnboardingView+API.swift
//  Contributor
//
//  Created by KiwiTech on 1/12/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit

extension AppIntroViewController {
    
 func configureOnBoardTemplate(completion: @escaping ([OnboardingMessage]?,
                                                        Error?) -> Void) {
    if let templateName = UserManager.shared.deepLinkOnboardTemplate {
        callOnBoardingApi(templateName) { (templates, error) in
            if error == nil {
              completion(templates, nil)
            } else {
              completion(nil, error)
            }
        }
    } else {
        callOnBoardingApi(Constants.onboardingDefaultTempate) { (templates, error) in
            if error == nil {
              completion(templates, nil)
            } else {
              completion(nil, error)
            }
        }
     }
  }

  func callOnBoardingApi(_ templateName: String, completion: @escaping ([OnboardingMessage]?,
                                                                        Error?) -> Void) {
    NetworkManager.shared.getOnboardingTemplate(template: templateName) {  [weak self] (templateData, error) in
        guard let _ = self else { return }
        if error == nil {
          completion(templateData, nil)
        } else {
          completion(nil, error)
        }
    }
  }
}
