//
//  CountryManager.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 23/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

public class BSCountryManager: NSObject {
    
    public static let US_COUNTRY_CODE: String = "US"

    fileprivate static let instance = BSCountryManager()
    fileprivate var countryCodes : [String] = []
    fileprivate let COUNTRY_STATES : [String : [String : String]] = [
        "US": [
            "AK" : "Alaska",
            "AL" : "Alabama",
            "AR" : "Arkansas",
            "AS" : "American Samoa",
            "AZ" : "Arizona",
            "CA" : "California",
            "CO" : "Colorado",
            "CT" : "Connecticut",
            "DC" : "District of Columbia",
            "DE" : "Delaware",
            "FL" : "Florida",
            "GA" : "Georgia",
            "GU" : "Guam",
            "HI" : "Hawaii",
            "IA" : "Iowa",
            "ID" : "Idaho",
            "IL" : "Illinois",
            "IN" : "Indiana",
            "KS" : "Kansas",
            "KY" : "Kentucky",
            "LA" : "Louisiana",
            "MA" : "Massachusetts",
            "MD" : "Maryland",
            "ME" : "Maine",
            "MI" : "Michigan",
            "MN" : "Minnesota",
            "MO" : "Missouri",
            "MS" : "Mississippi",
            "MT" : "Montana",
            "NC" : "North Carolina",
            "ND" : "North Dakota",
            "NE" : "Nebraska",
            "NH" : "New Hampshire",
            "NJ" : "New Jersey",
            "NM" : "New Mexico",
            "NV" : "Nevada",
            "NY" : "New York",
            "OH" : "Ohio",
            "OK" : "Oklahoma",
            "OR" : "Oregon",
            "PA" : "Pennsylvania",
            "PR" : "Puerto Rico",
            "RI" : "Rhode Island",
            "SC" : "South Carolina",
            "SD" : "South Dakota",
            "TN" : "Tennessee",
            "TX" : "Texas",
            "UT" : "Utah",
            "VA" : "Virginia",
            "VI" : "Virgin Islands",
            "VT" : "Vermont",
            "WA" : "Washington",
            "WI" : "Wisconsin",
            "WV" : "West Virginia",
            "WY" : "Wyoming"
        ],
        "BR" : [
            "AC" : "Acre",
            "AM" : "Amazonas",
            "BA" : "Bahia",
            "CE" : "Ceará",
            "DF" : "Distrito Federal",
            "ES" : "Espírito Santo",
            "GO" : "Goiás",
            "MG" : "Minas Gerais",
            "PB" : "Paraíba",
            "PI" : "Piauí",
            "RJ" : "Rio de Janeiro",
            "RN" : "Rio Grande do Norte",
            "RO" : "Rondônia",
            "RR" : "Roraima",
            "RS" : "Rio Grande do Sull",
            "SE" : "Sergipe",
            "SP" : "São Paulo",
            "TO" : "Tocantins",
            "XA" : "Maranhão",
            "XB" : "Mato Grosso do Sul",
            "XC" : "Mato Grosso",
            "XD" : "Santa Catarina",
            "XE" : "Pará",
            "XF" : "Pernambuco",
            "XG" : "Paraná",
            "XH" : "Alagoas",
            "XI" : "Amapá"
        ],
        "CA" : [
            "AB" : "Alberta",
            "BC" : "British Columbia",
            "MB" : "Manitoba",
            "NB" : "New Brunswick",
            "NF" : "Newfoundland",
            "NL" : "Newfoundland and Labrador",
            "NS" : "Nova Scotia",
            "NT" : "Northwest Territories",
            "NU" : "Nunavut",
            "ON" : "Ontario",
            "PE" : "Prince Edward Island",
            "QC" : "Quebec",
            "SK" : "Saskatchewan",
            "YT" : "Yukon Territory"
        ]
    ]
    fileprivate let COUNTRIES_WITHOUT_ZIP : [String] = ["ao","ag","aw","ac","bs","bz","bj","bw","bo","bf","bi","cm","cf","km","cg","cd","ck","cw","dj","dm","tp","gq","er","fj","tf","gm","gh","gd","gy","hm","hk","ki","ly","mo","mw","ml","mr","nr","an","nu","kp","qa","rw","kn","st","sc","sl","sb","sr","sy","tl","tg","tk","to","tv","ug","ae","vu","ye","zw"
    ]
    
    internal var removeCountriesWithoutFlag = true
    
    
    override fileprivate init() {
        super.init()
        initCountryCodes()
    }
    
    open class func getInstance() -> BSCountryManager {
        return instance
    }

    func initCountryCodes() {
        
        countryCodes = NSLocale.isoCountryCodes
        if removeCountriesWithoutFlag {
            var tmpCodes : [String] = []
            for countryCode in countryCodes {
                if let _ = BSImageLibrary.getFlag(countryCode: countryCode) {
                    tmpCodes.append(countryCode)
                }
            }
            countryCodes = tmpCodes
        }
    }
    
//    func handleCountriesWithoutFlag(remove: Bool) {
//        if remove != removeCountriesWithoutFlag {
//            removeCountriesWithoutFlag = remove
//            initCountryCodes()
//        }
//        removeCountriesWithoutFlag = remove
//    }
    
    public func getCountryCodes() -> [String] {
        return self.countryCodes
    }
    
    public func getCountryName(countryCode: String) -> String? {
        let current = Locale(identifier: "en_US")
        return current.localizedString(forRegionCode: countryCode) ?? nil
    }
    
    public func countryHasStates(countryCode : String) -> Bool {
        
        if let _ = COUNTRY_STATES[countryCode.uppercased()] {
            return true
        }
        return false
    }
    
    public func getCountryStates(countryCode : String) -> [(name: String, code: String)]? {
        
        if let states = COUNTRY_STATES[countryCode.uppercased()] {
            var result : [(name: String, code: String)] = []
            for (code, name) in states {
                result.append((name: name, code: code))
            }
            result = result.sorted {
                $0.name < $1.name
            }
            return result
        }
        return nil
    }
    
    public func getStateName(countryCode : String, stateCode: String) -> String? {
        
        if let states = COUNTRY_STATES[countryCode.uppercased()] {
            return states[stateCode]
        }
        return nil
    }
    
    public func countryHasNoZip(countryCode : String) -> Bool {
         return self.COUNTRIES_WITHOUT_ZIP.firstIndex(of: countryCode.lowercased()) != nil
    }
}
