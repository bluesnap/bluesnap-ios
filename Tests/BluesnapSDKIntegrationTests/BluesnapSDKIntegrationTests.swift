//
//  BluesnapSDKIntegrationTests.swift
//  BluesnapSDKIntegrationTests
//
//  Created by Sivani on 11/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import XCTest

@testable import BluesnapSDK

class BluesnapSDKIntegrationTests: XCTestCase {
    let email = "test@sdk.com"

    let purchaseCCData = [
        "cardLastFourDigits": "1111", "expirationMonth": "10", "expirationYear": "2030",
        "cardType": "VISA",
    ]

    let purchaseBillingData = [
        "firstName": "La", "lastName": "Fleur", "address1": "555 Broadway street",
        "city": "New York", "zip": "3abc 324a", "country": "us", "state": "NY",
    ]

    let purchaseShippingData = [
        "firstName": "Taylor", "lastName": "Love", "address1": "AddressTest",
        "city": "CityTest", "zip": "12345", "country": "br", "state": "RJ",
    ]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEndToEndFullBillingWithShippingWithMailCheckoutFlow() {
        let shopper = MockShopper(
            creditCardInfo: [(purchaseBillingData, purchaseCCData)], email: email,
            shippingContactInfo: purchaseShippingData, fullBillingRequired: true,
            emailRequired: true, shippingRequired: true)

        let tokenizeRequest = BSTokenizeRequest()
        tokenizeRequest.paymentDetails = BSTokenizeNewCCDetails(
            ccNumber: "4111 1111 1111 1111", cvv: "123", ccType: nil,
            expDate: "\(purchaseCCData["expirationMonth"]!)/\(purchaseCCData["expirationYear"]!)")
        tokenizeRequest.billingDetails = BSBillingAddressDetails(
            email: email,
            name: "\(purchaseBillingData["firstName"]!) \(purchaseBillingData["lastName"]!)",
            address: purchaseBillingData["address1"], city: purchaseBillingData["city"],
            zip: purchaseBillingData["zip"], country: purchaseBillingData["country"]?.uppercased(),
            state: purchaseBillingData["state"])
        tokenizeRequest.shippingDetails = BSShippingAddressDetails(
            name: "\(purchaseShippingData["firstName"]!) \(purchaseShippingData["lastName"]!)",
            address: purchaseShippingData["address1"], city: purchaseShippingData["city"],
            zip: purchaseShippingData["zip"],
            country: purchaseShippingData["country"]?.uppercased(),
            state: purchaseShippingData["state"])

        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            do {
                try BlueSnapSDK.initBluesnap(
                    bsToken: token, generateTokenFunc: { _ in }, initKount: true,
                    fraudSessionId: nil,
                    applePayMerchantIdentifier: "merchant.com.example.bluesnap",
                    merchantStoreCurrency: "USD", initCardinal: false,
                    completion: { errors in

                        XCTAssertNil(errors, "Got errors from initBluesnap")

                        BlueSnapSDK.submitTokenizedDetails(
                            tokenizeRequest: tokenizeRequest,
                            completion: { (result, error) in
                                XCTAssertNil(error, "error: \(String(describing: error))")

                                // verify the received details from the server call
                                XCTAssertEqual(
                                    result[BSTokenizeBaseCCDetails.CARD_TYPE_KEY], "VISA")
                                XCTAssertEqual(
                                    result[BSTokenizeBaseCCDetails.LAST_4_DIGITS_KEY], "1111")
                                XCTAssertEqual(
                                    result[BSTokenizeBaseCCDetails.ISSUING_COUNTRY_KEY], "US")

                                BSIntegrationTestingAPIHelper.createTokenizedTransaction(
                                    purchaseAmount: 22.0,
                                    purchaseCurrency: "USD",
                                    bsToken: token,
                                    completion: { isSuccess, data, shopperId in
                                        XCTAssert(
                                            isSuccess,
                                            "error: \(String(describing: "Transaction failed"))")
                                        XCTAssertNotNil(
                                            data,
                                            "error: \(String(describing: "No data from transaction"))"
                                        )
                                        XCTAssertNotNil(
                                            shopperId,
                                            "error: \(String(describing: "No shopperId from transaction"))"
                                        )

                                        BSIntegrationTestingAPIHelper.retrieveVaultedShopper(
                                            vaultedShopperId: shopperId!,
                                            completion: {
                                                isSuccess, data in
                                                XCTAssert(
                                                    isSuccess,
                                                    "error: \(String(describing: "Transaction failed"))"
                                                )
                                                let error =
                                                    BluesnapSDKIntegrationTestsHelper
                                                    .checkRetrieveVaultedShopperResponse(
                                                        responseBody: data!, shopperInfo: shopper)

                                                XCTAssertNil(
                                                    error, "error: \(String(describing: error))")

                                                semaphore.signal()
                                            })
                                    })
                            })
                    })

            } catch {
                NSLog("Unexpected error: \(error).")
                XCTFail()
            }
        })
        semaphore.wait()

    }

    func testEndToEndAchPaymentFlow() {

        let tokenizeRequest = BSTokenizeRequest()

        tokenizeRequest.paymentDetails = BSTokenizeEcpAchDetails(
            routingNumber: "998877665",
            accountNumber: "223344556",
            accountType: "CONSUMER_CHECKING",
            paymentMethod: "ECP"
        )

        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            do {
                try BlueSnapSDK.initBluesnap(
                    bsToken: token, generateTokenFunc: { _ in }, initKount: true,
                    fraudSessionId: nil,
                    applePayMerchantIdentifier: "merchant.com.example.bluesnap",
                    merchantStoreCurrency: "USD", initCardinal: false,
                    completion: { errors in

                        XCTAssertNil(errors, "Got errors from initBluesnap")

                        BlueSnapSDK.submitEcpAchTokenizedDetails(
                            tokenizeRequest: tokenizeRequest,
                            completion: { (result, error) in
                                XCTAssertNil(error, "error: \(String(describing: error))")
                               
                                BSIntegrationTestingAPIHelper.createTokenizedEcpAchTransaction(
                                    purchaseAmount: 22.0,
                                    purchaseCurrency: "USD",
                                    paymentMethod: "ECP",
                                    routingNumber: "998877665",
                                    accountNumber: "223344556",
                                    accountType: "CONSUMER_CHECKING",

                                    bsToken: token,
                                    completion: { isSuccess, data, shopperId in
                                        XCTAssert(
                                            isSuccess,
                                            "error: \(String(describing: "Transaction failed"))")
                                        XCTAssertNotNil(
                                            data,
                                            "error: \(String(describing: "No data from transaction"))"
                                        )


                                        semaphore.signal()
                                    })
                            })
                    })

            } catch {
                NSLog("Unexpected error: \(error).")
                XCTFail()
            }
        })
        semaphore.wait()

    }
}
