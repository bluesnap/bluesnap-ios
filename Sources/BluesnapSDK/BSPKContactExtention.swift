//
// Created by oz on 15/06/2017.
// Copyright (c) 2017 Bluesnap. All rights reserved.
//

import Foundation

import PassKit


public protocol DictionaryConvertible {
    func toDictionary() throws -> [String: Any]
}


extension DictionaryConvertible {

    public func toJSON() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self.toDictionary(), options: JSONSerialization.WritingOptions.prettyPrinted);
    }
}


extension Dictionary {
    mutating public func setValueIfExists(value: Value?, for key: Key) {
        if let unwrappedValue = value {
            self[key] = unwrappedValue;
        }
    }
}


extension PKContact: DictionaryConvertible {
    public func toDictionary() -> [String: Any] {
        var map = [String: Any]();
        map.setValueIfExists(value: self.emailAddress, for: "email");
//        map.setValueIfExists(value: self.phoneNumber?.stringValue, for: "phone");
        if let address = self.postalAddress {
            var addressMap = [String: Any]();
            addressMap["line1"] = address.street;
            addressMap["city"] = address.city;
            addressMap["state"] = address.state;
            addressMap["zip"] = address.postalCode;
            addressMap["country"] = address.isoCountryCode;
            map["address"] = addressMap;
        }
        return map;
    }
}




