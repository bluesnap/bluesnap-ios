//
//  BSCurrencyTests.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 15/11/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BBSCurrencyTests: XCTestCase {
    
    internal let usd = BSCurrency(name: "United States Dollar", code: "USD", rate: 1.0)
    internal let euro = BSCurrency(name: "Euro", code: "EUR", rate: 0.5)
    internal let ils = BSCurrency(name: "Israeli Shekel", code: "ILS", rate: 4.0)
    
    override func setUp() {
        print("----------------------------------------------------")
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testCurrencyConversion() {
        
        createDummyCurrenies()
        
        var price = BSPriceDetails(amount: 100.0, taxAmount: 10.0, currency: usd.code)
        price.changeCurrencyAndConvertAmounts(newCurrency: euro)
        XCTAssertEqual(price.amount, 50.0)
        XCTAssertEqual(price.taxAmount, 5.0)
        XCTAssertEqual(price.currency, euro.code)
        
        price = BSPriceDetails(amount: 100.0, taxAmount: 10.0, currency: usd.code)
        price.changeCurrencyAndConvertAmounts(newCurrency: ils)
        XCTAssertEqual(price.amount, 400.0)
        XCTAssertEqual(price.taxAmount, 40.0)
        XCTAssertEqual(price.currency, ils.code)
        
        price = BSPriceDetails(amount: 100.0, taxAmount: 10.0, currency: usd.code)
        price.changeCurrencyAndConvertAmounts(newCurrency: usd)
        XCTAssertEqual(price.amount, 100.0)
        XCTAssertEqual(price.taxAmount, 10.0)
        XCTAssertEqual(price.currency, usd.code)
        
        price = BSPriceDetails(amount: 400.0, taxAmount: 40.0, currency: ils.code)
        price.changeCurrencyAndConvertAmounts(newCurrency: usd)
        XCTAssertEqual(price.amount, 100.0)
        XCTAssertEqual(price.taxAmount, 10.0)
        XCTAssertEqual(price.currency, usd.code)
        
        price = BSPriceDetails(amount: 400.0, taxAmount: 40.0, currency: ils.code)
        price.changeCurrencyAndConvertAmounts(newCurrency: euro)
        XCTAssertEqual(price.amount, 50.0)
        XCTAssertEqual(price.taxAmount, 5.0)
        XCTAssertEqual(price.currency, euro.code)

        // change back and forth
        price = BSPriceDetails(amount: 100.0, taxAmount: 10.0, currency: usd.code)
        
        price.changeCurrencyAndConvertAmounts(newCurrency: euro)
        XCTAssertEqual(price.amount, 50.0)
        XCTAssertEqual(price.taxAmount, 5.0)
        XCTAssertEqual(price.currency, euro.code)
        
        price.changeCurrencyAndConvertAmounts(newCurrency: ils)
        XCTAssertEqual(price.amount, 400.0)
        XCTAssertEqual(price.taxAmount, 40.0)
        XCTAssertEqual(price.currency, ils.code)
        
        price.changeCurrencyAndConvertAmounts(newCurrency: usd)
        XCTAssertEqual(price.amount, 100.0)
        XCTAssertEqual(price.taxAmount, 10.0)
        XCTAssertEqual(price.currency, usd.code)
    }
    
    private func createDummyCurrenies() {
        
        let currencies : [BSCurrency] = [usd, euro, ils]
        let bsCurrencies = BSCurrencies(baseCurrency: usd.code, currencies: currencies)
        BSApiManager.bsCurrencies = bsCurrencies
    }
}
