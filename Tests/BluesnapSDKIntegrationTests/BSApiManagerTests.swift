//
//  BSApiManagerTests.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 20/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSApiManagerTests: XCTestCase {

    private var tokenExpiredExpectation: XCTestExpectation?
    private var tokenWasRecreated = false

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("----------------------------------------------------")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //------------------------------------------------------
    // MARK: Is Token Expired
    //------------------------------------------------------
    func testIsTokenExpiredExpectsFalse() {

        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in

            NSLog("testIsTokenExpiredExpectsFalse; token str=\(String(describing: token!.getTokenStr()))")

            _ = BSApiCaller.isTokenExpired(bsToken: token, completion: { isExpired in
                assert(isExpired == false)
                semaphore.signal()
            })
        })
        semaphore.wait()
    }

    func testIsTokenExpiredExpectsTrue() {

        let expiredToken = "fcebc8db0bcda5f8a7a5002ca1395e1106ea668f21200d98011c12e69dd6bceb_"
        let token = BluesnapSDKIntegrationTestsHelper.initBSToken(tokenStr: expiredToken)
        
        BSApiManager.setBsToken(bsToken: token)

        let semaphore = DispatchSemaphore(value: 0)
        _ = BSApiCaller.isTokenExpired(bsToken: token, completion: { isExpired in
            assert(isExpired == true)
            semaphore.signal()
        })
        semaphore.wait()
    }

    //------------------------------------------------------
    // MARK: SDK Data
    //------------------------------------------------------

    // test get SDk Data with a valid token
    // If the test fails on the billing/shipping values, run the UI test testShortReturningShopperExistingCcFlowWithEdit in the demo app
    func testGetSdkData() {
        let semaphore = DispatchSemaphore(value: 0)
        let shopperId: Int? = BSIntegrationTestingAPIHelper.createVaultedShopper(creditCard: BluesnapSDKIntegrationTestsHelper.getVisa()) //22061813 //22208751
        BSIntegrationTestingAPIHelper.createToken(shopperId: shopperId, completion: { token, error in

            if let error = error {
                XCTFail("Create Token with shopper ID failed. error: \(error)")
            }

            BSApiManager.getSdkData(baseCurrency: nil, completion: { sdkData, errors in

                XCTAssertNil(errors, "Got errors while trying to get currencies")
                XCTAssertNotNil(sdkData, "Failed to get sdk data")

                let getBilling = BluesnapSDKIntegrationTestsHelper.getBillingDetails()
                let getShipping = BluesnapSDKIntegrationTestsHelper.getShippingDetails()
                XCTAssertEqual(700000, sdkData?.kountMID)

                let bsCurrencies = sdkData?.currencies
                let gbpCurrency: BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
                XCTAssertNotNil(gbpCurrency)
                NSLog("testGetTokenAndCurrencies; GBP currency name is: \(String(describing: gbpCurrency.name)), its rate is \(String(describing: gbpCurrency.rate))")

                let shopper = sdkData?.shopper
                XCTAssertNotNil(shopper, "Failed to get shopper")
                XCTAssertEqual(getBilling.name, shopper?.name)
                XCTAssertEqual(getBilling.city, shopper?.city)
                XCTAssertEqual(getBilling.state, shopper?.state)
                XCTAssertEqual(getBilling.zip, shopper?.zip)
                XCTAssertEqual(getBilling.country?.lowercased(), shopper?.country?.lowercased())
                //XCTAssertEqual("S@gmail.com", shopper?.email)
                XCTAssertEqual(getBilling.address, shopper?.address)

                let shipping = shopper?.shippingDetails
                //XCTAssertNil(shipping)
                XCTAssertEqual(getShipping.name, shipping?.name)
                XCTAssertEqual(getShipping.city, shipping?.city)
                //XCTAssertEqual(nil, shipping?.state)
                //XCTAssertEqual("il", shipping?.country)
                XCTAssertEqual(getShipping.zip, shipping?.zip)
                XCTAssertEqual(getShipping.address, shipping?.address)
//                XCTAssertEqual(getShipping.phone, shopper?.phone)

                if let existingCreditCards = shopper?.existingCreditCards {
                    let ccInfo: BSCreditCardInfo = existingCreditCards[0]
                    let ccDetails: BSCreditCard = ccInfo.creditCard
                    let getVisa = BluesnapSDKIntegrationTestsHelper.getBSCreditCard(cc: BluesnapSDKIntegrationTestsHelper.getVisa())
                    XCTAssertEqual(getVisa.last4Digits, ccDetails.last4Digits)
                    XCTAssertEqual(getVisa.ccType, ccDetails.ccType)
                    XCTAssertEqual(getVisa.expirationMonth, ccDetails.expirationMonth)
                    //XCTAssertEqual("2022", ccDetails.expirationYear)
                    let billing = ccInfo.billingDetails
                    XCTAssertEqual(getBilling.name, billing?.name)
                    //XCTAssertEqual("somecity", billing?.city)
                    //XCTAssertEqual("ON", billing?.state)
                    //XCTAssertEqual("ca", billing?.country)
                    //XCTAssertEqual("4282300", billing?.zip)
                    //XCTAssertEqual("58 somestreet", billing?.address)
                } else {
                    XCTFail("No cc in shopper")
                }

                let supportedPaymentMethods = sdkData?.supportedPaymentMethods
                let ccIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.CreditCard, supportedPaymentMethods: supportedPaymentMethods)
                XCTAssertTrue(ccIsSupported)
                let applePayIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.ApplePay, supportedPaymentMethods: supportedPaymentMethods)
                XCTAssertTrue(applePayIsSupported)
                let payPalIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.PayPal, supportedPaymentMethods: supportedPaymentMethods)
                XCTAssertTrue(payPalIsSupported)

                semaphore.signal()
            })
        })
        semaphore.wait()
    }

    //------------------------------------------------------
    // MARK: PayPal
    //------------------------------------------------------

    func testGetPayPalToken() {

        let priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let sdkRequest = BSSdkRequest(withEmail: false, withShipping: false, fullBilling: false, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: { _ in }, updateTaxFunc: nil)
        let purchaseDetails: BSPayPalSdkResult = BSPayPalSdkResult(sdkRequestBase: sdkRequest)

        let semaphore = DispatchSemaphore(value: 0)

        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            assert(error == nil, "Error in creting bs token")
            assert(token != nil, "Token is nil")
            BSApiManager.createPayPalToken(purchaseDetails: purchaseDetails, withShipping: false, completion: { resultToken, resultError in

                XCTAssertNil(resultError)
                NSLog("*** testGetPayPalToken; Test result: resultToken=\(resultToken ?? ""), resultError= \(String(describing: resultError))")
                semaphore.signal()
            })
        })

        semaphore.wait()
    }

    func testGetPayPalTokenWithInvalidTokenNoRegeneration() {

        createExpiredTokenNoRegeneration()
        let priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let sdkRequest = BSSdkRequest(withEmail: false, withShipping: false, fullBilling: false, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: { _ in }, updateTaxFunc: nil)
        let purchaseDetails: BSPayPalSdkResult = BSPayPalSdkResult(sdkRequestBase: sdkRequest)

        let semaphore = DispatchSemaphore(value: 0)

        BSApiManager.createPayPalToken(purchaseDetails: purchaseDetails, withShipping: false, completion: { resultToken, resultError in

            XCTAssertNotNil(resultError)
            assert(resultError == BSErrors.unAuthorised)
            NSLog("*** testGetPayPalTokenWithInvalidTokenNoRegeneration; Test result: resultToken=\(resultToken ?? ""), resultError= \(String(describing: resultError))")

            assert(self.tokenWasRecreated == false)
            semaphore.signal()
        })

        semaphore.wait()
    }

    func testGetPayPalTokenWithExpiredToken() {

        createExpiredTokenWithRegeneration()

        let priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let sdkRequest = BSSdkRequest(withEmail: false, withShipping: false, fullBilling: false, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: { _ in }, updateTaxFunc: nil)
        let purchaseDetails: BSPayPalSdkResult = BSPayPalSdkResult(sdkRequestBase: sdkRequest)

        let semaphore = DispatchSemaphore(value: 0)

        BSApiManager.createPayPalToken(purchaseDetails: purchaseDetails, withShipping: false, completion: { resultToken, resultError in

            XCTAssertNil(resultError)
            NSLog("*** testGetPayPalTokenWithExpiredToken; Test result: resultToken=\(resultToken ?? ""), resultError= \(String(describing: resultError))")

            assert(self.tokenWasRecreated == true)
            semaphore.signal()
        })

        semaphore.wait()
    }



    func testGetPayPalTokenTwiceWithSameToken() {

        let priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let sdkRequest = BSSdkRequest(withEmail: false, withShipping: false, fullBilling: false, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: { _ in }, updateTaxFunc: nil)
        let purchaseDetails: BSPayPalSdkResult = BSPayPalSdkResult(sdkRequestBase: sdkRequest)
        var tokenWasRecreated = false

        let semaphore = DispatchSemaphore(value: 0)

        BSApiManager.setGenerateBsTokenFunc(generateTokenFunc: { completion in
            NSLog("*** testGetPayPalTokenTwiceWithSameToken: Recreating token!!!")
            tokenWasRecreated = true
            BSIntegrationTestingAPIHelper.createToken(completion: completion)
        })

        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            BSApiManager.createPayPalToken(purchaseDetails: purchaseDetails, withShipping: false, completion: { resultToken, resultError in

                XCTAssertNil(resultError)
                NSLog("*** testGetPayPalTokenTwiceWithSameToken; First Token result: resultToken=\(resultToken ?? ""), resultError= \(String(describing: resultError))")
                semaphore.signal()
            })
        })

        semaphore.wait()

        // clear the existing PayPalToken so that the API will try to create a new one
        BSApiManager.payPalToken = nil

        // Try to create a second opaypal token with the same BLS token
        let semaphore2 = DispatchSemaphore(value: 0)

        BSApiManager.createPayPalToken(purchaseDetails: purchaseDetails, withShipping: false, completion: { resultToken, resultError in

            XCTAssertNil(resultError)
            NSLog("*** testGetPayPalTokenTwiceWithSameToken; Second Token result: resultToken=\(resultToken ?? ""), resultError= \(String(describing: resultError))")
            semaphore2.signal()
        })

        semaphore2.wait()

        XCTAssertTrue(tokenWasRecreated)
    }

    //------------------------------------------------------
    // MARK: Supported Payment Methods
    //------------------------------------------------------

    func testGetSupportedPaymentMethods() {

        let semaphore = DispatchSemaphore(value: 0)

        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            BSApiManager.getSupportedPaymentMethods(completion: { resultPaymentMethods, resultError in

                XCTAssertNil(resultError)
                NSLog("*** testGetSupportedPaymentMethods; Test result: resultPaymentMethods=\(resultPaymentMethods ?? []), resultError= \(String(describing: resultError))")

                // check that CC and ApplePay are supported
                let ccIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.CreditCard, supportedPaymentMethods: resultPaymentMethods)
                XCTAssertTrue(ccIsSupported)
                let applePayIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.ApplePay, supportedPaymentMethods: resultPaymentMethods)
                XCTAssertTrue(applePayIsSupported)
                let payPalIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.PayPal, supportedPaymentMethods: resultPaymentMethods)
                XCTAssertTrue(payPalIsSupported)

                semaphore.signal()
            })
        })

        semaphore.wait()
    }

    func testGetSupportedPaymentMethodsWithExpiredToken() {

        createExpiredTokenWithRegeneration()

        let semaphore = DispatchSemaphore(value: 0)

        BSApiManager.getSupportedPaymentMethods(completion: { resultPaymentMethods, resultError in

            XCTAssertNil(resultError)
            NSLog("*** testGetSupportedPaymentMethodsWithExpiredToken; Test result: resultPaymentMethods=\(resultPaymentMethods ?? []), resultError= \(String(describing: resultError))")

            // check that CC and ApplePay are supported
            let ccIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.CreditCard, supportedPaymentMethods: resultPaymentMethods)
            XCTAssertTrue(ccIsSupported)
            let applePayIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.ApplePay, supportedPaymentMethods: resultPaymentMethods)
            XCTAssertTrue(applePayIsSupported)
            let payPalIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.PayPal, supportedPaymentMethods: resultPaymentMethods)
            XCTAssertTrue(payPalIsSupported)

            semaphore.signal()
        })

        semaphore.wait()
    }


    //------------------------------------------------------
    // MARK: Submit CC details
    //------------------------------------------------------

    func testSubmitCCDetailsSuccess() {

        let ccn = "4111 1111 1111 1111"
        let cvv = "111"
        let exp = "10/2030"

        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in

            self.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, completion: {
                (result, error) in

                XCTAssert(error == nil, "error: \(String(describing: error))")
                let ccType = result.ccType
                let last4 = result.last4Digits
                let country = result.ccIssuingCountry
                NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
                assert(last4 == "1111", "last4 should be 1111")
                assert(ccType == "VISA", "CC Type should be VISA")
                assert(country == "US", "country should be US")
                semaphore.signal()
            })
        })
        semaphore.wait()
    }

    func testSubmitCCDetailsSuccessWithExpiredToken() {

        createExpiredTokenWithRegeneration()

        let ccn = "4111 1111 1111 1111"
        let cvv = "111"
        let exp = "10/2030"

        let semaphore = DispatchSemaphore(value: 0)
        self.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, completion: {
            (result, error) in

            XCTAssert(error == nil, "error: \(String(describing: error))")
            let ccType = result.ccType
            let last4 = result.last4Digits
            let country = result.ccIssuingCountry
            NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
            assert(last4 == "1111", "last4 should be 1111")
            assert(ccType == "VISA", "CC Type should be VISA")
            assert(country == "US", "country should be US")
            XCTAssert(self.tokenWasRecreated == true)
            semaphore.signal()
        })
        semaphore.wait()
    }

    func testSubmitCCDetailsErrorInvalidCcNumber() {

        submitCCDetailsExpectError(ccn: "4111", cvv: "111", exp: "12/2020", expectedError: BSErrors.invalidCcNumber)
    }

    func testSubmitCCDetailsErrorEmptyCcNumber() {

        submitCCDetailsExpectError(ccn: "", cvv: "111", exp: "12/2020", expectedError: BSErrors.invalidCcNumber)
    }

    func testSubmitCCDetailsErrorInvalidCvv() {

        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "3", exp: "12/2020", expectedError: BSErrors.invalidCvv)
    }

    func testSubmitCCDetailsErrorInvalidExp() {

        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "111", exp: "1220", expectedError: BSErrors.invalidExpDate)
    }


    //------------------------------------------------------
    // MARK: Submit CCN
    //------------------------------------------------------

    func testSubmitCCNSuccess() {

        let ccn = "4111 1111 1111 1111"

        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in

            BSApiManager.submitCcn(ccNumber: ccn, completion: {
                (result, error) in

                XCTAssert(error == nil, "error: \(String(describing: error))")
                let ccType = result.ccType
                let last4 = result.last4Digits
                let country = result.ccIssuingCountry
                NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
                assert(last4 == "1111", "last4 should be 1111")
                assert(ccType == "VISA", "CC Type should be VISA")
                assert(country == "US", "country should be US")
                semaphore.signal()
            })
        })
        semaphore.wait()
    }

    func testSubmitCCNError() {

        let ccn = "4111"
        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            BSApiManager.submitCcn(ccNumber: ccn, completion: {
                (result, error) in
                XCTAssert(error == BSErrors.invalidCcNumber, "error: \(String(describing: error)) should have been BSErrors.invalidCcNumber")
                semaphore.signal()
            })
        })
        semaphore.wait()
    }

    func testSubmitEmptyCCNError() {

        let ccn = ""
        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            BSApiManager.submitCcn(ccNumber: ccn, completion: {
                (result, error) in
                XCTAssert(error == BSErrors.invalidCcNumber, "error: \(String(describing: error)) should have been BSErrors.invalidCcNumber")
                semaphore.signal()
            })
        })
        semaphore.wait()
    }

    //------------------------------------------------------
    // MARK: BlueSnap Token
    //------------------------------------------------------


//    func testGetTokenWithBadCredentials() {
//
//        listenForBsTokenExpiration(expected: false)
//        do {
//            let _ = try BSApiManager.createBSToken(domain: BSApiManager.BS_SANDBOX_DOMAIN, user: "dummy", password: "dummypass")
//            print("We should have crashed here")
//            fatalError()
//        } catch let error as BSErrors {
//            if error == BSErrors.invalidInput {
//                print("Got the correct error")
//            } else {
//                print("Got wrong error \(error.localizedDescription)")
//                fatalError()
//            }
//        } catch let error {
//            print("Got wrong error \(error.localizedDescription)")
//            fatalError()
//        }
//    }


    //------------------------------------------------------
    // MARK: private functions
    //------------------------------------------------------

    private func submitCCDetailsExpectError(ccn: String!, cvv: String!, exp: String!, expectedError: BSErrors) {

        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in

            self.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, completion: {
                (result, error) in

                if let error = error {
                    XCTAssertEqual(error, expectedError)
                    NSLog("Got the right error!")
                } else {
                    XCTAssert(false, "Should have thrown error")
                }
                semaphore.signal()
            })
        })
        semaphore.wait()
    }


    

    func createExpiredTokenNoRegeneration() {

        let expiredToken = "fcebc8db0bcda5f8a7a5002ca1395e1106ea668f21200d98011c12e69dd6bceb_"
        BSApiManager.setBsToken(bsToken: BluesnapSDKIntegrationTestsHelper.initBSToken(tokenStr: expiredToken))
        BSApiManager.setGenerateBsTokenFunc(generateTokenFunc: { completion in
            NSLog("*** Not recreating token!!!")
            completion(nil, nil)
        })
    }

    func createExpiredTokenWithRegeneration() {
        tokenWasRecreated = false
        let expiredToken = "fcebc8db0bcda5f8a7a5002ca1395e1106ea668f21200d98011c12e69dd6bceb_"
        BSApiManager.setBsToken(bsToken: BluesnapSDKIntegrationTestsHelper.initBSToken(tokenStr: expiredToken))
        BSApiManager.setGenerateBsTokenFunc(generateTokenFunc: { completion in
            NSLog("*** Recreating token!!!")
            self.tokenWasRecreated = true
            BSIntegrationTestingAPIHelper.createToken(completion: completion)
        })
    }

    private func submitCcDetails(ccNumber: String, expDate: String, cvv: String, completion: @escaping (BSCreditCard, BSErrors?) -> Void) {

        BSApiManager.submitPurchaseDetails(ccNumber: ccNumber, expDate: expDate, cvv: cvv, last4Digits: nil, cardType: nil, billingDetails: nil, shippingDetails: nil, storeCard: nil, fraudSessionId: nil, completion: completion)
    }
}
