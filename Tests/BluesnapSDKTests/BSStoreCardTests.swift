//
//  BSShopperConfigurationTests.swift
//  BluesnapSDK
//
//  Created by Roy Biber on 05/11/2018.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSStoreCardTests: XCTestCase {

    override func setUp() {
        print("----------------------------------------------------")
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testStoreCardInSDKRequest() {
        // In BSSdkRequestShopperRequirements hiding the button should not be possible
        var sdkRequestShopperRequirements = BSSdkRequestShopperRequirements(withEmail: false,
                withShipping: false,
                fullBilling: false,
                billingDetails: nil,
                shippingDetails: nil,
                purchaseFunc: { _ in }
        )

        XCTAssertTrue(!sdkRequestShopperRequirements.hideStoreCardSwitch)

        sdkRequestShopperRequirements.hideStoreCardSwitch = false
        XCTAssertTrue(!sdkRequestShopperRequirements.hideStoreCardSwitch)

        sdkRequestShopperRequirements.hideStoreCardSwitch = true
        XCTAssertTrue(!sdkRequestShopperRequirements.hideStoreCardSwitch)

        print("----------------------------------------------------")

        var sdkResultShopperRequirementsApplePay = BSApplePaySdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertNil(sdkResultShopperRequirementsApplePay.storeCard)

        var sdkResultShopperRequirementsPayPal = BSPayPalSdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertNil(sdkResultShopperRequirementsPayPal.storeCard)

        var sdkResultShopperRequirementsCC = BSCcSdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertTrue(sdkResultShopperRequirementsCC.storeCard)

        sdkResultShopperRequirementsCC.storeCard = false
        XCTAssertTrue(sdkResultShopperRequirementsCC.storeCard)

        sdkResultShopperRequirementsCC.storeCard = true
        XCTAssertTrue(sdkResultShopperRequirementsCC.storeCard)

        sdkResultShopperRequirementsCC.storeCard = false
        XCTAssertTrue(sdkResultShopperRequirementsCC.storeCard)

        var sdkResultExistingShopperRequirementsCC: BSExistingCcSdkResult = BSExistingCcSdkResult(sdkRequestBase: sdkRequestShopperRequirements, shopper: BSShopper(), existingCcDetails: BSCreditCardInfo(creditCard: BSCreditCard(), billingDetails: nil))
        XCTAssertTrue(sdkResultExistingShopperRequirementsCC.storeCard)

        sdkResultExistingShopperRequirementsCC.storeCard = false
        XCTAssertTrue(sdkResultExistingShopperRequirementsCC.storeCard)

        sdkResultExistingShopperRequirementsCC.storeCard = true
        XCTAssertTrue(sdkResultExistingShopperRequirementsCC.storeCard)

        sdkResultExistingShopperRequirementsCC.storeCard = false
        XCTAssertTrue(sdkResultExistingShopperRequirementsCC.storeCard)

        print("----------------------------------------------------")

        var sdkRequest = BSSdkRequest(withEmail: false,
                withShipping: false,
                fullBilling: false,
                priceDetails: BSPriceDetails(amount: 10, taxAmount: 10, currency: "USD"),
                billingDetails: nil,
                shippingDetails: nil,
                purchaseFunc: { _ in },
                updateTaxFunc: nil
        )

        XCTAssertFalse(sdkRequest.hideStoreCardSwitch)

        sdkRequest.hideStoreCardSwitch = true
        XCTAssertTrue(sdkRequest.hideStoreCardSwitch)

        sdkRequest.hideStoreCardSwitch = false
        XCTAssertFalse(sdkRequest.hideStoreCardSwitch)

        print("----------------------------------------------------")

        var sdkResultApplePay = BSApplePaySdkResult(sdkRequestBase: sdkRequest)
        XCTAssertNil(sdkResultApplePay.storeCard)

        var sdkResultPayPal = BSPayPalSdkResult(sdkRequestBase: sdkRequest)
        XCTAssertNil(sdkResultPayPal.storeCard)

        var sdkResultCC = BSCcSdkResult(sdkRequestBase: sdkRequest)
        XCTAssertFalse(sdkResultCC.storeCard)

        sdkResultCC.storeCard = true
        XCTAssertTrue(sdkResultCC.storeCard)

        sdkResultCC.storeCard = false
        XCTAssertFalse(sdkResultCC.storeCard)

        sdkResultCC.storeCard = true
        XCTAssertTrue(sdkResultCC.storeCard)

        var sdkResultExistingCC: BSExistingCcSdkResult = BSExistingCcSdkResult(sdkRequestBase: sdkRequest, shopper: BSShopper(), existingCcDetails: BSCreditCardInfo(creditCard: BSCreditCard(), billingDetails: nil))
        XCTAssertTrue(sdkResultExistingCC.storeCard)

        sdkResultExistingCC.storeCard = false
        XCTAssertTrue(sdkResultExistingCC.storeCard)

        sdkResultExistingCC.storeCard = true
        XCTAssertTrue(sdkResultExistingCC.storeCard)

        sdkResultExistingCC.storeCard = false
        XCTAssertTrue(sdkResultExistingCC.storeCard)
    }
}
