//
//  BluesnapSDKExampleUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Oz on 26/03/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
import Foundation
import PassKit
import BluesnapSDK

#if canImport(KountWrapper)
import KountWrapper
#endif

class CheckoutNewShopperUITests: CheckoutBaseTester {

    /* -------------------------------- New shopper views tests ---------------------------------------- */
    
    func testAllowCurrencyChange(){
        allowCurrencyChangeNewCCValidation(isEnabled: true)
    }
    
    func testNotAllowCurrencyChange(){
        allowCurrencyChangeNewCCValidation(isEnabled: false)
    }
    
    //TODO: fix these two!!
    
    /**
     This test verifies that changing the currency while shipping is disabled
     changes the buy button as it should in payment screen.
     Also, it verifies that after changing to different currencies
     and back to the origin one, the amount remains the same
     */
//    func testCurrencyChangesInPaymentScreen(){
//        testCurrencyChanges(withShipping: false)
//    }
    
    /**
     This test verifies that changing the currency while shipping is enabled
     changes the buy button as it should in shipping screen.
     Also, it verifies that after changing to different currencies
     and back to the origin one, the amount remains the same
     */
//    func testCurrencyChangesInShippingScreen(){
//        testCurrencyChanges(withShipping: true)
//    }

    
    func testViewsFullBillingNoShippingNoEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: false, withEmail: false)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)

        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: true)
        
        // check zip input field visibility according to different countries
        paymentHelper.checkZipVisibility(defaultCountry: defaultCountry, zipPlaceholder: "Billing Zip")
        
        // check state input field visibility according to different countries
        paymentHelper.checkStateVisibility(defaultCountry: defaultCountry)

        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)
        
    }
    
    func testViewsFullBillingNoShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: false, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // change country to USA to have state and zip
        paymentHelper.setCountry(countryCode: "US")
        
        // check trying to pay with empty fields
        paymentHelper.checkPayWithEmptyInputs(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, payButtonId: "PayButton", zipPlaceholder: "Billing Zip")
        
        // check invalid cc line inputs
        paymentHelper.checkInvalidCCLineInputs()
        
        // check invalid billing inputs
        paymentHelper.checkInvalidInfoInputs(payButtonId: "PayButton")
        
        // check Store Card view visibility
        paymentHelper.closeKeyboard()
        paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: true)
        
        // check store card visibility after changing screens
        paymentHelper.checkStoreCardVisibilityAfterChangingScreens(shouldBeVisible: true, setTo: true, sdkRequest: sdkRequest)
        
        // check store card visibility after changing screens
        paymentHelper.checkStoreCardVisibilityAfterChangingScreens(shouldBeVisible: true, setTo: false, sdkRequest: sdkRequest)
    }
    
    func testViewsFullBillingWithShippingNoEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: false)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: true)
        
        // check pay button when shipping same as billing is on
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest)

        // fill in shipping details with country without shipping tax
        fillShippingDetails(shippingDetails: getDummyShippingDetails())
        
        BSUITestUtils.pressBackButton(app: app)
        
        // verify that the shipping info has been saved in shipping screen after going back and entering to the screen again
        gotoShippingScreen(fillInDetails: false)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)

    }
    
    func testViewsFullBillingWithShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: true)
        
        // check pay button when shipping same as billing is on
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest)

        // change to country without shipping tax
        shippingHelper.setCountry(countryCode: "IL")
        
        BSUITestUtils.pressBackButton(app: app)

        // verify that the billing info has been saved in payment screen (including error messages)
        paymentHelper.checkCcnComponentState(ccnShouldBeOpen: false, ccn: BSUITestUtils.getValidVisaCreditCardNumber(), last4digits: "1111", exp: "11/26", cvv: "333")
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        setShippingSameAsBillingSwitch(shouldBeOn: true)
        // check pay button- for shipping country with tax
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        setShippingSameAsBillingSwitch(shouldBeOn: false)
        // check pay button- for shipping country without tax
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)
        
    }
    
    func testViewsNoFullBillingNoShippingNoEmail() {
        setUpForCheckoutSdk(fullBilling: false, withShipping: false, withEmail: false)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        paymentHelper.checkNewCCLineVisibilityAfterEnteringCCN()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: true)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

    }
    
    func testViewsNoFullBillingNoShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: false, withShipping: false, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: true)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

    }
    
    func testViewsNoFullBillingWithShippingNoEmail() {
        setUpForCheckoutSdk(fullBilling: false, withShipping: true, withEmail: false)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: true)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check zip input field visibility according to different countries
        shippingHelper.checkZipVisibility(defaultCountry: defaultCountry, zipPlaceholder: "Shipping Zip")
        
        // check state input field visibility according to different countries
        shippingHelper.checkStateVisibility(defaultCountry: defaultCountry)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest)

        // check trying to pay with empty fields
        shippingHelper.checkPayWithEmptyInputs(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, payButtonId: "ShippingPayButton", zipPlaceholder: "Shipping Zip")
        
        // check invalid shipping inputs
        shippingHelper.checkInvalidInfoInputs(payButtonId: "ShippingPayButton")
        
        setShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "BR", stateCode: "RJ"))
        
        // go back and forward
        BSUITestUtils.pressBackButton(app: app)
        gotoShippingScreen(fillInDetails: false)
        
        // verify info has been saved in shipping
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
    }
    
    func testViewsNoFullBillingWithShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: false, withShipping: true, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: true)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest)

    }
    
    /* -------------------------------- New shopper end-to-end flow tests ---------------------------------------- */
    
    func testFlowFullBillingNoShippingNoEmail() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: false, withEmail: false)
    }
    
    func testFlowFullBillingNoShippingWithEmail() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: false, withEmail: true)
    }
    
    func testFlowFullBillingWithShippingNoEmail() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: false)
    }
    
    func testFlowFullBillingWithShippingWithEmail() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true)
    }
    
    func testFlowShippingSameAsBilling() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true, shippingSameAsBilling: true)
    }
    
    // TODO: do we need this?
    func testFlowFullBillingWithShippingWithEmailNostate() {

        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: true)

        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "IL"
        billingDetails.state = nil
        
        fillBillingDetails(ccn: BSUITestUtils.getValidVisaCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: billingDetails)
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        paymentHelper.pressPayButton()

        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GB"
        shippingDetails.state = nil
        
        fillShippingDetails(shippingDetails: shippingDetails)
        
        shippingHelper.pressPayButton()

        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    // TODO: do we need this?
    func testFlowFullBillingWithShippingWithEmailNoZip() {

        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: true)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "GH"
        billingDetails.state = nil

        fillBillingDetails(ccn: BSUITestUtils.getValidVisaCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: billingDetails)
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        paymentHelper.pressPayButton()

        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GH"
        shippingDetails.state = nil
        fillShippingDetails(shippingDetails: shippingDetails)
        
        shippingHelper.pressPayButton()

        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowNoFullBillingNoShippingNoEmail() {
        newCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: false)
    }
    
    func testFlowNoFullBillingNoShippingWithEmail() {
        newCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: true)
    }
    
    func testFlowNoFullBillingWithShippingNoEmail() {
        newCardBasicCheckoutFlow(fullBilling: false, withShipping: true, withEmail: false)
    }
    
    func testFlowNoFullBillingWithShippingWithEmail() {
        newCardBasicCheckoutFlow(fullBilling: false, withShipping: true, withEmail: true)
    }
    
    func testFlowStoreCardInServer() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true, storeCard: true)
    }
    
    func testFlowHideStoreCardSwitch(){
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true, hideStoreCardSwitch: true)
    }
    
    //------------------------------------ Helper functions ----------------------------
    
    // DemoApp helpers
    
    private func testCurrencyChanges(withShipping: Bool){
        setUpForCheckoutSdk(fullBilling: false, withShipping: withShipping, withEmail: false)
        
        setAndUpdateCurrency(currencyName: "Israeli New Sheqel ILS", newCurrencyCode: "ILS", oldCurrencyCode: checkoutCurrency)

        testCurrencyInPayButton(withShipping: withShipping, fillInDetails: true)
    
        setAndUpdateCurrency(currencyName: "US Dollar USD", newCurrencyCode: "USD", oldCurrencyCode: "ILS")
        
        testCurrencyInPayButton(withShipping: withShipping, fillInDetails: false)

    }
    
    private func testCurrencyInPayButton(withShipping: Bool, fillInDetails: Bool){
        if (withShipping){
            gotoShippingScreen(fillInDetails: fillInDetails)
//            _ = checkShippingPayButton()
            BSUITestUtils.pressBackButton(app: app)
        }
            
        else {
//            _ = checkPayButton()
        }
    }
    
    private func setAndUpdateCurrency(currencyName: String, newCurrencyCode: String, oldCurrencyCode: String){
        paymentHelper.setCurrency(currencyName: currencyName)
        sdkRequest.priceDetails.currency = newCurrencyCode
         
        
    }
    
    private func waitForExistingCcScreen() -> BSExistingCcScreenUITestHelper {
        
        let existingCcHelper = BSExistingCcScreenUITestHelper(app:app)
        waitForElementToExist(element: existingCcHelper.billingNameLabel, waitTime: 60)
        return existingCcHelper
    }
    
    
    
}
