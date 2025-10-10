//
//  PaymentTypeScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 07/09/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest

class BSPaymentTypeScreenUITestHelper {
    
//    var keyboardIsHidden = true

    var app: XCUIApplication!
    
    init(app: XCUIApplication!) {
        self.app = app
//        self.keyboardIsHidden = keyboardIsHidden
    }
    
    func getApplePayButtonElement() -> XCUIElement{
        return app.buttons["ApplePayButton"]
    }
    
    func getPayPalButtonElement() -> XCUIElement{
        return app.buttons["PayPalButton"]
    }
    
    func getCcButtonElement() -> XCUIElement{
        return app.buttons["CcButton"]
    }
    
    func checkPaymentTypes(expectedApplePay: Bool, expectedPayPal: Bool, expectedCC: Bool) {
        
        // check visibility of CC button
        let ccButton = getCcButtonElement()
        let ccButtonIsVisible = ccButton.exists
        XCTAssertTrue(ccButtonIsVisible == expectedCC, "New Credit Card Button is not displayed")

        // check visibility of ApplePay button
        let applePayButton = getApplePayButtonElement()
        let applePayButtonIsVisible = applePayButton.exists //&& applePayButton.isEnabled && applePayButton.isHittable
        XCTAssertTrue(applePayButtonIsVisible == expectedApplePay, "ApplePay Button is not displayed")

        // check visibility of PayPal button
        let payPalButton = getPayPalButtonElement()
        let payPalButtonIsVisible = payPalButton.exists
        XCTAssertTrue(payPalButtonIsVisible == expectedPayPal, "PayPal Button is not displayed")
    }
    
    func checkExistingCCLine(index: Int, expectedLastFourDigits: String, expectedExpDate: String) {
        let identifier = "existingCc\(index)"
        let existingCCLine = app.buttons[identifier]
//        let existingCCLine = app.otherElements.element(matching: .any, identifier: identifier)
        
        // get the cc line component's labels
        let lastFourDigitsLabel = existingCCLine.staticTexts["Last4DigitsLabel"]
        let expDateLabel = existingCCLine.staticTexts["ExpirationLabel"]
        
        // verify that the labels match the expected values
        let lastFourDigitsLabelText: String = lastFourDigitsLabel.label
        XCTAssertTrue(lastFourDigitsLabelText == expectedLastFourDigits, "Last Four Digits label expected value: \(expectedLastFourDigits), actual value: \(lastFourDigitsLabelText)")
        
        let expDateLabelText: String = expDateLabel.label
        XCTAssertTrue(expDateLabelText == expectedExpDate, "Last Four Digits label expected value: \(expectedExpDate), actual value: \(expDateLabelText)")

    }

}
