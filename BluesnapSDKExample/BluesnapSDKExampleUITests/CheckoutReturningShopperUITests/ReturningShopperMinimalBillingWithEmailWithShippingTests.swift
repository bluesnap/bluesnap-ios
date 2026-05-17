//
//  ReturningShopperMinimalBillingWithEmailWithShippingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperMinimalBillingWithEmailWithShippingTests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Returning shopper Full Billing With Email With Shipping views tests ---------------------------------------- */
    
    func returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: false, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_shopperWithMinimalBilling() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_shopperWithMinimalBillingWithEmail() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_shopperWithMinimalBillingWithShipping() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_shopperWithMinimalBillingWithEmailWithShipping() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_shopperWithFullBilling() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_shopperWithFullBillingWithEmail() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_shopperWithFullBillingWithShipping() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperEndToEndMinimalBillingWithEmailWithShipping_shopperWithFullBillingWithEmailWithShipping() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: true, withEmail: true)

    }
    
}
