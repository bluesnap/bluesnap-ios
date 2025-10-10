//
//  SubscriptionChargeReturningShopperUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 15/04/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import Foundation
import PassKit
import BluesnapSDK

class SubscriptionChargeReturningShopperUITests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Subscription common tests ---------------------------------------- */
    
    func subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, trialPeriodDays: Int? = nil){
        
        setUpForSdkWithReturningShopper(shopperWithFullBilling: checkoutFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping, isSubscription: true, trialPeriodDays: trialPeriodDays)

        // check cc line visibility in existing cc screen
        existingCcHelper.checkExistingCCLineVisibility(expectedLastFourDigits: BSUITestUtils.getValidVisaLast4Digits(), expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
        
        // check all components visibility in existing cc screen
        existingCcHelper.checkScreenItems(sdkRequest: sdkRequest)
        
        // check pay button content
        existingCcHelper.checkPayButton(sdkRequest: sdkRequest, subscriptionHasPriceDetails: trialPeriodDays == nil)
        
        if trialPeriodDays != nil {
            existingCcHelper.pressEditButton(editBilling: true)

            // check currency menu button is disabled in payment screen
            paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
        }
    }
    
    /* -------------------------------- Subscription views tests ---------------------------------------- */
    
    func testAllowCurrencyChange_subscriptionWithPriceDetails(){
        allowCurrencyChangeExistingCCValidation(isEnabled: true, isSubscription: true)
    }
    
    func testNotAllowCurrencyChange_subscriptionWithPriceDetails(){
        allowCurrencyChangeExistingCCValidation(isEnabled: false, isSubscription: true)
    }
    
    func testAllowCurrencyChange_subscriptionWithoutPriceDetails(){
        allowCurrencyChangeExistingCCValidation(isEnabled: false, isSubscription: true, trialPeriodDays: 28)
    }
    
    func testNotAllowCurrencyChange_subscriptionWithoutPriceDetails(){
        allowCurrencyChangeExistingCCValidation(isEnabled: false, isSubscription: true, trialPeriodDays: 28)
    }
    
    func testViewsNoFullBillingNoShippingNoEmail_shopperWithFullBillingWithEmailWithShipping_subscriptionWithoutPriceDetails() {
        subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false, trialPeriodDays: 30)
    }

    func testViewsNoFullBillingNoShippingNoEmail_shopperWithFullBillingWithEmailWithShipping_subscriptionWithPriceDetails() {
        subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false)
    }

    func testViewsFullBillingWithShippingWithEmail_shopperWithFullBillingWithEmailWithShipping_subscriptionWithoutPriceDetails() {
        subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true, trialPeriodDays: 28)
    }

    func testViewsFullBillingWithShippingWithEmail_shopperWithFullBillingWithEmailWithShipping_subscriptionWithPriceDetails() {
        subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    /* -------------------------------- Subscription end-to-end flow tests ---------------------------------------- */
    
    
    func testFlowNoFullBillingNoShippingNoEmail_shopperWithFullBillingWithEmailWithShipping_existingCardSubscription() {
        setUpForSdkWithReturningShopper(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false)
        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: false)
    }
    
    func testFlowFullBillingWithShippingWithEmail_shopperWithFullBillingWithEmailWithShipping_existingCardSubscription() {
        setUpForSdkWithReturningShopper(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true)
        
    }
}

