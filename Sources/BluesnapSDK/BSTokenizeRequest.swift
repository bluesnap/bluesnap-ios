//
//  BSTokenizeRequest.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 08/03/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import Foundation

/**
 Class holds data to be submitted to BLS server under the current token, to be used later for server-to-server actions
 - Specific payment type details are in sub-classes
 - (optional) Price details
 - (optional) Shopper billing details
 - (optional) Shopper shipping details
 */
  public class BSTokenizeRequest : NSObject {
    public var paymentDetails: BSTokenizePaymentDetails?
    public var billingDetails: BSBillingAddressDetails?
    public var shippingDetails: BSShippingAddressDetails?
    public var storeCard: Bool?
}

/**
 Base class for payment details to be submitted to BLS server
 */
  public class BSTokenizePaymentDetails : NSObject { }

/**
 Base Credit Card payment details to be submitted to BLS server
 - ccType: Credit Card Type
 - expDate: CC expiration date in format MM/YYYY  (in case of new/existing CC)
 */
  public class BSTokenizeBaseCCDetails : BSTokenizePaymentDetails {
    
    public static let LAST_4_DIGITS_KEY = "last4Digits"
    public static let CARD_TYPE_KEY = "ccType"
    public static let ISSUING_COUNTRY_KEY = "issuingCountry"
    
    var ccType: String!
    var expDate: String!
    public init(ccType: String!, expDate: String!) {
        self.ccType = ccType
        self.expDate = expDate
    }
}

/**
 New Credit Card payment details to be submitted to BLS server
 - ccNumber: Full credit card number
 - cvv: credit card security code
 */
  public class BSTokenizeNewCCDetails
: BSTokenizeBaseCCDetails {
    var ccNumber: String!
    var cvv: String!
    public init(ccNumber: String!, cvv: String!, ccType: String!, expDate: String!) {
        super.init(ccType: ccType, expDate: expDate)
        self.ccNumber = ccNumber
        self.cvv = cvv
    }
}

/**
 Existing Credit Card payment details to be submitted to BLS server
 - lastFourDigits: last for digits of existing credit card number
 */
  public class BSTokenizeExistingCCDetails : BSTokenizeBaseCCDetails {
    var lastFourDigits: String!
    public init(lastFourDigits: String!, ccType: String!, expDate: String!) {
        super.init(ccType: ccType, expDate: expDate)
        self.lastFourDigits = lastFourDigits
    }
}

/**
 ApplePay payment details to be submitted to BLS server
 - applePayToken: ApplePay token
 */
  public class BSTokenizeApplePayDetails : BSTokenizePaymentDetails {
    var applePayToken: String!
    public init(applePayToken: String!) {
        self.applePayToken = applePayToken
    }
}
