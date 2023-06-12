//
//  BSCcPayment.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

/**
 (PCI-compliant) Credit Card details: result of submitting the CC details to BlueSnap server
 */
public class BSCreditCard: NSObject, NSCopying, BSModel {
    private static let CARD_LAST_FOUR_DIGITS: String = "cardLastFourDigits";
    private static let EXPIRATION_MONTH: String = "expirationMonth";
    private static let EXPIRATION_YEAR: String = "expirationYear";
    private static let CARD_TYPE: String = "cardType";

    public var ccType: String?
    public var last4Digits: String?
    public var ccIssuingCountry: String?
    public var expirationMonth: String?
    public var expirationYear: String?

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSCreditCard()
        copy.ccType = ccType
        copy.last4Digits = last4Digits
        copy.ccIssuingCountry = ccIssuingCountry
        copy.expirationMonth = expirationMonth
        copy.expirationYear = expirationYear
        return copy
    }

    public func getExpiration() -> String {
        return (expirationMonth ?? "") + " / " + (expirationYear ?? "")
    }

    func getExpirationForSubmit() -> String {
        return (expirationMonth ?? "") + "/" + (expirationYear ?? "")
    }

    public func toJson() -> ([String: Any])! {
        var ccDetailsBody: [String: Any] = [:]

        if let expirationMonth = expirationMonth {
            ccDetailsBody[BSCreditCard.EXPIRATION_MONTH] = expirationMonth
        }
        if let expirationYear = expirationYear {
            ccDetailsBody[BSCreditCard.EXPIRATION_YEAR] = expirationYear
        }
        if let ccLast4Digits = last4Digits {
            ccDetailsBody[BSCreditCard.CARD_LAST_FOUR_DIGITS] = ccLast4Digits
        }
        if let ccType = ccType {
            ccDetailsBody[BSCreditCard.CARD_TYPE] = ccType
        }

        return ccDetailsBody
    }
}

func == (leftCreditCardA: BSCreditCard, rightCreditCard: BSCreditCard) -> Bool {
    var returnValue = false
    if (leftCreditCardA.last4Digits == rightCreditCard.last4Digits
            && leftCreditCardA.expirationMonth == rightCreditCard.expirationMonth
            && leftCreditCardA.expirationYear == rightCreditCard.expirationYear
            && leftCreditCardA.ccType == rightCreditCard.ccType) {
        returnValue = true
    }
    return returnValue
}

/**
 (PCI-compliant) Existing credit card info as we get it from BlueSnap API when getting the shopper information
 */
class BSCreditCardInfo: BSPaymentInfo, NSCopying {

    public var creditCard: BSCreditCard!
    public var billingDetails: BSBillingAddressDetails?

    private init() {
        super.init(paymentType: BSPaymentType.CreditCard)
    }

    public init(creditCard: BSCreditCard!, billingDetails: BSBillingAddressDetails?) {
        super.init(paymentType: BSPaymentType.CreditCard)
        self.creditCard = creditCard
        self.billingDetails = billingDetails
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSCreditCardInfo()
        copy.billingDetails = billingDetails?.copy(with: zone) as? BSBillingAddressDetails
        copy.creditCard = creditCard.copy(with: zone) as? BSCreditCard
        return copy
    }
}

/**
 New CC details for the purchase
 */
public class BSCcSdkResult: BSBaseSdkResult {
    override var storeCard: Bool! {
        get { // why? isn't it already handeled in validation?
            return super.isShopperRequirements() ? true : super.storeCard
        }
        set {
            super.storeCard = newValue
        }
    }
    public var creditCard: BSCreditCard = BSCreditCard()
    public var billingDetails: BSBillingAddressDetails! = BSBillingAddressDetails()
    public var shippingDetails: BSShippingAddressDetails?
    public var threeDSAuthenticationResult: String!

    public override init(sdkRequestBase: BSSdkRequestProtocol) {
        super.init(sdkRequestBase: sdkRequestBase)
        chosenPaymentMethodType = BSPaymentType.CreditCard

        if let billingDetails = sdkRequestBase.shopperConfiguration.billingDetails {
            self.billingDetails = billingDetails.copy() as? BSBillingAddressDetails
        }
        if !sdkRequestBase.shopperConfiguration.withShipping {
            self.shippingDetails = nil
        } else if let shippingDetails = BSApiManager.shopper?.shippingDetails {
            self.shippingDetails = shippingDetails.copy() as? BSShippingAddressDetails
        } else if let shippingDetails = sdkRequestBase.shopperConfiguration.shippingDetails {
            self.shippingDetails = shippingDetails.copy() as? BSShippingAddressDetails
        }
    }

    public func getBillingDetails() -> BSBillingAddressDetails! {
        return billingDetails
    }

    public func getShippingDetails() -> BSShippingAddressDetails? {
        return shippingDetails
    }

    public func setShippingDetails(shippingDetails: BSShippingAddressDetails?) {
        self.shippingDetails = shippingDetails
    }
}

/**
 Existing CC details for the purchase
 */
public class BSExistingCcSdkResult: BSCcSdkResult, NSCopying {
    override var storeCard: Bool! {
        get {
            return true
        }
        set {}
    }

    // for copy
    override private init(sdkRequestBase: BSSdkRequestProtocol) {
        super.init(sdkRequestBase: sdkRequestBase)
    }

    init(sdkRequestBase: BSSdkRequestProtocol, shopper: BSShopper!, existingCcDetails: BSCreditCardInfo!) {

        super.init(sdkRequestBase: sdkRequestBase)

        self.creditCard = existingCcDetails.creditCard.copy() as! BSCreditCard

        if let ccBillingDetails = existingCcDetails.billingDetails {
            self.billingDetails = ccBillingDetails.copy() as? BSBillingAddressDetails
            if !sdkRequestBase.shopperConfiguration.withEmail {
                self.billingDetails.email = nil
            } else if self.billingDetails.email == nil {
                self.billingDetails.email = shopper.email
            }
            if !sdkRequestBase.shopperConfiguration.fullBilling {
                self.billingDetails.address = nil
                self.billingDetails.city = nil
                self.billingDetails.state = nil
            }
        } else {
            if let initialBillingDetails = sdkRequestBase.shopperConfiguration.billingDetails {
                self.billingDetails = initialBillingDetails.copy() as? BSBillingAddressDetails
            } else {
                self.billingDetails = BSBillingAddressDetails()
            }
            if let name = shopper.name {
                billingDetails.name = name
            }
            if sdkRequestBase.shopperConfiguration.withEmail {
                if let email = shopper.email {
                    billingDetails.email = email
                }
            }
            if let country = shopper.country {
                billingDetails.country = country
                if sdkRequestBase.shopperConfiguration.fullBilling {
                    if let state = shopper.state {
                        billingDetails.state = state
                    }
                    if let address = shopper.address {
                        billingDetails.address = address
                    }
                    if let city = shopper.city {
                        billingDetails.city = city
                    }
                }
                if let zip = shopper.zip {
                    billingDetails.zip = zip
                }
            }
        }

        if sdkRequestBase.shopperConfiguration.withShipping {
            if let shopperShippingDetails = shopper.shippingDetails {
                self.shippingDetails = shopperShippingDetails.copy() as? BSShippingAddressDetails
            } else if let initialShippingDetails = sdkRequestBase.shopperConfiguration.shippingDetails {
                self.shippingDetails = initialShippingDetails.copy() as? BSShippingAddressDetails
            }
            if self.shippingDetails?.name == nil || self.shippingDetails?.name == "" {
                // copy from billing
                self.shippingDetails!.name = billingDetails.name
                self.shippingDetails!.country = billingDetails.country
                self.shippingDetails!.state = billingDetails.state
                self.shippingDetails!.zip = billingDetails.zip
                self.shippingDetails!.city = billingDetails.city
                self.shippingDetails!.address = billingDetails.address
                self.shippingDetails!.name = billingDetails.name
            }
//            if let phone = shopper.phone {
//                self.shippingDetails?.phone = phone
//            }
        }
    }


    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSExistingCcSdkResult(sdkRequestBase: BlueSnapSDK.sdkRequestBase!)
        copy.creditCard = self.creditCard.copy() as! BSCreditCard
        copy.billingDetails = self.billingDetails.copy() as? BSBillingAddressDetails
        if let shippingDetails = self.shippingDetails {
            copy.shippingDetails = shippingDetails.copy() as? BSShippingAddressDetails
        }
        return copy
    }

}

