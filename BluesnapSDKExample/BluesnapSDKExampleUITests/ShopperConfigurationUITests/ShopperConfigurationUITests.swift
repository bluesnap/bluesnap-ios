//
// Created by Sivani on 2019-02-18.
// Copyright (c) 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest

class ShopperConfigurationUITests: UIBaseTester {

    internal var existingCcHelper: BSExistingCcScreenUITestHelper!
    internal var vaultedShopperId: String!

    internal func setUpForChoosePaymentMethodSdk(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, allowCurrencyChange: Bool = false, hideStoreCardSwitch: Bool = false, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false) {

        // initialize required helpers
        if (tapExistingCc) {
            isExistingCard = true
            existingCcHelper = BSExistingCcScreenUITestHelper(app: app)
        }

//        printShopperDiscription(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)

        let semaphore = DispatchSemaphore(value: 0)

        DemoAPIHelper.createVaultedShopper(fullBilling: shopperWithFullBilling, withEmail: shopperWithEmail, withShipping: shopperWithShipping, billingInfo: getDummyBillingDetails(), shippingInfo: getDummyShippingDetails(), creditCard: (Int(BSUITestUtils.getValidExpYear()) ?? 2026, Int(BSUITestUtils.getValidCvvNumber()) ?? 333, BSUITestUtils.getValidExpMonth(), BSUITestUtils.getValidVisaCreditCardNumberWithoutSpaces()), completion: { shopperId, error in
            if let shopperId_ = shopperId {
                self.vaultedShopperId = shopperId_
                semaphore.signal()
            }
        })

        semaphore.wait()

        super.setUpForSdk(fullBilling: checkoutFullBilling, withShipping: checkoutWithShipping, withEmail: checkoutWithEmail, allowCurrencyChange: allowCurrencyChange, hideStoreCardSwitch: hideStoreCardSwitch, isReturningShopper: true, shopperId: vaultedShopperId)

        if (shopperWithShipping) {
            isShippingSameAsBillingOn = false
        }
        
        setShopperDetailsInSdkRequest(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, tapExistingCc: tapExistingCc)

        // start checkout
        gotoPaymentScreen(shopperId: vaultedShopperId, tapExistingCc: tapExistingCc, checkExistingCcLine: checkExistingCcLine)
    }

    private func setShopperDetailsInSdkRequest(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, tapExistingCc: Bool = false){

        // set billing/shipping info
        if (tapExistingCc){
            sdkRequest.shopperConfiguration.billingDetails?.name = BSUITestUtils.getDummyBillingDetails().name
            
            if (shopperWithEmail){
                sdkRequest.shopperConfiguration.billingDetails?.email = BSUITestUtils.getDummyBillingDetails().email!
            }
        }
        
        if(shopperWithShipping){
            sdkRequest.shopperConfiguration.shippingDetails = BSUITestUtils.getDummyShippingDetails()
        }
        
    }

    private func gotoPaymentScreen(shopperId: String? = nil, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false) {
        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)

        // click "Checkout" button
        app.buttons["ChooseButton"].tap()

        // wait for payment type screen to load

        let ccButton = paymentTypeHelper.getCcButtonElement()
        waitForElementToExist(element: ccButton, waitTime: 120)

        // make sure payment type buttons are visible
        paymentTypeHelper.checkPaymentTypes(expectedApplePay: true, expectedPayPal: true, expectedCC: true)

        if tapExistingCc {
            if (checkExistingCcLine) {// check existing CC line
                paymentTypeHelper.checkExistingCCLine(index: 0, expectedLastFourDigits: "1111", expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
            }

            // click existing CC
            app.buttons["existingCc0"].tap()

        } else {
            // click New CC button
            app.buttons["CcButton"].tap()
        }
    }
    
    internal func setUpForCreatePaymentSdk(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false) {
        
        setUpForChoosePaymentMethodSdk(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping, tapExistingCc: tapExistingCc, checkExistingCcLine: checkExistingCcLine)
        
        if (!tapExistingCc){
            newCardBasicFillInInfoAndPay()
        }
            
        else{
            existingCardBasicFillInInfoAndPay(checkoutWithShipping: checkoutWithShipping)
        }
        
        checkResult(expectedSuccessText: "Success!")
        
        app.buttons["TryAgainButton"].tap()
    }


    /* -------------------------------- Choose Payment Method Common tests ---------------------------------------- */

    func chooseNewCardPaymentMethodViewsCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, shippingSameAsBilling: Bool = false){
        
        setUpForChoosePaymentMethodSdk(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping)

        // check currency menu button is disabled in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.closeKeyboard()
        paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: true)
        
        if (checkoutWithShipping){
            let expectedShippingSameAsBilling = checkoutFullBilling && !shopperWithShipping
            paymentHelper.checkShippingSameAsBillingSwitch(shouldBeVisible: expectedShippingSameAsBilling , shouldBeOn: expectedShippingSameAsBilling)
            
            if (expectedShippingSameAsBilling){
                // check pay button when shipping same as billing is on
                paymentHelper.checkDoneButton()
                setShippingSameAsBillingSwitch(shouldBeOn: false)
            }
            
            // check pay button when shipping same as billing is off
            paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)
            
            // set store card switch to true
            setStoreCardSwitch(shouldBeOn: true)
            
            // continue to shipping screen
            gotoShippingScreen()
            
            // check Inputs Fields visibility (including error messages)
            shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
            
            // check shipping pay button
            shippingHelper.checkDoneButton()
        }
        
        else {
            // check pay button when shipping same as billing is on
            paymentHelper.checkDoneButton()
            
            // check store card visibility after changing screens
            paymentHelper.checkStoreCardVisibilityAfterChangingScreens(shouldBeVisible: true, setTo: true, sdkRequest: sdkRequest)
            
            // check store card visibility after changing screens
            paymentHelper.checkStoreCardVisibilityAfterChangingScreens(shouldBeVisible: true, setTo: false, sdkRequest: sdkRequest)
        }
    }
    
    func allowCurrencyChangeNewCCValidation(allowCurrencyChange: Bool){
    
        setUpForChoosePaymentMethodSdk(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: true, allowCurrencyChange: allowCurrencyChange)
        
        // check currency menu button visibility in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
        // check currency menu button visibility after opening country screen
        paymentHelper.setCountry(countryCode: "US")
        
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
        paymentHelper.setStoreCardSwitch(shouldBeOn: true)
        
        gotoShippingScreen()
        
        BSUITestUtils.pressBackButton(app: app)
        
        // check urrency menu button visibility back in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
    }
    
    func allowCurrencyChangeExistingCCValidation(allowCurrencyChange: Bool){
        setUpForChoosePaymentMethodSdk(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: true, allowCurrencyChange: allowCurrencyChange, tapExistingCc: true)
        
        // check currency menu button visibility in existing cc screen
        existingCcHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
        existingCcHelper.pressEditButton(editBilling: true)
        
        // check currency menu button visibility in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
        // check currency menu button visibility after opening country screen
        paymentHelper.setCountry(countryCode: "US")
        
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
        BSUITestUtils.pressBackButton(app: app)
        
        // check urrency menu button visibility back in existing cc screen
        existingCcHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
    }
    
    func chooseExistingCardPaymentMethodFViewsCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool) {
        
        setUpForChoosePaymentMethodSdk(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping, tapExistingCc: true, checkExistingCcLine: true)

        // check cc line visibility in existing cc screen
        existingCcHelper.checkExistingCCLineVisibility(expectedLastFourDigits: BSUITestUtils.getValidVisaLast4Digits(), expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
        
        // check all components visibility in existing cc screen
        existingCcHelper.checkScreenItems(sdkRequest: sdkRequest)
        
        // check pay button content
        existingCcHelper.checkDoneButton()
        
        existingCcHelper.pressEditButton(editBilling: true)
        
        // check currency menu button is disabled in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
    }
    
    func chooseNewCardPaymentMethodFlow(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, shippingSameAsBilling: Bool = false) {

        setUpForChoosePaymentMethodSdk(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping)

        
        newCardBasicFillInInfoAndPay(shippingSameAsBilling: shippingSameAsBilling)

        checkResult(expectedSuccessText: "Success!")
        
        let semaphore = DispatchSemaphore(value: 0)

        DemoAPIHelper.retrieveVaultedShopper(vaultedShopperId: vaultedShopperId, completion: {
            isSuccess, data in
            XCTAssert(isSuccess, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            let error = BSUITestUtils.checkRetrieveVaultedShopperResponse(responseBody: data!, sdkRequest: self.sdkRequest, cardStored: true, expectedCreditCardInfo: [(BSUITestUtils.getValidVisaLast4Digits(), "VISA", BSUITestUtils.getValidExpMonth(),BSUITestUtils.getValidExpYear()), (BSUITestUtils.getValidMCLast4Digits(), "MASTERCARD", BSUITestUtils.getValidExpMonth(),BSUITestUtils.getValidExpYear())], chosenPaymentMethod: "CC", cardIndex: 1)

            XCTAssertNil(error, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            semaphore.signal()
        })

        semaphore.wait()

    }

    func newCardBasicFillInInfoAndPay(shippingSameAsBilling: Bool = false) {
        // fill in info in payment screen and continue to shipping or paying
        fillBillingDetails(ccn: BSUITestUtils.getValidMCCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: getDummyBillingDetails())
        
        // set store card switch to True
        setStoreCardSwitch(shouldBeOn: true)

        // continue to shipping it's required and fill in info in shipping screen
        if (sdkRequest.shopperConfiguration.withShipping && !shippingSameAsBilling){
            if (isShippingSameAsBillingOn){
                setShippingSameAsBillingSwitch(shouldBeOn: false)
            }
            gotoShippingScreen(fillInDetails: false)
            fillShippingDetails(shippingDetails: getDummyShippingDetails())
            shippingHelper.pressPayButton()
        }

        else{
            paymentHelper.pressPayButton()
        }
    }
    
    func chooseExistingCardPaymentMethodFlow(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool){
        
        setUpForChoosePaymentMethodSdk(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping, tapExistingCc: true, checkExistingCcLine: true)
        
        existingCardBasicFillInInfoAndPay(checkoutWithShipping: checkoutWithShipping)
        
        checkResult(expectedSuccessText: "Success!")
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DemoAPIHelper.retrieveVaultedShopper(vaultedShopperId: vaultedShopperId, completion: {
            isSuccess, data in
            XCTAssert(isSuccess, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")
            
            let error = BSUITestUtils.checkRetrieveVaultedShopperResponse(responseBody: data!, sdkRequest: self.sdkRequest, cardStored: true, expectedCreditCardInfo: [(BSUITestUtils.getValidVisaLast4Digits(), "VISA", BSUITestUtils.getValidExpMonth(),BSUITestUtils.getValidExpYear())], chosenPaymentMethod: "CC", cardIndex: 0)
            
            XCTAssertNil(error, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")
            
            semaphore.signal()
        })
        
        semaphore.wait()
        
    }
    
    func existingCardBasicFillInInfoAndPay(checkoutWithShipping: Bool) {
        existingCcHelper.pressEditButton(editBilling: true)
        setBillingDetails(billingDetails: BSUITestUtils.getDummyEditBillingDetails())
        paymentHelper.pressPayButton()
        
        if (checkoutWithShipping){
            existingCcHelper.pressEditButton(editBilling: false)
            setShippingDetails(shippingDetails: BSUITestUtils.getDummyEditShippingDetails())
            shippingHelper.pressPayButton()
        }
        
        existingCcHelper.pressPayButton()
    }

    /* -------------------------------- Choose Payment Method views tests ---------------------------------------- */
    
    func testViewsChooseNewCCPaymentMinimalBilling(){
        chooseNewCardPaymentMethodViewsCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testViewsChooseNewCCPaymentFullBillingWithShippingWithEmail(){
        chooseNewCardPaymentMethodViewsCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testViewsChooseNewCCPaymentFullBillingWithShippingWithEmail_shopperWithFullBillingWithEmailWithShipping(){
        chooseNewCardPaymentMethodViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testAllowCurrencyChangeInChooseNewCCPaymentMethod(){
        allowCurrencyChangeNewCCValidation(allowCurrencyChange: true)
    }
    
    func testNotAllowCurrencyChangeInChooseNewCCPaymentMethod(){
        allowCurrencyChangeNewCCValidation(allowCurrencyChange: false)
    }
    
    func testViewsChooseExistingCCPaymentMinimalBilling(){
        chooseExistingCardPaymentMethodFViewsCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false)
    }

    func testViewsChooseExistingCCPaymentFullBillingWithShippingWithEmail(){
        chooseExistingCardPaymentMethodFViewsCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testAllowCurrencyChangeInChooseExistingCCPaymentMethod(){
        allowCurrencyChangeExistingCCValidation(allowCurrencyChange: true)
    }
    
    func testNotAllowCurrencyChangeInChooseExistingCCPaymentMethod(){
        allowCurrencyChangeExistingCCValidation(allowCurrencyChange: false)
    }
    
    /* -------------------------------- Choose Payment Method end-to-end flow tests ---------------------------------------- */

    func testFlowChooseNewCCPaymentMinimalBilling(){
        chooseNewCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testFlowChooseNewCCPaymentFullBillingWithShippingWithEmail(){
        chooseNewCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testFlowChooseExistingCCPaymentMinimalBilling(){
        chooseExistingCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testFlowChooseExistingCCPaymentFullBillingWithShippingWithEmail(){
        chooseExistingCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    /* -------------------------------- Create Payment Common tests ---------------------------------------- */
    
    
    func createCreditCardPaymentMethodFlow(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false) {
        setUpForCreatePaymentSdk(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping, tapExistingCc: tapExistingCc, checkExistingCcLine: checkExistingCcLine)
        
        setPurchaseAmount(waitToExist: true)
        
        app.buttons["CreateButton"].tap()

        // TODO: Restore this when the server bug is fixed
        checkResult(expectedSuccessText: "Success!")

        let semaphore = DispatchSemaphore(value: 0)

        DemoAPIHelper.retrieveVaultedShopper(vaultedShopperId: vaultedShopperId, completion: {
            isSuccess, data in
            XCTAssert(isSuccess, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            let expectedCreditCardInfo = tapExistingCc ? [(BSUITestUtils.getValidVisaLast4Digits(), "VISA", BSUITestUtils.getValidExpMonth(),BSUITestUtils.getValidExpYear())] : [(BSUITestUtils.getValidVisaLast4Digits(), "VISA", BSUITestUtils.getValidExpMonth(),BSUITestUtils.getValidExpYear()), (BSUITestUtils.getValidMCLast4Digits(), "MASTERCARD", BSUITestUtils.getValidExpMonth(),BSUITestUtils.getValidExpYear())]
    
            let cardIndex = tapExistingCc ? 0 : 1
            
            let error = BSUITestUtils.checkRetrieveVaultedShopperResponse(responseBody: data!, sdkRequest: self.sdkRequest, cardStored: true, expectedCreditCardInfo: expectedCreditCardInfo, chosenPaymentMethod: "CC", cardIndex: cardIndex)
            
         

            XCTAssertNil(error, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            semaphore.signal()
        })

        semaphore.wait()
        
    }
    
    /* -------------------------------- Create Payment end-to-end flow tests ---------------------------------------- */
    
    func testFlowCreateNewCCPaymentMinimalBilling(){
        createCreditCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false, tapExistingCc: false, checkExistingCcLine: false)
    }
    
    func testFlowCreateNewCCPaymentFullBillingWithShippingWithEmail(){
        createCreditCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testFlowCreateExistingCCPaymentMinimalBilling(){
        createCreditCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false, tapExistingCc: true, checkExistingCcLine: true)
    }
    
    func testFlowCreateExistingCCPaymentFullBillingWithShippingWithEmail(){
        createCreditCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true, tapExistingCc: true, checkExistingCcLine: true)
    }



}
