//
//  ProfileItems.swift
//  Contributor
//
//  Created by John Martin on 1/19/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import UIKit

class ProfileItemUIDs {
  static let countryBR = "057f95e2b7a946db9c9556588effa61c"
  static let countryUS = "0c43ea783b1b50bd7e2fe2f279ba4fc6"
  static let countryUK = "530b106ba55dcde688507d37059c3d90"
  static let countryAU = "e7932c585ea48d396e42d692de780b06"
  static let countryCA = "c65ddc97a21d4018dbef569f1366aa5f"
  static let incomeUS = "eed3694f3d2f4d88aad7841202ef0d64"
  static let incomeUK = "e5fa8325b9164759b0a154fe763465e6"
  static let incomeAU = "70b56b59ac77445bb7a6aa88b78642f2"
  static let incomeCA = "f6ab976f204649f7b8208478b6f8b416"
  static let gender = "31b62756667848da9561c7de59b948dd"
  static let ageRange = "0f714d28078c451ba7ee94e4c05a9952"  // age range
  static let country = "57a8fa3c19b54cb3b117a55dfa29cb66"
  static let employment = "73865f3d1dd44ea897a2e8787ca16c51"
  static let education = "b3e6c4f8a8a040cba7e1b91c5a574f8e"
}

class ProfileItemRefs {
  static let incomeUS = "household_income_us"
  static let incomeUK = "household_income_uk"
  static let incomeAU = "household_income_au"
  static let incomeCA = "household_income_ca"
  static let incomeBR = "household_income_br"
  static let gender = "gender"
  static let ageRange = "age_range"  // age range
  static let age = "age"
  static let country = "country_of_residence"
  static let employment = "employment"
  static let education = "education"
  static let dob = "dob"
  static let postalCodeStringUS = "us_zip_code_of_residence_string"
  static let postalCodeStringUK = "uk_postal_code_of_residence_string"
  static let postalCodeStringAU = "au_postal_code_of_residence_string"
  static let postalCodeStringCA = "ca_postal_code_of_residence_string"
  static let postalCodeUS = "us_zip_code_of_residence"
  static let postalCodeUK = "uk_postal_code_of_residence"
  static let postalCodeAU = "au_postal_code_of_residence"
  static let postalCodeCA = "ca_postal_code_of_residence"
  static let stateUS = "us_state_of_residence"
  static let countyUS = "us_county_of_residence"
  static let cityUS = "us_city_of_residence"
  static let regionUK = "uk_region_of_residence"
  static let townUK = "uk_town_of_residence"
  static let stateAU = "au_state_of_residence"
  static let countyAU = "au_county_of_residence"
  static let cityAU = "au_city_of_residence"
  static let provinceCA = "ca_province_of_residence"
  static let cityCA = "ca_city_of_residence"

  static let postalCodeStrings = [
    postalCodeStringUS,
    postalCodeStringUK,
    postalCodeStringAU,
    postalCodeStringCA
  ]

  static let postalCodeStringRefByCountryUID = [
    ProfileItemUIDs.countryUS: ProfileItemRefs.postalCodeStringUS,
    ProfileItemUIDs.countryUK: ProfileItemRefs.postalCodeStringUK,
    ProfileItemUIDs.countryAU: ProfileItemRefs.postalCodeStringAU,
    ProfileItemUIDs.countryCA: ProfileItemRefs.postalCodeStringCA
  ]

  static let postalCodeRefByCountryUID = [
    ProfileItemUIDs.countryUS: ProfileItemRefs.postalCodeUS,
    ProfileItemUIDs.countryUK: ProfileItemRefs.postalCodeUK,
    ProfileItemUIDs.countryAU: ProfileItemRefs.postalCodeAU,
    ProfileItemUIDs.countryCA: ProfileItemRefs.postalCodeCA
  ]

  static let countrySpecificItems: [String: [String]] = [
    ProfileItemUIDs.countryUS: [
      ProfileItemRefs.incomeUS,
      ProfileItemRefs.postalCodeStringUS,
      ProfileItemRefs.postalCodeUS,
      ProfileItemRefs.stateUS,
      ProfileItemRefs.countyUS,
      ProfileItemRefs.cityUS
    ],
    ProfileItemUIDs.countryUK: [
      ProfileItemRefs.incomeUK,
      ProfileItemRefs.postalCodeStringUK,
      ProfileItemRefs.postalCodeUK,
      ProfileItemRefs.regionUK,
      ProfileItemRefs.townUK
    ],
    ProfileItemUIDs.countryAU: [
      ProfileItemRefs.incomeAU,
      ProfileItemRefs.postalCodeStringAU,
      ProfileItemRefs.postalCodeAU,
      ProfileItemRefs.stateAU,
      ProfileItemRefs.countyAU,
      ProfileItemRefs.cityAU
    ],
    ProfileItemUIDs.countryCA: [
      ProfileItemRefs.incomeCA,
      ProfileItemRefs.postalCodeStringCA,
      ProfileItemRefs.postalCodeCA,
      ProfileItemRefs.provinceCA,
      ProfileItemRefs.cityCA
    ],
    ProfileItemUIDs.countryBR: [
      ProfileItemRefs.incomeBR,
    ]
  ]
  
  static let minPostalCodeLengthByCountryUID = [
    ProfileItemUIDs.countryUS: 5,
    ProfileItemUIDs.countryUK: 5,
    ProfileItemUIDs.countryAU: 4,
    ProfileItemUIDs.countryCA: 6
  ]
}
