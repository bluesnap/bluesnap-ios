//
//  CheckoutBaseTester.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 06/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import PassKit
import BluesnapSDK
//@testable import BluesnapSDKIntegrationTests //TODO: make it work

class CheckoutBaseTester: UIBaseTester{
//    internal var isReturningShopper: Bool = false
    
    internal func setUpForCheckoutSdk(fullBilling: Bool, withShipping: Bool, withEmail: Bool, allowCurrencyChange: Bool = true, hideStoreCardSwitch: Bool = false, isReturningShopper: Bool = false, shopperId: String? = nil, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false, isSubscription: Bool = false, trialPeriodDays: Int? = nil){

        super.setUpForSdk(fullBilling: fullBilling, withShipping: withShipping, withEmail: withEmail, allowCurrencyChange: allowCurrencyChange, hideStoreCardSwitch: hideStoreCardSwitch, isReturningShopper: isReturningShopper, shopperId: shopperId, trialPeriodDays: trialPeriodDays)
        
        // start checkout
        gotoPaymentScreen(shopperId: shopperId, tapExistingCc: tapExistingCc, checkExistingCcLine: checkExistingCcLine, isSubscription: isSubscription)
    }
    
    private func gotoPaymentScreen(shopperId: String? = nil, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false, isSubscription: Bool = false){
        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)
        
        // click "Checkout" button / "Subscription" button
        BSUITestUtils.closeKeyboard(app: app, inputToTap: app.textFields["TaxField"])
        if(isSubscription){
            app.buttons["SubscriptionButton"].tap()

        } else {
            app.buttons["CheckoutButton"].tap()
        }
        
        // wait for payment type screen to load
        let ccButton = paymentTypeHelper.getCcButtonElement()
        waitForElementToExist(element: ccButton, waitTime: 120)
        
        // make sure payment type buttons are visible
        paymentTypeHelper.checkPaymentTypes(expectedApplePay: true, expectedPayPal: !isSubscription, expectedCC: true)
        
        if tapExistingCc {
            if (checkExistingCcLine) {// check existing CC line
                paymentTypeHelper.checkExistingCCLine(index: 0, expectedLastFourDigits: "1111", expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
            }
            
            // click existing CC
            app.buttons["existingCc0"].tap()
            
        } else {
            // click New CC button
            app.buttons["CcButton"].tap()
            waitForPaymentScreen()
        }
    }
    
    /* -------------------------------- Checkout Flow Common Tests ---------------------------------------- */
    
    internal func newCardBasicCheckoutFlow(fullBilling: Bool, withShipping: Bool, withEmail: Bool, shippingSameAsBilling: Bool = false, hideStoreCardSwitch: Bool = false, storeCard: Bool = false, isSubscription: Bool = false) {
        
        setUpForCheckoutSdk(fullBilling: fullBilling, withShipping: withShipping, withEmail: withEmail, hideStoreCardSwitch: hideStoreCardSwitch,isSubscription: isSubscription)
        
        //TODO: add store card visibility check
        
        if (hideStoreCardSwitch){
            paymentHelper.checkStoreCardVisibilityAndState(shouldBeVisible: !hideStoreCardSwitch)
        }
        
        newCardBasicFillInInfoAndPay(shippingSameAsBilling: shippingSameAsBilling, storeCard: storeCard)
        
        checkResult(expectedSuccessText: "Success!")
        
        let shopperIdLabel = app.staticTexts["ShopperIdLabel"]
        waitForElementToExist(element: shopperIdLabel, waitTime: 300)
        
        var shopperId: String = shopperIdLabel.label
        let range = shopperId.startIndex..<shopperId.index(shopperId.startIndex, offsetBy: 12)
        
        shopperId.removeSubrange(range)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DemoAPIHelper.retrieveVaultedShopper(vaultedShopperId: shopperId, completion: {
            isSuccess, data in
            XCTAssert(isSuccess, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")
            
            let error = BSUITestUtils.checkRetrieveVaultedShopperResponse(responseBody: data!, sdkRequest: self.sdkRequest, cardStored: storeCard, expectedCreditCardInfo: [("1111", "VISA", "11","2026")], shippingSameAsBilling: shippingSameAsBilling, isSubscription: isSubscription)
            
            XCTAssertNil(error, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")
            
            semaphore.signal()
        })
        
        semaphore.wait()
        
    }
    
    private func newCardBasicFillInInfoAndPay(shippingSameAsBilling: Bool = false, storeCard: Bool = false) {
        // fill in info in payment screen and continue to shipping or paying
        fillBillingDetails(ccn: BSUITestUtils.getValidVisaCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: getDummyBillingDetails())
        
        if (storeCard){
            setStoreCardSwitch(shouldBeOn: true)
        }
        
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
    
    internal func existingCardBasicCheckoutFlow(existingCcHelper: BSExistingCcScreenUITestHelper, vaultedShopperId: String, fullBilling: Bool, withShipping: Bool, withEmail: Bool){
        //        setUpForSdkWithReturningShopper(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: fullBilling, checkoutWithEmail: withEmail, checkoutWithShipping: withShipping)
        
        //        newCardBasicFillInInfoAndPay(shippingSameAsBilling: shippingSameAsBilling)
        
        existingCcHelper.pressPayButton()
        
        checkResult(expectedSuccessText: "Success!")
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DemoAPIHelper.retrieveVaultedShopper(vaultedShopperId: vaultedShopperId, completion: {
            isSuccess, data in
            XCTAssert(isSuccess, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")
            
            let error = BSUITestUtils.checkRetrieveVaultedShopperResponse(responseBody: data!, sdkRequest: self.sdkRequest, cardStored: true, expectedCreditCardInfo: [("1111", "VISA", "11","2026")])
            
            XCTAssertNil(error, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")
            
            semaphore.signal()
        })
        
        semaphore.wait()
        
        print("done")
        
    }
    
    internal func allowCurrencyChangeNewCCValidation(isEnabled: Bool, isSubscription: Bool = false, trialPeriodDays: Int? = nil){
        setUpForCheckoutSdk(fullBilling: false, withShipping: true, withEmail: false, allowCurrencyChange: isEnabled, isSubscription: isSubscription, trialPeriodDays: trialPeriodDays)
        
        // check currency menu button visibility in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
        // check currency menu button visibility after opening country screen
        paymentHelper.setCountry(countryCode: "US")
        
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
        if (isSubscription) {
            paymentHelper.setStoreCardSwitch(shouldBeOn: true)
        }
        
        gotoShippingScreen()
        
        BSUITestUtils.pressBackButton(app: app)
        
        // check urrency menu button visibility back in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
    }
    
}

