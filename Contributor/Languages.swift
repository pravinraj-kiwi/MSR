//
//  Languages.swift
//  Contributor
//
//  Created by Shashi Kumar on 25/06/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit
class Language: NSObject {
    
    open var languageCode: String
    open var language: String
    open var isSelected: Bool = false
    public static var emptyLanguage : Language { return Language(languageCode: "", language: "", selected: false) }
    
//     Constructor to initialize a country
//
//     - Parameters:
//     - countryCode: the country code
    public init(languageCode: String, language: String, selected: Bool) {
        
        self.languageCode = languageCode
        self.language = language
        self.isSelected = selected
    }
    
    open override var description: String{
        return self.language
    }
}
class Languages: NSObject {
    
    /// Language code to show in application to choese
    fileprivate(set) static var languages: [Language] = {
        
        var languages: [Language] = []
        languages.append(Language(languageCode: "en", language: "English (United States)", selected: false))
        languages.append(Language(languageCode: "pt-BR", language: "Portugese (Brazil)", selected: false))
        languages.append(Language(languageCode: Locale.current.languageCode ?? "", language: "Device Language", selected: false))
        
        return languages
    }()

    // Find a Language Available for Application or not
    //
    // - Parameter code: Language code, exe. en
    // - Returns: true/false
    class func isLanguageAvailable(_ code: String) -> Bool {
        for language in languages {
            if  code == language.languageCode {
                return true
            }
        }
        return false
    }

    // Find a Language based on it's Language code
    //
    // - Parameter code: Language code, exe. en
    // - Returns: Language
    class func languageFromLanguageCode(_ code: String) -> Language {
        for language in languages {
            if  code == language.languageCode {
                return language
            }
        }
        return Language.emptyLanguage
    }
    // Find a Language based on it's Language Name
    //
    // - Parameter languageName: languageName, exe. english
    // - Returns: Language
    class func languageFromLanguageName(_ languageName: String) -> Language {
        for language in languages {
            if languageName == language.language {
                return language
            }
        }
        return Language.emptyLanguage
    }
    
}
