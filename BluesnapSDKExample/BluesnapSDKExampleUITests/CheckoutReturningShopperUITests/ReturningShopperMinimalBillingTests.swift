//
//  ReturningShopperMinimalBillingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperMinimalBillingTests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Returning shopper Minimal Billing views tests ---------------------------------------- */
    
    func returningShopperViewsMinimalBillingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBilling_shopperWithMinimalBilling() {
        returningShopperViewsMinimalBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBilling_shopperWithMinimalBillingWithEmail() {
        returningShopperViewsMinimalBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBilling_shopperWithMinimalBillingWithShipping() {
        returningShopperViewsMinimalBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBilling_shopperWithMinimalBillingWithEmailWithShipping() {
        returningShopperViewsMinimalBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBilling_shopperWithFullBilling() {
        returningShopperViewsMinimalBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBilling_shopperWithFullBillingWithEmail() {
        returningShopperViewsMinimalBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBilling_shopperWithFullBillingWithShipping() {
        returningShopperViewsMinimalBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperEndToEndMinimalBilling_shopperWithFullBillingWithEmailWithShipping() {
        returningShopperViewsMinimalBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: false)

    }
}
