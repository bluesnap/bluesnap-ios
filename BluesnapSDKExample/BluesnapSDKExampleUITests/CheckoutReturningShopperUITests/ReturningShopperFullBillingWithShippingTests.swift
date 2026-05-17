//
//  ReturningShopperFullBillingWithShippingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperFullBillingWithShippingTests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Returning shopper Full Billing With Shipping views tests ---------------------------------------- */
    
    func returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_shopperWithMinimalBilling() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_shopperWithMinimalBillingWithEmail() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_shopperWithMinimalBillingWithShipping() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_shopperWithMinimalBillingWithEmailWithShipping() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_shopperWithFullBilling() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_shopperWithFullBillingWithEmail() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_shopperWithFullBillingWithShipping() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperEndToEndFullBillingWithShipping_shopperWithFullBillingWithEmailWithShipping() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: false)

    }
    
}
