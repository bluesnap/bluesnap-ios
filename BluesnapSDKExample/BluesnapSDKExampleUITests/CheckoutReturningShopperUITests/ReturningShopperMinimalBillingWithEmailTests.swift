//
//  ReturningShopperMinimalBillingWithEmailTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperMinimalBillingWithEmailTests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Returning shopper Minimal Billing With Email views tests ---------------------------------------- */
    
    func returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: false, checkoutWithEmail: true, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_shopperWithMinimalBilling() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_shopperWithMinimalBillingWithEmail() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_shopperWithMinimalBillingWithShipping() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_shopperWithMinimalBillingWithEmailWithShipping() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_shopperWithFullBilling() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_shopperWithFullBillingWithEmail() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_shopperWithFullBillingWithShipping() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperEndToEndMinimalBillingWithEmail_shopperWithFullBillingWithEmailWithShipping() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: true)

    }
    
}
