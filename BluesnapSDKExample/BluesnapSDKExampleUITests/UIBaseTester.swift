//
// Created by Sivani on 2019-02-18.
// Copyright (c) 2019 Bluesnap. All rights reserved.
//

import Foundation

import Foundation
import XCTest
import PassKit
import BluesnapSDK
//@testable import BluesnapSDKIntegrationTests //TODO: make it work

class UIBaseTester: XCTestCase{
    internal var app: XCUIApplication! //using Implicitly Unwrapped Optionals for initialization purpose
    internal var defaultCountry: String!
    internal var checkoutCurrency: String!
    internal var purchaseAmount: Double!
    internal var taxPercent: Double!
    internal var sdkRequest: BSSdkRequest!
    internal var isShippingSameAsBillingOn: Bool = false
    internal var isReturningShopper: Bool = false
    internal var paymentHelper: BSPaymentScreenUITestHelper!
    internal var shippingHelper: BSShippingScreenUITestHelper!
    internal var isExistingCard: Bool = false

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()
        defaultCountry = NSLocale.current.regionCode ?? BSCountryManager.US_COUNTRY_CODE
        checkoutCurrency = "USD"
        purchaseAmount = 30
        taxPercent = 0.05


        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        print("done")

        //        app.terminate()

    }

    internal func setUpForSdk(fullBilling: Bool, withShipping: Bool, withEmail: Bool, allowCurrencyChange: Bool = true, hideStoreCardSwitch: Bool = false, isReturningShopper: Bool = false, shopperId: String? = nil, trialPeriodDays: Int? = nil){

        // set returning shopper and shipping same as billing properties
        self.isReturningShopper = isReturningShopper
        if (fullBilling && withShipping && !isExistingCard) {
            isShippingSameAsBillingOn = true
        }

        // prepare sdk request
        prepareSdkRequest(fullBilling: fullBilling, withShipping: withShipping, withEmail: withEmail, allowCurrencyChange: allowCurrencyChange, hideStoreCardSwitch: hideStoreCardSwitch)

        // initialize required helpers
        paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        if (withShipping){
            shippingHelper = BSShippingScreenUITestHelper(app: app)
        }

        // set switches and amounts in merchant checkout screen
        setMerchantCheckoutScreen(shopperId: shopperId, trialPeriodDays: trialPeriodDays)
    }

    private func prepareSdkRequest(fullBilling: Bool, withShipping: Bool, withEmail: Bool, allowCurrencyChange: Bool = true, hideStoreCardSwitch: Bool = false) {

        let taxAmount = purchaseAmount * taxPercent // according to updateTax() in ViewController
        let priceDetails = BSPriceDetails(amount: purchaseAmount, taxAmount: taxAmount, currency: checkoutCurrency)
        let sdkRequest = BSSdkRequest(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: {_ in }, updateTaxFunc: nil)
        sdkRequest.shopperConfiguration.billingDetails = BSBillingAddressDetails()
        sdkRequest.shopperConfiguration.billingDetails?.country = defaultCountry
        sdkRequest.shopperConfiguration.shippingDetails = BSShippingAddressDetails()
        sdkRequest.shopperConfiguration.shippingDetails?.country = defaultCountry
        sdkRequest.allowCurrencyChange = allowCurrencyChange
        sdkRequest.hideStoreCardSwitch = hideStoreCardSwitch
        self.sdkRequest = sdkRequest
    }

    private func setMerchantCheckoutScreen(shopperId: String? = nil, trialPeriodDays: Int? = nil){

        // set new/returning shopper
        setSwitch(switchId: "ReturningShopperSwitch", isDesiredConfig: isReturningShopper, waitToExist: true, waitToDisappear: true)

        if let shopperId = shopperId {
            setTextField(textFieldId: "ReturningShopperId", value: shopperId)

            let amountField = app.textFields["AmountField"]
            amountField.doubleTap()
            let coverView = app.otherElements.element(matching: .any, identifier: "CoverView")
            waitForEllementToDisappear(element: coverView, waitTime: 30)
        }

        // set with Shipping switch = on
        setSwitch(switchId: "WithShippingSwitch", isDesiredConfig: sdkRequest.shopperConfiguration.withShipping, waitToExist: true)

        // set full billing switch = on
        setSwitch(switchId: "FullBillingSwitch", isDesiredConfig: sdkRequest.shopperConfiguration.fullBilling, waitToExist: true)

        // set with Email switch = on
        setSwitch(switchId: "WithEmailSwitch", isDesiredConfig: sdkRequest.shopperConfiguration.withEmail)

        // set with Email switch = on
        setSwitch(switchId: "allowCurrencyChangeSwitch", isDesiredConfig: sdkRequest.allowCurrencyChange)

        // set with Email switch = on
        setSwitch(switchId: "HideStoreCardSwitch", isDesiredConfig: sdkRequest.hideStoreCardSwitch)

        if let trialPeriodDays = trialPeriodDays{
            setTextField(textFieldId: "TrialDaysNumberField", value: String(trialPeriodDays))
        }
        
        setPurchaseAmount()
    }
    
    internal func setPurchaseAmount(waitToExist: Bool = false) {
        if let priceDetails = sdkRequest.priceDetails {
            // set amount text field value
            let amount = "\(priceDetails.amount ?? 0)"
            setTextField(textFieldId: "AmountField", value: amount, waitToExist: waitToExist)
        }
    }
    
    internal func setTextField(textFieldId: String, value: String, waitToExist: Bool = false) {
        // set amount text field value
        let textField : XCUIElement = app.textFields[textFieldId]
        
        if (waitToExist) {
            waitForElementToExist(element: textField, waitTime: 140)
            waitForElementToBeHittable(element: textField, waitTime: 140)
        }
        textField.clearText()
        textField.typeText(value)
        
    }

    internal func setSwitch(switchId: String, isDesiredConfig: Bool, waitToExist: Bool = false, waitToDisappear: Bool = false) {

        // set new/returning shopper
        let configSwitch = app.switches[switchId]
        if (waitToExist) {
            waitForElementToExist(element: configSwitch, waitTime: 140)
            //            waitForElementToBeEnabled(element: configSwitch, waitTime: 140)
            waitForElementToBeHittable(element: configSwitch, waitTime: 140)
        }
        let configSwitchValue = (configSwitch.value as? String) ?? "0"
        if (configSwitchValue == "0" && isDesiredConfig) || (configSwitchValue == "1" && !isDesiredConfig) {
            configSwitch.tap()
            // wait for action to finish
            if (waitToDisappear) {
                let coverView = app.otherElements.element(matching: .any, identifier: "CoverView")
                waitForEllementToDisappear(element: coverView, waitTime: 30)
            }
        }
    }

    internal func setShippingSameAsBillingSwitch(shouldBeOn: Bool){
        paymentHelper.closeKeyboard()
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: shouldBeOn)
        isShippingSameAsBillingOn = shouldBeOn
    }

    internal func setStoreCardSwitch(shouldBeOn: Bool){
        paymentHelper.closeKeyboard()
        paymentHelper.setStoreCardSwitch(shouldBeOn: shouldBeOn)
//        shippingSameAsBilling = shouldBeOn
    }

    internal func gotoShippingScreen(fillInDetails: Bool = true) {

        if (fillInDetails){
            fillBillingDetails(ccn: BSUITestUtils.getValidVisaCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: getDummyBillingDetails())
        }

        paymentHelper.pressPayButton()

        waitForShippingScreen()
    }

    internal func fillBillingDetails(ccn: String, exp: String, cvv: String, billingDetails: BSBillingAddressDetails, ignoreCountry: Bool? = false) {

        // fill CC values
        paymentHelper.setCcDetails(ccn: ccn, exp: exp, cvv: cvv)

        setBillingDetails(billingDetails: billingDetails, ignoreCountry: ignoreCountry)

        // check that the values are in correctly
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
    }

    internal func setBillingDetails(billingDetails: BSBillingAddressDetails, ignoreCountry: Bool? = false){
        // fill field values
        paymentHelper.setFieldValues(billingDetails: billingDetails, sdkRequest: sdkRequest, ignoreCountry: ignoreCountry)

        sdkRequest.shopperConfiguration.billingDetails = billingDetails
    }

    internal func fillShippingDetails(shippingDetails: BSShippingAddressDetails){

        setShippingDetails(shippingDetails: shippingDetails)

        // check that the values are in correctly
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)

    }

    internal func setShippingDetails(shippingDetails: BSShippingAddressDetails){
        // fill field values
        shippingHelper.setFieldValues(shippingDetails: shippingDetails, sdkRequest: sdkRequest)

        sdkRequest.shopperConfiguration.shippingDetails = shippingDetails
    }

    internal func getDummyBillingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSBillingAddressDetails {

        let billingDetails = BSBillingAddressDetails(email: "shevie@gmail.com", name: "Shevie Chen", address: "58 somestreet", city : "somecity", zip : "4282300", country : countryCode, state : stateCode)
        return billingDetails
    }

    internal func getDummyShippingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSShippingAddressDetails {

        let shippingDetails = BSShippingAddressDetails(name: "Funny Brice", address: "77 Rambla street", city : "Barcelona", zip : "4815", country : countryCode, state : stateCode)
        return shippingDetails
    }

    internal func getDummyEditBillingDetails(countryCode: String? = "US", stateCode: String? = "NY") -> BSBillingAddressDetails {

        let billingDetails = BSBillingAddressDetails(email: "test@sdk.com", name: "La Fleur", address: "555 Broadway street", city : "New York", zip : "3abc 324a", country : countryCode, state : stateCode)
        return billingDetails
    }

    internal func getDummyEditShippingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSShippingAddressDetails {

        let shippingDetails = BSShippingAddressDetails(name: "Janet Weiss", address: "75 some street", city : "Denton", zip : "162342", country : countryCode, state : stateCode)
        return shippingDetails
    }

    internal func checkResult(expectedSuccessText: String) {

        let successLabel = app.staticTexts["SuccessLabel"]
        waitForElementToExist(element: successLabel, waitTime: 300)
        let labelText: String = successLabel.label
        assert(labelText == expectedSuccessText)
    }

    internal func waitForElementToExist(element: XCUIElement, waitTime: TimeInterval) {

        let exists = NSPredicate(format: "exists == 1")
        let ex: XCTestExpectation = expectation(for: exists, evaluatedWith: element)
        wait(for: [ex], timeout: waitTime)
        //        waitForExpectations(timeout: waitTime, handler: { error in
        //            NSLog("Finished waiting")
        //        })
    }

    internal func waitForElementToBeEnabled(element: XCUIElement, waitTime: TimeInterval) {

        let exists = NSPredicate(format: "isEnabled == 1")
        let ex: XCTestExpectation = expectation(for: exists, evaluatedWith: element)
        wait(for: [ex], timeout: waitTime)
        //        waitForExpectations(timeout: waitTime, handler: { error in
        //            NSLog("Finished waiting")
        //
    }

    internal func waitForElementToBeHittable(element: XCUIElement, waitTime: TimeInterval) {

        let exists = NSPredicate(format: "isHittable == 1")
        let ex: XCTestExpectation = expectation(for: exists, evaluatedWith: element)
        wait(for: [ex], timeout: waitTime)
        //        waitForExpectations(timeout: waitTime, handler: { error in
        //            NSLog("Finished waiting")
        //
    }

    internal func waitForEllementToDisappear(element: XCUIElement, waitTime: TimeInterval) {

        let exists = NSPredicate(format: "exists == 0")
        let ex: XCTestExpectation = expectation(for: exists, evaluatedWith: element)
        wait(for: [ex], timeout: waitTime)
    }

    internal func waitForPaymentScreen() {

        let payButton = app.buttons["PayButton"]
        waitForElementToExist(element: payButton, waitTime: 60)
    }

    internal func waitForShippingScreen() {

        let payButton = app.buttons["ShippingPayButton"]
        waitForElementToExist(element: payButton, waitTime: 60)
    }

}
