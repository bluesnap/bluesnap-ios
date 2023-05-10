//
//  BSExistingCcScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 09/11/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK

class BSExistingCcScreenUITestHelper {
    
    var app: XCUIApplication!
    var existingCcLineInput : XCUIElement!
    var billingLabel : XCUIElement!
    var shippingLabel : XCUIElement!
    var billingNameLabel : XCUIElement!
    var shippingNameLabel : XCUIElement!
    var billingAddressTextView : XCUIElement!
    var shippingAddressTextView : XCUIElement!
    var editBillingButton : XCUIElement!
    var editShippingButton : XCUIElement!

    init(app: XCUIApplication!) {
        self.app = app
//        let elementsQuery = app.scrollViews.otherElements
        existingCcLineInput = app.otherElements.element(matching: .any, identifier: "ExistingCCN")
        billingLabel = app.staticTexts["BillingLabel"]
        shippingLabel = app.staticTexts["ShippingLabel"]
        billingNameLabel = app.staticTexts["BillingName"] //elementsQuery.element(matching: .any, identifier: "BillingName")
        shippingNameLabel = app.staticTexts["ShippingName"] //elementsQuery.element(matching: .any, identifier: "ShippingName")
        billingAddressTextView = app.textViews["BillingAddress"] //elementsQuery.element(matching: .any, identifier: "BillingAddress")
        shippingAddressTextView = app.textViews["ShippingAddress"] //elementsQuery.element(matching: .any, identifier: "ShippingAddress")
        editBillingButton = app.buttons["EditBillingButton"] //elementsQuery.element(matching: .any, identifier: "EditBillingButton")
        editShippingButton = app.buttons["EditShippingButton"] //elementsQuery.element(matching: .any, identifier: "EditShippingButton")
    }
    
    func getManuButton() -> XCUIElement {
        return app.buttons["MenuButton"]
    }
    
    func checkExistingCCLineVisibility(expectedLastFourDigits: String, expectedExpDate: String) {
        // get the cc line component's labels
        let lastFourDigitsLabel = existingCcLineInput.staticTexts["Last4DigitsLabel"]
        let expDateLabel = existingCcLineInput.staticTexts["ExpirationLabel"]
        
        // verify that the labels match the expected values
        let lastFourDigitsLabelText: String = lastFourDigitsLabel.label
        XCTAssertTrue(lastFourDigitsLabelText == expectedLastFourDigits, "Last Four Digits label expected value: \(expectedLastFourDigits), actual value: \(lastFourDigitsLabelText)")
        
        let expDateLabelText: String = expDateLabel.label
        XCTAssertTrue(expDateLabelText == expectedExpDate, "Last Four Digits label expected value: \(expectedExpDate), actual value: \(expDateLabelText)")
        
    }
    
    // check visibility of inputs - make sure fields are shown according to configuration
    func checkScreenItems(sdkRequest: BSSdkRequest) {
        XCTAssertTrue(billingLabel.exists, "Billing Label is not displayed")
        XCTAssertTrue(billingNameLabel.exists, "Billing Name Label is not displayed")
        XCTAssertTrue(billingAddressTextView.exists, "Billing Address Label is not displayed")
        XCTAssertTrue(editBillingButton.exists, "Edit Billing Button is not displayed")
        if sdkRequest.shopperConfiguration.withShipping {
            XCTAssertTrue(shippingLabel.exists, "Shipping Label is not displayed")
            XCTAssertTrue(shippingNameLabel.exists, "Shipping Name Label is not displayed")
            XCTAssertTrue(shippingAddressTextView.exists, "Shipping Address Label is not displayed")
            XCTAssertTrue(editShippingButton.exists, "Edit Shipping Button is not displayed")
        } else {
            XCTAssertTrue(!shippingLabel.exists, "Shipping Label is displayed")
            XCTAssertTrue(!shippingNameLabel.exists, "Shipping Name Label is displayed")
            XCTAssertTrue(!shippingAddressTextView.exists, "Shipping Address Label is displayed")
            XCTAssertTrue(!editShippingButton.exists, "Edit Shipping Button is displayed")
        }
    }
    
    func checkNameLabelContent(sdkRequest: BSSdkRequest, isBilling: Bool) {
        var nameLabel: XCUIElement!
        var expectedName: String!
        
        if (isBilling){
            nameLabel = billingNameLabel
            expectedName = sdkRequest.shopperConfiguration.billingDetails?.name
        }
        
        else{
            nameLabel = shippingNameLabel
            expectedName = sdkRequest.shopperConfiguration.shippingDetails?.name
        }
        
        let nameLabelText = nameLabel.label

        XCTAssertEqual(nameLabelText, expectedName, "\(nameLabel.identifier) Label expected value: \(expectedName!), actual value: \(nameLabelText)")
    }
    
    // parameters fullBillingDisplay, emailDisplay, shippingDisplay indicates which fields should be displayed.
    // it is basically (shopper configuration && checkout configuration)
    func checkAddressBoxContent(sdkRequest: BSSdkRequest, isBilling: Bool, fullBillingDisplay: Bool, emailDisplay: Bool, shippingDisplay: Bool) {
        
        // shipping box validation and shopper has no shipping
//        if (!isBilling && shippingDisplay) {
//            return
//        }
        
        var expectedAddressContent = ""
        let contactInfo = isBilling ? sdkRequest.shopperConfiguration.billingDetails! : sdkRequest.shopperConfiguration.shippingDetails!
        let fullInfo = fullBillingDisplay || !isBilling && shippingDisplay
        
        if (isBilling && emailDisplay) {
            expectedAddressContent += (contactInfo as! BSBillingAddressDetails).email! + "\n"
        }
        
        if (fullInfo) {
            expectedAddressContent += contactInfo.address! + ", "
            expectedAddressContent += contactInfo.city! + " "
            expectedAddressContent += contactInfo.state! + " "
        }
        
        expectedAddressContent += contactInfo.zip! +  " "
        
        let countryName = BSCountryManager.getInstance().getCountryName(countryCode: contactInfo.country!)
        expectedAddressContent += countryName ?? contactInfo.country!
        
        
        let addressTextView = isBilling ? billingAddressTextView : shippingAddressTextView
        let addressTextViewText = addressTextView?.value as! String
        
        XCTAssertEqual(addressTextViewText, expectedAddressContent, "\(String(describing: addressTextView?.identifier)) Label expected value: \(expectedAddressContent), actual value: \(String(describing: addressTextViewText))")

    }
    
    func checkPayButton(sdkRequest: BSSdkRequest, subscriptionHasPriceDetails: Bool? = nil) {
        var expectedPayText = ""
//        var expectedAmount = sdkRequest.priceDetails.amount.doubleValue
        //        let taxPrecent = calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "")
        
        if (sdkRequest.shopperConfiguration.withShipping){
            let country = sdkRequest.shopperConfiguration.shippingDetails?.country
            let state = sdkRequest.shopperConfiguration.shippingDetails?.state
//            expectedAmount = BSUITestUtils.calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "", purchaseAmount: sdkRequest.priceDetails.amount.doubleValue)
            
            expectedPayText = BSUITestUtils.getPayButtonText(sdkRequest: sdkRequest, country: country ?? "", state: state ?? "", subscriptionHasPriceDetails: subscriptionHasPriceDetails)
        }
        
        else {
            expectedPayText = BSUITestUtils.getPayButtonText(sdkRequest: sdkRequest, country: nil, state: nil, subscriptionHasPriceDetails: subscriptionHasPriceDetails)

//            expectedPayText = "Pay \(sdkRequest.priceDetails.currency == "USD" ? "$" : sdkRequest.priceDetails.currency ?? "USD") \(expectedAmount)"
        }
        
        BSUITestUtils.checkAPayButton(app: app, buttonId: "PayButton", expectedPayText: expectedPayText)
    }
    
    func checkDoneButton() {
        BSUITestUtils.checkAPayButton(app: app, buttonId: "PayButton", expectedPayText: "Done")
    }
    
    func pressPayButton() {
        app.buttons["PayButton"].tap()
    }
    
    /*
     paremter editBilling is set to true for edit billing info, false for edit shipping info
     */
    func pressEditButton(editBilling: Bool) {
        if editBilling{
            editBillingButton.tap()
        }
        
        else{
            editShippingButton.tap()
        }
    }
    
    func checkMenuButtonEnabled(expectedEnabled: Bool){
        let menuButton = getManuButton()
        
        XCTAssertTrue(menuButton.isEnabled == expectedEnabled, "Menu button expected to be Enabled: \(expectedEnabled), but was Enabled: \(menuButton.isEnabled)")
    }
    
}
