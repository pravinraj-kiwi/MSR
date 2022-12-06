//
//  OtpValidationModel.swift
//  Contributor
//
//  Created by KiwiTech on 2/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

struct PhoneValidationModel {
    var countryCode: String? = ""
    var phoneNumber: String? = ""
}

struct CountryResponse: Codable {
    var countryList: [CountryData]?
    private enum CodingKeys: String, CodingKey {
        case countryList = "CountryList"
    }
}

struct CountryData: Codable {
    var country: String = ""
    var countryCode: String = ""
    var phoneNumber: String? = ""
    private enum CodingKeys: String, CodingKey {
        case country = "Country"
        case countryCode = "Code"
        case phoneNumber
    }
}
