//
//  BSUpdateShopperTests.swift
//  BluesnapSDK
//
//  Created by Roy Biber on 2018-12-25.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSUpdateShopperTests: XCTestCase {

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
    // MARK: Update Shopper
    //------------------------------------------------------

    func testUpdateShopperApplePay() {
        var set2: Bool = true
        var cc: [String: String] = BluesnapSDKIntegrationTestsHelper.getVisa()
        var vaultedShopperId: Int = BSIntegrationTestingAPIHelper.createVaultedShopper(creditCard: cc, set2: set2)!
        var shopper: BSShopper = BluesnapSDKIntegrationTestsHelper.createShopperForUpdate(add2: set2, vaultedShopperId: vaultedShopperId, chosenPaymentMethodType: BSPaymentType.ApplePay.rawValue)
        shopper.shippingDetails = BluesnapSDKIntegrationTestsHelper.getShippingDetails(add2: set2)
        set2 = !set2

        BSUpdateShopperTests.updateShopper(shopper: shopper, set2: set2)
        BSUpdateShopperTests.checkSdkData(shopper: shopper, set2: set2)
    }

    func testUpdateShopperPayPal() {
        var set2: Bool = false
        var cc: [String: String] = BluesnapSDKIntegrationTestsHelper.getMasterCard()
        var vaultedShopperId: Int = BSIntegrationTestingAPIHelper.createVaultedShopper(creditCard: cc, set2: set2)!
        var shopper: BSShopper = BluesnapSDKIntegrationTestsHelper.createShopperForUpdate(add2: set2, vaultedShopperId: vaultedShopperId, chosenPaymentMethodType: BSPaymentType.PayPal.rawValue)
        //shopper.shippingDetails = BluesnapSDKIntegrationTestsHelper.getShippingDetails(add2: set2)
        set2 = !set2

        BSUpdateShopperTests.updateShopper(shopper: shopper, set2: set2)
        BSUpdateShopperTests.checkSdkData(shopper: shopper, set2: set2)
    }

    func testUpdateCreditCard() {
        var set2: Bool = true
        var cc: [String: String] = BluesnapSDKIntegrationTestsHelper.getVisa()
        var vaultedShopperId: Int = BSIntegrationTestingAPIHelper.createVaultedShopper(creditCard: cc, set2: set2)!

        cc = BluesnapSDKIntegrationTestsHelper.getMasterCard()
        var shopper: BSShopper = BluesnapSDKIntegrationTestsHelper.createShopperForUpdate(add2: set2, vaultedShopperId: vaultedShopperId,
                chosenPaymentMethodType: BSPaymentType.CreditCard.rawValue, creditCard: BluesnapSDKIntegrationTestsHelper.getBSCreditCard(cc: cc))
        shopper.shippingDetails = BluesnapSDKIntegrationTestsHelper.getShippingDetails(add2: set2)
        set2 = !set2

        BSUpdateShopperTests.updateShopperCreditCard(creditCard: cc, shopper: shopper, set2: set2)
        BSUpdateShopperTests.checkSdkData(shopper: shopper, set2: set2)
    }

    func testUpdateAll() {
        var set2: Bool = false
        var cc: [String: String] = BluesnapSDKIntegrationTestsHelper.getMasterCard()
        var vaultedShopperId: Int = BSIntegrationTestingAPIHelper.createVaultedShopper(creditCard: cc, set2: set2)!
        var shopper: BSShopper = BluesnapSDKIntegrationTestsHelper.createShopperForUpdate(add2: set2, vaultedShopperId: vaultedShopperId, chosenPaymentMethodType: BSPaymentType.PayPal.rawValue)

        set2 = !set2
        BSUpdateShopperTests.updateShopper(shopper: shopper, set2: set2)
        BSUpdateShopperTests.checkSdkData(shopper: shopper, set2: set2)

        set2 = !set2
        cc = BluesnapSDKIntegrationTestsHelper.getVisa()
        shopper = BluesnapSDKIntegrationTestsHelper.createShopperForUpdate(add2: set2, vaultedShopperId: vaultedShopperId,
                chosenPaymentMethodType: BSPaymentType.CreditCard.rawValue, creditCard: BluesnapSDKIntegrationTestsHelper.getBSCreditCard(cc: cc))
        shopper.shippingDetails = BluesnapSDKIntegrationTestsHelper.getShippingDetails(add2: set2)
        BSUpdateShopperTests.updateShopperCreditCard(creditCard: cc, shopper: shopper, set2: set2)
        BSUpdateShopperTests.checkSdkData(shopper: shopper, set2: set2)

        set2 = !set2
        shopper = BluesnapSDKIntegrationTestsHelper.createShopperForUpdate(add2: set2, vaultedShopperId: vaultedShopperId, chosenPaymentMethodType: BSPaymentType.ApplePay.rawValue)
        BSUpdateShopperTests.updateShopper(shopper: shopper, set2: set2)
        BSUpdateShopperTests.checkSdkData(shopper: shopper, set2: set2)
    }

    //------------------------------------------------------
    // MARK: private functions API Calls
    //------------------------------------------------------

    private static func checkSdkData(shopper: BSShopper, set2: Bool = false) {
        let semaphore4 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(shopperId: shopper.vaultedShopperId, completion: {
            token, error in

            if let error = error {
                XCTFail("Create Token with shopper ID failed. error: \(error)")
            }
            BSUpdateShopperTests.getSdkData(shopper: shopper, set2: set2, completion: { error in
                semaphore4.signal()
            })

        })
        semaphore4.wait()
    }

    private static func updateShopper(shopper: BSShopper, set2: Bool = false) {
        
        let semaphore3 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(shopperId: shopper.vaultedShopperId, completion: {
            token, error in
            NSLog("token: \(token!.tokenStr)")
            BSApiManager.shopper = shopper
            BSApiManager.updateShopper(completion: {
                (result, error) in

                XCTAssert(error == nil, "error: \(String(describing: error))")
                semaphore3.signal()
            })
        })
        semaphore3.wait()
    }

    private static func updateShopperCreditCard(creditCard: [String: String], shopper: BSShopper, set2: Bool = false) {

        let semaphore3 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(shopperId: shopper.vaultedShopperId, completion: { token, error in
            NSLog("token: \(token!.tokenStr)")
            
            BSIntegrationTestingAPIHelper.submitCCDetails(ccDetails: creditCard, billingDetails: BluesnapSDKIntegrationTestsHelper.getBillingDetails(add2: set2), shippingDetails: shopper.shippingDetails, storeCard: true, completion: { error2 in
                BSApiManager.shopper = shopper
                
                BSApiManager.updateShopper { result, error3 in
                    XCTAssert(error3 == nil, "error: \(String(describing: error3))")
                    semaphore3.signal()
                }
            })
        })
        
        semaphore3.wait()
    }

    private static func getSdkData(shopper: BSShopper, set2: Bool = false, completion: @escaping (BSErrors?) -> Void) {
        BSApiManager.getSdkData(baseCurrency: nil, completion: {
            sdkData, errors in

            XCTAssertNil(errors, "Got errors while trying to get currencies")
            XCTAssertNotNil(sdkData, "Failed to get sdk data")

            let sdkDataShopper = sdkData?.shopper
            XCTAssertNotNil(sdkDataShopper, "Failed to get shopper")
            XCTAssertEqual(shopper.chosenPaymentMethod?.chosenPaymentMethodType, sdkDataShopper?.chosenPaymentMethod?.chosenPaymentMethodType)
            NSLog("Result: getSdkData - chosenPaymentMethodType=\(sdkDataShopper?.chosenPaymentMethod?.chosenPaymentMethodType!)")
            if BSPaymentType.CreditCard.rawValue == shopper.chosenPaymentMethod?.chosenPaymentMethodType, let sdkDataCreditCard = sdkDataShopper?.chosenPaymentMethod?.creditCard,
               let creditCard = shopper.chosenPaymentMethod?.creditCard {
                XCTAssertEqual(creditCard.last4Digits, sdkDataCreditCard.last4Digits)
                XCTAssertEqual(creditCard.ccType, sdkDataCreditCard.ccType)
                NSLog("Result: getSdkData - ccType=\(creditCard.ccType!), last4Digits=\(creditCard.last4Digits!)")

                var existingCreditCards: [BSCreditCardInfo] = sdkDataShopper?.existingCreditCards ?? []
                for creditCardInfo in existingCreditCards {
                    if creditCard.last4Digits == creditCardInfo.creditCard.last4Digits {
                        var billingDetails: BSBillingAddressDetails = creditCardInfo.billingDetails ?? BSBillingAddressDetails()
                        var actualBillingDetails: BSBillingAddressDetails = BluesnapSDKIntegrationTestsHelper.getBillingDetails(add2: set2)
                        XCTAssertEqual(billingDetails.name, actualBillingDetails.name)
                        XCTAssertTrue((billingDetails.country ?? "").caseInsensitiveCompare(actualBillingDetails.country ?? "") == .orderedSame)
                        XCTAssertTrue((billingDetails.state ?? "").caseInsensitiveCompare(actualBillingDetails.state ?? "") == .orderedSame)
                        XCTAssertEqual(billingDetails.address, actualBillingDetails.address)
                        XCTAssertEqual(billingDetails.city, actualBillingDetails.city)
                        XCTAssertEqual(billingDetails.zip, actualBillingDetails.zip)

                        NSLog("Result: getSdkDataBillingDetails - name=\(billingDetails.name!), country=\(billingDetails.country!), state=\(billingDetails.state!), address=\(billingDetails.address!), city=\(billingDetails.city!), zip=\(billingDetails.zip!)")
                    }
                }

            }

            if let shippingDetails = shopper.shippingDetails {
                XCTAssertEqual(shippingDetails.name, sdkDataShopper?.shippingDetails?.name)
                XCTAssertTrue((shippingDetails.country ?? "").caseInsensitiveCompare(sdkDataShopper?.shippingDetails?.country ?? "") == .orderedSame)
                XCTAssertTrue((shippingDetails.state ?? "").caseInsensitiveCompare(sdkDataShopper?.shippingDetails?.state ?? "") == .orderedSame)
                XCTAssertEqual(shippingDetails.address, sdkDataShopper?.shippingDetails?.address)
                XCTAssertEqual(shippingDetails.city, sdkDataShopper?.shippingDetails?.city)
                XCTAssertEqual(shippingDetails.zip, sdkDataShopper?.shippingDetails?.zip)

                NSLog("Result: getSdkDataShippingDetails - name=\(shippingDetails.name!), country=\(shippingDetails.country!), state=\(shippingDetails.state!), address=\(shippingDetails.address!), city=\(shippingDetails.city!), zip=\(shippingDetails.zip!)")
            }

            XCTAssertEqual(shopper.name, sdkDataShopper?.name)
            XCTAssertTrue((shopper.country ?? "").caseInsensitiveCompare(sdkDataShopper?.country ?? "") == .orderedSame)
            XCTAssertTrue((shopper.state ?? "").caseInsensitiveCompare(sdkDataShopper?.state ?? "") == .orderedSame)
            XCTAssertEqual(shopper.address, sdkDataShopper?.address)
            XCTAssertEqual(shopper.address2, sdkDataShopper?.address2)
            XCTAssertEqual(shopper.city, sdkDataShopper?.city)
            XCTAssertEqual(shopper.email, sdkDataShopper?.email)
            XCTAssertEqual(shopper.zip, sdkDataShopper?.zip)
            XCTAssertEqual(shopper.phone, sdkDataShopper?.phone)

            NSLog("Result: getSdkData - name=\(shopper.name!), country=\(shopper.country!), state=\(shopper.state!), address=\(shopper.address!), city=\(shopper.city!), email=\(shopper.email!), zip=\(shopper.zip!), phone=\(shopper.phone!)")

            completion(errors)
        })
    }
}
