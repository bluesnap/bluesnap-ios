//
//  BSAddress.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation


/**
 Shopper address details for purchase.
 State is mandatory only if the country has state (USA, Canada and Brazil).
 For not-full billing details, only name, country and zip are filled, email is optional
 For full billing details, everything is mandatory except email which is optional.
 For shipping details all field are mandatory.
 */
public class BSBaseAddressDetails: NSObject, BSModel {
    public static let FIRST_NAME: String = "firstName";
    public static let LAST_NAME: String = "lastName";
    public static let ADDRESS: String = "address";
    public static let ADDRESS_1: String = "address1";
    public static let ADDRESS_2: String = "address2";
    public static let STATE: String = "state";
    public static let ZIP: String = "zip";
    public static let COUNTRY: String = "country";
    public static let CITY: String = "city";
    public static let EMAIL: String = "email";
    public static let PHONE: String = "phone";

    public var name: String! = ""
    public var address: String?
    public var city: String?
    public var zip: String?
    public var country: String?
    public var state: String?

    public override init() {
        super.init()
    }

    public func getSplitName() -> (firstName: String, lastName: String)? {
        return BSStringUtils.splitName(name)
    }

    public func toJson() -> ([String: Any])! {
        var baseAddressDetails: [String: Any] = [:]
        if let splitName = getSplitName() {
            baseAddressDetails[BSBaseAddressDetails.FIRST_NAME] = splitName.firstName
            baseAddressDetails[BSBaseAddressDetails.LAST_NAME] = splitName.lastName
        }
        if let country = country {
            baseAddressDetails[BSBaseAddressDetails.COUNTRY] = country
        }
        if let state = state {
            baseAddressDetails[BSBaseAddressDetails.STATE] = state
        }
        if let city = city {
            baseAddressDetails[BSBaseAddressDetails.CITY] = city
        }
        if let zip = zip {
            baseAddressDetails[BSBaseAddressDetails.ZIP] = zip
        }
        if let address = address {
            baseAddressDetails[BSBaseAddressDetails.ADDRESS] = address
        }
        return baseAddressDetails
    }
}

/**
 Shopper billing details - basically address + email
 */
public class BSBillingAddressDetails: BSBaseAddressDetails, NSCopying {

    public var email: String?

    public override init() {
        super.init()
    }

    public init(email: String?, name: String!, address: String?, city: String?, zip: String?, country: String?, state: String?) {
        super.init()
        self.email = email
        self.name = name
        self.address = address
        self.city = city
        self.zip = zip
        self.country = country
        self.state = state
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSBillingAddressDetails(email: email, name: name, address: address, city: city, zip: zip, country: country, state: state)
        return copy
    }

    public override func toJson() -> ([String: Any])! {
        var billingAddressDetails: [String: Any] = super.toJson()
        if let email = email {
            billingAddressDetails[BSBaseAddressDetails.EMAIL] = email
        }
        if let address = address {
            billingAddressDetails[BSBaseAddressDetails.ADDRESS_1] = address
        }
        return billingAddressDetails
    }
}

/**
 Shopper shipping details - basically address
 */
public class BSShippingAddressDetails: BSBaseAddressDetails, NSCopying {

    public override init() {
        super.init()
    }

    public init(name: String!, address: String?, city: String?, zip: String?, country: String?, state: String?) {
        super.init()
        self.name = name
        self.address = address
        self.city = city
        self.zip = zip
        self.country = country
        self.state = state
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSShippingAddressDetails(name: name, address: address, city: city, zip: zip, country: country, state: state)
        return copy
    }

    public override func toJson() -> ([String: Any])! {
        var shippingAddressDetails: [String: Any] = super.toJson()
        if let address = address {
            shippingAddressDetails[BSBaseAddressDetails.ADDRESS_1] = address
        }
        return shippingAddressDetails
    }
}


