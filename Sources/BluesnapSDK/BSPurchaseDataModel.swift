//
//  BSPurchaseDataModel.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 18/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

/**
 Available payment types
 */
public enum BSPaymentType: String {
    case CreditCard = "CC"
    case ApplePay = "APPLE_PAY"
    case PayPal = "PAYPAL"
}

/**
 Base class for the different payments; for now only BSCreditCardInfo inherits from this.
 */
public class BSPaymentInfo: NSObject {
    let paymentType: BSPaymentType!

    public init(paymentType: BSPaymentType!) {
        self.paymentType = paymentType
    }
}

/**
 Base class for payment request; this will be the result of the payment flow (one of the inherited classes: BSCcSdkResult/BSApplePaySdkResult/BSPayPalSdkResult)
 */
public class BSBaseSdkResult: NSObject {
    private var isSdkRequestIsShopperRequirements: Bool! = nil
    private var isSdkRequestIsSubscriptionCharge: Bool! = nil
    private var isSdkRequestSubscriptionHasPriceDetails: Bool? = nil
    var storeCard: Bool! = nil
    var fraudSessionId: String?
    var priceDetails: BSPriceDetails!
    var chosenPaymentMethodType: BSPaymentType?

    /**
    * for Regular Checkout Flow
    */
    internal init(sdkRequestBase: BSSdkRequestProtocol) {
        super.init()
        self.isSdkRequestIsShopperRequirements = (sdkRequestBase is BSSdkRequestShopperRequirements)
        self.isSdkRequestIsSubscriptionCharge = (sdkRequestBase is BSSdkRequestSubscriptionCharge)
        self.isSdkRequestSubscriptionHasPriceDetails = isSdkRequestIsSubscriptionCharge ? (sdkRequestBase as! BSSdkRequestSubscriptionCharge).hasPriceDetails() : nil
        self.storeCard = self.isSdkRequestIsShopperRequirements
        self.priceDetails = hasPriceDetails() ? sdkRequestBase.priceDetails.copy() as? BSPriceDetails : nil
        self.fraudSessionId = BlueSnapSDK.fraudSessionId
    }

    public func getFraudSessionId() -> String? {
        return fraudSessionId;
    }

    // MARK: getters and setters

    public func getAmount() -> Double! {
        return (hasPriceDetails()) ? priceDetails.amount.doubleValue : nil
    }

    public func getTaxAmount() -> Double! {
        return (hasPriceDetails()) ? priceDetails.taxAmount.doubleValue : nil
    }

    public func getCurrency() -> String! {
        return (hasPriceDetails()) ? priceDetails.currency : nil
    }

    public func getChosenPaymentMethodType() -> BSPaymentType! {
        return chosenPaymentMethodType
    }

    public func isShopperRequirements() -> Bool! {
        return isSdkRequestIsShopperRequirements
    }
    
    public func isSubscriptionCharge() -> Bool! {
        return isSdkRequestIsSubscriptionCharge
    }
    
    public func isSubscriptionHasPriceDetails() -> Bool? {
        return isSdkRequestSubscriptionHasPriceDetails
    }
    
    public func hasPriceDetails() -> Bool {
        return !(isShopperRequirements() || (isSubscriptionCharge() && !isSubscriptionHasPriceDetails()!))
    }
}

/**
 price details: amount, tax and currency
 */
public class BSPriceDetails: NSObject, NSCopying {

    public var amount: NSNumber! = 0.0
    public var taxAmount: NSNumber! = 0.0
    public var currency: String! = "USD"

    public func setDetailsWithAmount(amount: NSNumber!, taxAmount: NSNumber!, currency: NSString?/*, baseCurrency: NSString?*/) {
        self.amount = amount
        self.taxAmount = taxAmount
        self.currency = currency! as String
    }

    public init(amount: Double!, taxAmount: Double!, currency: String?) {
        super.init()
        self.amount = NSNumber.init(value: amount)
        self.taxAmount = NSNumber.init(value: taxAmount)
        self.currency = currency ?? "USD"
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSPriceDetails(amount: amount.doubleValue, taxAmount: taxAmount.doubleValue, currency: currency)
        return copy
    }

    public func changeCurrencyAndConvertAmounts(newCurrency: BSCurrency!) {

        if let currencies = BSApiManager.bsCurrencies {
            let originalRate = currencies.getCurrencyByCode(code: self.currency)?.getRate() ?? 1.0
            self.currency = newCurrency.code
            let newRate = newCurrency.getRate() / originalRate
            self.amount = NSNumber.init(value: self.amount.doubleValue * newRate)
            self.taxAmount = NSNumber.init(value: self.taxAmount.doubleValue * newRate)
        }
    }
}


/**
  Class holds initial or setup data for the flow:
    - Flow flavors (withShipping, withBilling, withEmail)
    - Price details
    - (optional) Shopper details
    - (optional) function for updating tax amount based on shipping country/state. Only called when 'withShipping
 */
public class BSSdkRequest: NSObject, BSSdkRequestProtocol {
    public var shopperConfiguration: BSShopperConfiguration!
    public var allowCurrencyChange: Bool = true
    public var hideStoreCardSwitch: Bool = false
    public var activate3DS: Bool = false
    public var priceDetails: BSPriceDetails! = BSPriceDetails(amount: 0, taxAmount: 0, currency: nil)
    public var applePayCustomizePayLine: String? = nil

    public var purchaseFunc: (BSBaseSdkResult?) -> Void
    public var updateTaxFunc: ((String, String?, BSPriceDetails) -> Void)?

    public init(
            withEmail: Bool,
            withShipping: Bool,
            fullBilling: Bool,
            priceDetails: BSPriceDetails!,
            billingDetails: BSBillingAddressDetails?,
            shippingDetails: BSShippingAddressDetails?,
            purchaseFunc: @escaping (BSBaseSdkResult?) -> Void,
            updateTaxFunc: ((String, String?, BSPriceDetails) -> Void)?) {

        self.shopperConfiguration = BSShopperConfiguration(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, billingDetails: billingDetails, shippingDetails: shippingDetails)
        self.priceDetails = priceDetails
        self.purchaseFunc = purchaseFunc
        self.updateTaxFunc = updateTaxFunc
    }
}

public class BSSdkRequestShopperRequirements: NSObject, BSSdkRequestProtocol {
    public var shopperConfiguration: BSShopperConfiguration!
    public var purchaseFunc: (BSBaseSdkResult?) -> Void

    public var activate3DS: Bool {
        get {
            return false
        }
        set {
        }
    }
    
    public var applePayCustomizePayLine: String? {
        get {
            return nil
        }
        set {
        }
    }
    
    public init(
            withEmail: Bool,
            withShipping: Bool,
            fullBilling: Bool,
            billingDetails: BSBillingAddressDetails?,
            shippingDetails: BSShippingAddressDetails?,
            purchaseFunc: @escaping (BSBaseSdkResult?) -> Void) {


        self.shopperConfiguration = BSShopperConfiguration(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, billingDetails: billingDetails, shippingDetails: shippingDetails)
        self.purchaseFunc = purchaseFunc
    }
}

public class BSSdkRequestSubscriptionCharge: BSSdkRequest {
    private var sdkRequestHasPriceDetails: Bool = true
    private var storedAllowCurrencyChange: Bool = true
    
    override public var hideStoreCardSwitch: Bool {
        get {
            return false
        }
        set {
        }
    }
    
    override public var allowCurrencyChange: Bool {
        get {
            return hasPriceDetails() ? storedAllowCurrencyChange : false
        }
        set {
            storedAllowCurrencyChange = newValue
        }
    }
    
    override public var activate3DS: Bool {
        get {
            return false
        }
        set {
        }
    }
    
    convenience public init(
        withEmail: Bool,
        withShipping: Bool,
        fullBilling: Bool,
        billingDetails: BSBillingAddressDetails?,
        shippingDetails: BSShippingAddressDetails?,
        purchaseFunc: @escaping (BSBaseSdkResult?) -> Void) {
        
        self.init(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, priceDetails: nil, billingDetails: billingDetails, shippingDetails: shippingDetails, purchaseFunc: purchaseFunc, updateTaxFunc: nil)
        
        sdkRequestHasPriceDetails = false
        allowCurrencyChange = false
    }
    
    public func hasPriceDetails() -> Bool {
        return sdkRequestHasPriceDetails
    }
}

extension BSSdkRequestProtocol {
    public var updateTaxFunc: ((String, String?, BSPriceDetails) -> Void)? { return nil }
    public var priceDetails: BSPriceDetails! { return nil }
    public var allowCurrencyChange: Bool { get { return false } set { } }
    public var hideStoreCardSwitch: Bool { get { return false } set { } }

    public mutating func adjustSdkRequest() {

        let defaultCountry = NSLocale.current.regionCode ?? BSCountryManager.US_COUNTRY_CODE

        if self.shopperConfiguration.withShipping {
            if self.shopperConfiguration.shippingDetails == nil {
                self.shopperConfiguration.shippingDetails = BSShippingAddressDetails()
            }
        } else if self.shopperConfiguration.shippingDetails != nil {
            self.shopperConfiguration.shippingDetails = nil
        }

        if self.shopperConfiguration.billingDetails == nil {
            self.shopperConfiguration.billingDetails = BSBillingAddressDetails()
        }

        if self.shopperConfiguration.billingDetails!.country ?? "" == "" {
            self.shopperConfiguration.billingDetails!.country = defaultCountry
        }
    }
}

public protocol BSSdkRequestProtocol {
    var shopperConfiguration: BSShopperConfiguration! {get set}
    var purchaseFunc: (BSBaseSdkResult?) -> Void { get set }

    var priceDetails: BSPriceDetails! { get }
    var updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)? { get }

    var allowCurrencyChange: Bool { get set }
    var hideStoreCardSwitch: Bool { get set }
    var activate3DS: Bool { get set }
    var applePayCustomizePayLine: String? { get set }

}

public class BSShopperConfiguration {
    public var withEmail: Bool = true
    public var withShipping: Bool = false
    public var fullBilling: Bool = false

    public var billingDetails: BSBillingAddressDetails?
    public var shippingDetails: BSShippingAddressDetails?

    public init(
            withEmail: Bool,
            withShipping: Bool,
            fullBilling: Bool,
            billingDetails: BSBillingAddressDetails?,
            shippingDetails: BSShippingAddressDetails?) {

        self.withEmail = withEmail
        self.withShipping = withShipping
        self.fullBilling = fullBilling
        self.billingDetails = billingDetails
        self.shippingDetails = shippingDetails
    }
}
