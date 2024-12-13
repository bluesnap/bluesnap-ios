//
//  BluesnapSDKTests.swift
//  BluesnapSDKTests
//
//  Created by Oz on 26/03/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BluesnapSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    //------------------------------------------------------
    // MARK: submitCcDetails
    //------------------------------------------------------
    

    func testValidNumbers() {
        testSubmitCCDetailsSuccess(ccn: "4111 1111 1111 1111", cvv: "111", exp: "10/2030")
        testSubmitCCDetailsSuccess(ccn: "5204 2452 5046 0049", cvv: "111", exp: "12/2030")
    }
    
    func testSubmitCCDetailsSuccess(ccn: String!, cvv: String!, exp: String!) {
 
        let tokenizeRequest = BSTokenizeRequest()
        tokenizeRequest.paymentDetails = BSTokenizeNewCCDetails(ccNumber: ccn, cvv: cvv, ccType: nil, expDate: exp)

        //TODO: this can be rplaced with XCTWaiter().wait
        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            
            BlueSnapSDK.submitTokenizedDetails(tokenizeRequest: tokenizeRequest, completion: { (result, error) in
                
                XCTAssert(error == nil, "error: \(String(describing: error))")
                let ccType = result[BSTokenizeBaseCCDetails.CARD_TYPE_KEY]
                let last4 = result[BSTokenizeBaseCCDetails.LAST_4_DIGITS_KEY]
                let country = result[BSTokenizeBaseCCDetails.ISSUING_COUNTRY_KEY]
                NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
                semaphore.signal()
            })
        })
        //semaphore.wait(timeout: .now() + 30)
        if semaphore.wait(timeout: .now() + 15) == .timedOut {
            XCTFail("timeout")
        }
    }
    
    
    func testSubmitCCDetailsError() {
        
        submitCCDetailsExpectError(ccn: "4111", cvv: "111", exp: "12/2020", expectedError: BSErrors.invalidCcNumber)
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "1", exp: "12/2020", expectedError: BSErrors.invalidCvv)
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "111", exp: "22/2020", expectedError: BSErrors.invalidExpDate)
    }
    
    func testSubmitEmptyCCDetailsError() {
        
        submitCCDetailsExpectError(ccn: "", cvv: "", exp: "", expectedError: BSErrors.invalidCcNumber)
    }
    
    
    //------------------------------------------------------
    // MARK: getCurrencyRates
    //------------------------------------------------------

    // test get currencies with a valid token
    func testGetTokenAndCurrencies() {
        
        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            
            do {            
                try BlueSnapSDK.initBluesnap(bsToken: token, generateTokenFunc: {_ in }, initKount: false, fraudSessionId: nil, applePayMerchantIdentifier: nil, merchantStoreCurrency: "USD", initCardinal: false, completion: { errors in
                    
                    XCTAssertNil(errors, "Got errors from initBluesnap")
                    
                    let bsCurrencies = BlueSnapSDK.getCurrencyRates()
                    XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
                    
                    let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
                    XCTAssertNotNil(gbpCurrency)
                    NSLog("testGetTokenAndCurrencies; GBP currency name is: \(String(describing: gbpCurrency.name)), its rate is \(String(describing: gbpCurrency.rate))")
                    
                    let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
                    XCTAssertNotNil(eurCurrencyRate)
                    NSLog("testGetTokenAndCurrencies; EUR currency rate is: \(String(describing: eurCurrencyRate))")
                    
                    semaphore.signal()
                })
                
            } catch {
                NSLog("Unexpected error: \(error).")
            }
        })
        //TODO: fix this..
        semaphore.wait()
//        if semaphore.wait(timeout: .now() + 15) == .timedOut {
//            XCTFail("timeout")
//
//        }
    }
    
        
    //------------------------------------------------------
    // MARK: private functions
    //------------------------------------------------------
    
    private func submitCCDetailsExpectError(ccn: String!, cvv: String!, exp: String!, expectedError: BSErrors) {
        
        let semaphore = DispatchSemaphore(value: 0)
        let tokenizeRequest = BSTokenizeRequest()
        tokenizeRequest.paymentDetails = BSTokenizeNewCCDetails(ccNumber: ccn, cvv: cvv, ccType: nil, expDate: exp)
        
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            
            BlueSnapSDK.submitTokenizedDetails(tokenizeRequest: tokenizeRequest, completion: {
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
        //semaphore.wait(timeout: .now() + 30)
        if semaphore.wait(timeout: .now() + 15) == .timedOut {
           XCTFail("timeout")
        }
    }
    
    
}
