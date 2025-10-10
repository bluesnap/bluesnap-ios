//
//  ReturningShopperFullBillingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperFullBillingTests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Returning shopper Full Billing views tests ---------------------------------------- */
    
    func returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_shopperWithMinimalBilling() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_shopperWithMinimalBillingWithEmail() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_shopperWithMinimalBillingWithShipping() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBilling_shopperWithMinimalBillingWithEmailWithShipping() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBilling_shopperWithFullBilling() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_shopperWithFullBillingWithEmail() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_shopperWithFullBillingWithShipping() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperEndToEndFullBilling_shopperWithFullBillingWithEmailWithShipping() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: false, withEmail: false)
    }
}
