//
//  ReturningShopperMinimalBillingWithShippingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperMinimalBillingWithShippingTests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Returning shopper Minimal Billing With Shipping views tests ---------------------------------------- */
    
    func returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_shopperWithMinimalBilling() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_shopperWithMinimalBillingWithEmail() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_shopperWithMinimalBillingWithShipping() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_shopperWithMinimalBillingWithEmailWithShipping() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_shopperWithFullBilling() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_shopperWithFullBillingWithEmail() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_shopperWithFullBillingWithShipping() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperEndToEndMinimalBillingWithShipping_shopperWithFullBillingWithEmailWithShipping() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: true, withEmail: false)

    }
    
    func testAllowCurrencyChange(){
        allowCurrencyChangeExistingCCValidation(isEnabled: true)
    }
    
    func testNotAllowCurrencyChange(){
        allowCurrencyChangeExistingCCValidation(isEnabled: false)
    }
    
}
