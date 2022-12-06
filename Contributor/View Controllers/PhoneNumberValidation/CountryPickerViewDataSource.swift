//
//  CountryPickerViewDataSource.swift
//  Contributor
//
//  Created by KiwiTech on 2/25/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol PickerDatasourceDelegate: class {
    func getSelectedCountryCode(_ countryData: CountryData)
}

class CountryPickerViewDataSource: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

    weak var pickerDelegate: PickerDatasourceDelegate?
    var countryCodeArray = [CountryData]()
    let plistName = "CountryList"
    
    func getCountryDetail() {
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist") {
            if let xml = FileManager.default.contents(atPath: path),
            let preferences = try? PropertyListDecoder().decode(CountryResponse.self, from: xml) {
                if let countries = preferences.countryList {
                    countryCodeArray = countries
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return countryCodeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        let countrylist = countryCodeArray[row]
        return "\(countrylist.country.localized()) (\(countrylist.countryCode))"
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        let selectedCountry = countryCodeArray[row]
        pickerDelegate?.getSelectedCountryCode(selectedCountry)
    }
}
