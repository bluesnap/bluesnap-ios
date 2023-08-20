//
//  ReturningShopperFullBillingWithEmailWithShippingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperFullBillingWithEmailWithShippingTests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Returning shopper Full Billing With Email With Shipping views tests ---------------------------------------- */
    
    func returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_shopperWithMinimalBilling() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_shopperWithMinimalBillingWithEmail() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_shopperWithMinimalBillingWithShipping() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_shopperWithMinimalBillingWithEmailWithShipping() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_shopperWithFullBilling() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_shopperWithFullBillingWithEmail() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_shopperWithFullBillingWithShipping() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperEndToEndFullBillingWithEmailWithShipping_shopperWithFullBillingWithEmailWithShipping() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true)

    }
    
}
