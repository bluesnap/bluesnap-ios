//
//  BSShopperConfigurationTests.swift
//  BluesnapSDK
//
//  Created by Roy Biber on 05/11/2018.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSShopperConfigurationTests: XCTestCase {

    override func setUp() {
        print("----------------------------------------------------")
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testSdkRequestResultTestType() {
        let sdkRequestShopperRequirements = BSSdkRequestShopperRequirements(withEmail: false,
                withShipping: false,
                fullBilling: false,
                billingDetails: nil,
                shippingDetails: nil,
                purchaseFunc: { _ in }
        )

        XCTAssertTrue(sdkRequestShopperRequirements is BSSdkRequestShopperRequirements)

        let sdkRequest = BSSdkRequest(withEmail: false,
                withShipping: false,
                fullBilling: false,
                priceDetails: BSPriceDetails(amount: 10, taxAmount: 10, currency: "USD"),
                billingDetails: nil,
                shippingDetails: nil,
                purchaseFunc: { _ in },
                updateTaxFunc: nil
        )

        XCTAssertTrue(sdkRequest is BSSdkRequest)

        let sdkResultShopperRequirements = BSBaseSdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertTrue(sdkResultShopperRequirements.isShopperRequirements())

        let sdkResultShopperRequirementsApplePay = BSApplePaySdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertTrue(sdkResultShopperRequirementsApplePay.getChosenPaymentMethodType() == BSPaymentType.ApplePay)

        let sdkResultShopperRequirementsPayPal = BSPayPalSdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertTrue(sdkResultShopperRequirementsPayPal.getChosenPaymentMethodType() == BSPaymentType.PayPal)

        let sdkResultShopperRequirementsCC = BSCcSdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertTrue(sdkResultShopperRequirementsCC.getChosenPaymentMethodType() == BSPaymentType.CreditCard)

        let sdkResult = BSBaseSdkResult(sdkRequestBase: sdkRequest)
        XCTAssertTrue(!sdkResult.isShopperRequirements())

        let sdkResultApplePay = BSApplePaySdkResult(sdkRequestBase: sdkRequest)
        XCTAssertTrue(sdkResultApplePay.getChosenPaymentMethodType() == BSPaymentType.ApplePay)

        let sdkResultPayPal = BSPayPalSdkResult(sdkRequestBase: sdkRequest)
        XCTAssertTrue(sdkResultPayPal.getChosenPaymentMethodType() == BSPaymentType.PayPal)

        let sdkResultCC = BSCcSdkResult(sdkRequestBase: sdkRequest)
        XCTAssertTrue(sdkResultCC.getChosenPaymentMethodType() == BSPaymentType.CreditCard)

    }

    func testGetChosenPaymentMethod() {
        let sdkConfiguration: BSSdkConfiguration = BSSdkConfiguration()
        sdkConfiguration.shopper = BSShopper()

        let visa: BSCreditCard = getBSCreditCardVisa()
        let masterCard: BSCreditCard = getBSCreditCardMasterCard()

        let billingDetails: BSBillingAddressDetails = getBillingDetails()

        let creditCardInfoVisa: BSCreditCardInfo = BSCreditCardInfo(creditCard: visa, billingDetails: billingDetails)
        let creditCardInfoMasterCard: BSCreditCardInfo = BSCreditCardInfo(creditCard: masterCard, billingDetails: billingDetails)

        let shopper = sdkConfiguration.shopper

        shopper?.chosenPaymentMethod = BSChosenPaymentMethod(chosenPaymentMethodType: BSPaymentType.CreditCard.rawValue, creditCard: visa)
        shopper?.existingCreditCards.append(creditCardInfoVisa)
        shopper?.existingCreditCards.append(creditCardInfoMasterCard)

        do {
            let getChosenPaymentMethod: BSChosenPaymentMethod? = try shopper!.getChosenPaymentMethod()
            XCTAssertTrue(getChosenPaymentMethod?.chosenPaymentMethodType == BSPaymentType.CreditCard.rawValue)
            NSLog("chosenPaymentMethodType: \(getChosenPaymentMethod?.chosenPaymentMethodType)")
            XCTAssertTrue(shopper?.chosenPaymentMethod?.creditCard! == getChosenPaymentMethod?.creditCardInfo?.creditCard!)
            NSLog("chosenPaymentMethod: creditCard - ccType=\(shopper?.chosenPaymentMethod?.creditCard?.ccType!), last4Digits=\(shopper?.chosenPaymentMethod?.creditCard?.last4Digits!)")
        } catch {
            XCTAssert(false, "error")
        }

        shopper?.chosenPaymentMethod = BSChosenPaymentMethod(chosenPaymentMethodType: BSPaymentType.CreditCard.rawValue, creditCard: masterCard)
        do {
            let getChosenPaymentMethod: BSChosenPaymentMethod? = try shopper!.getChosenPaymentMethod()
            XCTAssertTrue(getChosenPaymentMethod?.chosenPaymentMethodType == BSPaymentType.CreditCard.rawValue)
            NSLog("chosenPaymentMethodType: \(getChosenPaymentMethod?.chosenPaymentMethodType)")
            XCTAssertTrue(shopper?.chosenPaymentMethod?.creditCard! == getChosenPaymentMethod?.creditCardInfo?.creditCard!)
            NSLog("chosenPaymentMethod: creditCard - ccType=\(shopper?.chosenPaymentMethod?.creditCard?.ccType!), last4Digits=\(shopper?.chosenPaymentMethod?.creditCard?.last4Digits!)")
        } catch {
            XCTAssert(false, "error")
        }


    }

    private func getBillingDetails() -> BSBillingAddressDetails {
        let billlingDetails = BSBillingAddressDetails()
        billlingDetails.name = "Billing John"
        billlingDetails.country = "CA"
        billlingDetails.state = "ON"
        billlingDetails.address = "billing address"
        billlingDetails.city = "billing city"
        billlingDetails.zip = "123456"
        billlingDetails.email = "billing"
        return billlingDetails
    }

    private func getVisa() -> [String: String] {
        return ["ccn": "4111111111111111", "exp": "10/2020", "cvv": "111", "ccType": "VISA", "last4Digits": "1111", "issuingCountry": "US"]
    }

    private func getMasterCard() -> [String: String] {
        return ["ccn": "5555555555555557", "exp": "11/2021", "cvv": "123", "ccType": "MASTERCARD", "last4Digits": "5557", "issuingCountry": "BR"]
    }

    private func getBSCreditCardVisa() -> BSCreditCard {
        return getBSCreditCard(cc: getVisa())
    }

    private func getBSCreditCardMasterCard() -> BSCreditCard {
        return getBSCreditCard(cc: getMasterCard())
    }

    private func getBSCreditCard(cc: [String: String]) -> BSCreditCard {
        let creditCard: BSCreditCard = BSCreditCard()
        creditCard.ccType = cc["ccType"]
        creditCard.last4Digits = cc["last4Digits"]
        let expArr = cc["exp"]?.components(separatedBy: "/")
        creditCard.expirationMonth = expArr![0]
        creditCard.expirationYear = expArr![1]
        return creditCard
    }
}
