//
//  AppLanguageManager.swift
//  Contributor
//
//  Created by Shashi Kumar on 25/06/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import Foundation
final class AppLanguageManager {
    static let shared = AppLanguageManager()

    private(set) var currentLanguage: String
    private(set) var currentBundle: Bundle = Bundle.main
    var bundle: Bundle {
        return currentBundle
    }

    private init() {
        if let appLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            currentLanguage = appLanguage
        } else {
            currentLanguage = Locale.current.languageCode!
        }
    }

    func setAppLanguage(_ languageCode: String) {
        setCurrentLanguage(languageCode)
        setCurrentBundlePath(languageCode)
        
    }

    private func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.setValue(languageCode,
                                       forKey: "AppLanguage")
    }
    // get selected language from UserDefaults
    func getLanguage() -> String? {
        if let language = UserDefaults.standard.string(forKey: "AppLanguage"){
            return language
        }
        return nil
    }
    private func setCurrentBundlePath(_ languageCode: String) {
        guard let bundle = Bundle.main.path(forResource: languageCode,
                                            ofType: "lproj"),
            let langBundle = Bundle(path: bundle) else {
            currentBundle = Bundle.main
            return
        }
        currentBundle = langBundle
    }
}
