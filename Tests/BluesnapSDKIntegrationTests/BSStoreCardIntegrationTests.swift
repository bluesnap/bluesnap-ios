//
//  BSUpdateShopperTests.swift
//  BluesnapSDK
//
//  Created by Roy Biber on 2018-12-25.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSStoreCardTests: XCTestCase {

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
    // MARK: Store Card
    //------------------------------------------------------

    func testStoreCardTrueVisa() {
        var cc: [String: String] = BluesnapSDKIntegrationTestsHelper.getVisa()
        var vaultedShopperId: Int = BSIntegrationTestingAPIHelper.createVaultedShopper(creditCard: cc, storeCard: true)!

        BSStoreCardTests.checkSdkData(vaultedShopperId: vaultedShopperId, creditCard: cc, storeCard:true)
    }

    func testStoreCardFalseVisa() {
        var cc: [String: String] = BluesnapSDKIntegrationTestsHelper.getVisa()
        var vaultedShopperId: Int = BSIntegrationTestingAPIHelper.createVaultedShopper(creditCard: cc, storeCard: false)!

        BSStoreCardTests.checkSdkData(vaultedShopperId: vaultedShopperId, creditCard: cc, storeCard:false)
    }

    //------------------------------------------------------
    // MARK: private functions API Calls
    //------------------------------------------------------

    private static func checkSdkData(vaultedShopperId: Int, creditCard: [String: String], storeCard:Bool) {
        let semaphore4 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(shopperId: vaultedShopperId, completion: {
            token, error in

            if let error = error {
                XCTFail("Create Token with shopper ID failed. error: \(error)")
            }
            BSStoreCardTests.getSdkData(vaultedShopperId: vaultedShopperId, creditCard: creditCard, storeCard:storeCard, completion: { error in
                semaphore4.signal()
            })

        })
        semaphore4.wait()
    }

    private static func getSdkData(vaultedShopperId: Int, creditCard: [String: String], storeCard:Bool, completion: @escaping (BSErrors?) -> Void) {
        BSApiManager.getSdkData(baseCurrency: nil, completion: {
            sdkData, errors in

            XCTAssertNil(errors, "Got errors while trying to get currencies")
            XCTAssertNotNil(sdkData, "Failed to get sdk data")

            let sdkDataShopper = sdkData?.shopper
            XCTAssertNotNil(sdkDataShopper, "Failed to get shopper")

            var bsCreditCard: BSCreditCard = BluesnapSDKIntegrationTestsHelper.getBSCreditCard(cc: creditCard)
            var actualBillingDetails: BSBillingAddressDetails = BluesnapSDKIntegrationTestsHelper.getBillingDetails()
            var actualShippingDetails: BSShippingAddressDetails = BluesnapSDKIntegrationTestsHelper.getShippingDetails()

            var existingCreditCards: [BSCreditCardInfo] = sdkDataShopper?.existingCreditCards ?? []
            XCTAssertEqual(existingCreditCards.count, storeCard ? 1 : 0)
            NSLog("Result: store Card = \(storeCard)")

            if storeCard == true {
                for creditCardInfo in existingCreditCards {
                    XCTAssertEqual(bsCreditCard.last4Digits, creditCardInfo.creditCard.last4Digits)
                    XCTAssertEqual(bsCreditCard.ccType, creditCardInfo.creditCard.ccType)
                    XCTAssertEqual(bsCreditCard.expirationYear, creditCardInfo.creditCard.expirationYear)
                    XCTAssertEqual(bsCreditCard.expirationMonth, creditCardInfo.creditCard.expirationMonth)
                    NSLog("Result: ccType=\(bsCreditCard.ccType!), last4Digits=\(bsCreditCard.last4Digits!), exp=\(bsCreditCard.getExpiration())")

                    var billingDetails: BSBillingAddressDetails = creditCardInfo.billingDetails ?? BSBillingAddressDetails()
                    XCTAssertEqual(billingDetails.name, actualBillingDetails.name)
                    XCTAssertTrue((billingDetails.country ?? "").caseInsensitiveCompare(actualBillingDetails.country ?? "") == .orderedSame)
                    XCTAssertTrue((billingDetails.state ?? "").caseInsensitiveCompare(actualBillingDetails.state ?? "") == .orderedSame)
                    XCTAssertEqual(billingDetails.address, actualBillingDetails.address)
                    XCTAssertEqual(billingDetails.city, actualBillingDetails.city)
                    XCTAssertEqual(billingDetails.zip, actualBillingDetails.zip)

                    NSLog("Result: getSdkDataBillingDetails - name=\(billingDetails.name!), country=\(billingDetails.country!), state=\(billingDetails.state!), address=\(billingDetails.address!), city=\(billingDetails.city!), zip=\(billingDetails.zip!)")

                }
            } else {
                XCTAssertTrue(existingCreditCards.count == 0)
            }

            XCTAssertEqual(actualShippingDetails.name, sdkDataShopper?.shippingDetails?.name)
            XCTAssertTrue((actualShippingDetails.country ?? "").caseInsensitiveCompare(sdkDataShopper?.shippingDetails?.country ?? "") == .orderedSame)
            XCTAssertTrue((actualShippingDetails.state ?? "").caseInsensitiveCompare(sdkDataShopper?.shippingDetails?.state ?? "") == .orderedSame)
            XCTAssertEqual(actualShippingDetails.address, sdkDataShopper?.shippingDetails?.address)
            XCTAssertEqual(actualShippingDetails.city, sdkDataShopper?.shippingDetails?.city)
            XCTAssertEqual(actualShippingDetails.zip, sdkDataShopper?.shippingDetails?.zip)

            NSLog("Result: getSdkDataShippingDetails - name=\(actualShippingDetails.name!), country=\(actualShippingDetails.country!), state=\(actualShippingDetails.state!), address=\(actualShippingDetails.address!), city=\(actualShippingDetails.city!), zip=\(actualShippingDetails.zip!)")


            XCTAssertEqual(actualBillingDetails.name, sdkDataShopper?.name)
            XCTAssertTrue((actualBillingDetails.country ?? "").caseInsensitiveCompare(sdkDataShopper?.country ?? "") == .orderedSame)
            XCTAssertTrue((actualBillingDetails.state ?? "").caseInsensitiveCompare(sdkDataShopper?.state ?? "") == .orderedSame)
            XCTAssertEqual(actualBillingDetails.address, sdkDataShopper?.address)
            XCTAssertEqual(actualBillingDetails.city, sdkDataShopper?.city)
            XCTAssertEqual(actualBillingDetails.email, sdkDataShopper?.email)
            XCTAssertEqual(actualBillingDetails.zip, sdkDataShopper?.zip)

            NSLog("Result: getSdkData - name=\(actualBillingDetails.name!), country=\(actualBillingDetails.country!), state=\(actualBillingDetails.state!), address=\(actualBillingDetails.address!), city=\(actualBillingDetails.city!), email=\(actualBillingDetails.email!), zip=\(actualBillingDetails.zip!)")

            completion(errors)
        })
    }

}
