//
//  ReturningShopperFullBillingWithEmailTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperFullBillingWithEmailTests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Returning shopper Full Billing With Email views tests ---------------------------------------- */
    
    func returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_shopperWithMinimalBilling() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_shopperWithMinimalBillingWithEmail() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_shopperWithMinimalBillingWithShipping() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_shopperWithMinimalBillingWithEmailWithShipping() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_shopperWithFullBilling() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_shopperWithFullBillingWithEmail() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_shopperWithFullBillingWithShipping() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperEndToEndFullBillingWithEmail_shopperWithFullBillingWithEmailWithShipping() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: false, withEmail: true)
    }
    
}
