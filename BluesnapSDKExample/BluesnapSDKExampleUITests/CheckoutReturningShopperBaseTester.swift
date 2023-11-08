//
//  CheckoutReturningShopperUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 06/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest

class CheckoutReturningShopperBaseTester: CheckoutBaseTester {
    internal var existingCcHelper: BSExistingCcScreenUITestHelper!
    internal var vaultedShopperId: String!
//    internal var fullBillingDisplay: Bool!
//    internal var emailDisplay: Bool!
//    internal var shippingDisplay: Bool!

//    override func setUp() {
//        super.setUp()
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//
//        //        app.terminate()
//
//    }
    
    internal func setUpForSdkWithReturningShopper(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, allowCurrencyChange: Bool = true, isSubscription: Bool = false, trialPeriodDays: Int? = nil){
        
        // initialize required helpers
        existingCcHelper = BSExistingCcScreenUITestHelper(app: app)
        
        printShopperDiscription(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DemoAPIHelper.createVaultedShopper(fullBilling: shopperWithFullBilling, withEmail: shopperWithEmail, withShipping: shopperWithShipping, billingInfo: getDummyBillingDetails(), shippingInfo: getDummyShippingDetails(), creditCard: (Int(BSUITestUtils.getValidExpYear()) ?? 2026, Int(BSUITestUtils.getValidCvvNumber()) ?? 333, BSUITestUtils.getValidExpMonth(), BSUITestUtils.getValidVisaCreditCardNumberWithoutSpaces()), completion: { shopperId, error in
            if let shopperId_ = shopperId {
                self.vaultedShopperId = shopperId_
                semaphore.signal()
            }
        })
        
        semaphore.wait()

        isExistingCard = true
        setUpForCheckoutSdk(fullBilling: checkoutFullBilling, withShipping: checkoutWithShipping, withEmail: checkoutWithEmail, allowCurrencyChange: allowCurrencyChange, isReturningShopper: true, shopperId: vaultedShopperId, tapExistingCc: true, checkExistingCcLine: true, isSubscription: isSubscription, trialPeriodDays: trialPeriodDays)
        
        setShopperDetailsInSdkRequest(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)
        
    }
    
    func setShopperDetailsInSdkRequest(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        
        // set billing/shipping info
        sdkRequest.shopperConfiguration.billingDetails = BSUITestUtils.getDummyBillingDetails()
        if (!shopperWithEmail){
            sdkRequest.shopperConfiguration.billingDetails?.email = nil
        }
        
        if (!shopperWithFullBilling){
            sdkRequest.shopperConfiguration.billingDetails?.address = nil
            sdkRequest.shopperConfiguration.billingDetails?.city = nil
            sdkRequest.shopperConfiguration.billingDetails?.state = nil
        }
        
        if(shopperWithShipping){
            sdkRequest.shopperConfiguration.shippingDetails = BSUITestUtils.getDummyShippingDetails()
        }
        
        else{
            sdkRequest.shopperConfiguration.shippingDetails?.name = sdkRequest.shopperConfiguration.billingDetails?.name
            sdkRequest.shopperConfiguration.shippingDetails?.zip = sdkRequest.shopperConfiguration.billingDetails?.zip
            sdkRequest.shopperConfiguration.shippingDetails?.country = sdkRequest.shopperConfiguration.billingDetails?.country
            if (sdkRequest.shopperConfiguration.fullBilling){
                sdkRequest.shopperConfiguration.shippingDetails?.address = sdkRequest.shopperConfiguration.billingDetails?.address
                sdkRequest.shopperConfiguration.shippingDetails?.city = sdkRequest.shopperConfiguration.billingDetails?.city
                sdkRequest.shopperConfiguration.shippingDetails?.state = sdkRequest.shopperConfiguration.billingDetails?.state
            }
        }
    
    }
    
    func printShopperDiscription(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool) {
        print("Shopper \(String(describing: vaultedShopperId)), with Full Billing: \(shopperWithFullBilling), with Email: \(shopperWithEmail), with Shipping: \(shopperWithShipping)")
        
    }
    
    /* -------------------------------- Returning shopper Common tests ---------------------------------------- */

    
    internal func allowCurrencyChangeExistingCCValidation(isEnabled: Bool, isSubscription: Bool = false, trialPeriodDays: Int? = nil){
        setUpForSdkWithReturningShopper(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: true, allowCurrencyChange: isEnabled, isSubscription: isSubscription, trialPeriodDays: trialPeriodDays)
        
        // check currency menu button visibility in existing cc screen
        existingCcHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
        existingCcHelper.pressEditButton(editBilling: true)
        
        // check currency menu button visibility in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
        // check currency menu button visibility after opening country screen
        paymentHelper.setCountry(countryCode: "US")
        
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: false)
        
        BSUITestUtils.pressBackButton(app: app)
        
        // check urrency menu button visibility back in existing cc screen
        existingCcHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
    }
    
    internal func returningShopperViewsCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool) {
        
        // set-up for sdk and start returning shopper checkout (with cc line validation in payment type screen)
        setUpForSdkWithReturningShopper(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping)
        
        // check cc line visibility in existing cc screen
        existingCcHelper.checkExistingCCLineVisibility(expectedLastFourDigits: BSUITestUtils.getValidVisaLast4Digits(), expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
        
        // check all components visibility in existing cc screen
        existingCcHelper.checkScreenItems(sdkRequest: sdkRequest)
        
        // check pay button content
        existingCcHelper.checkPayButton(sdkRequest: sdkRequest)
        
        let (fullBillingDisplay, emailDisplay, shippingDisplay) = getDisplayConfiguration(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)

        // check summarized billing info visibility in existing cc screen
        existingCardPaymentAndShippingInfoVisibilityTest(isBilling: true, fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, shippingDisplay: shippingDisplay, screenHelper: paymentHelper)
        
        // check summarized shipping info visibility in existing cc screen
        if (checkoutWithShipping){
            existingCardPaymentAndShippingInfoVisibilityTest(isBilling: false, fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, shippingDisplay: shippingDisplay, screenHelper: shippingHelper)
        }
        
        // inner views tests: only for one option (matching configurations)
        if (shopperWithFullBilling == sdkRequest.shopperConfiguration.fullBilling &&
            shopperWithEmail == sdkRequest.shopperConfiguration.withEmail &&
            shopperWithShipping == sdkRequest.shopperConfiguration.withShipping){
            
            existingCardPaymentAndShippingEditInfoTest(fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, shippingDisplay: shippingDisplay)
        }
        
        else{
            checkComponentOpensIfMissingInfo(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)
        }
    }
    
    internal  func existingCardBasicCheckoutFlow(fullBilling: Bool, withShipping: Bool, withEmail: Bool){
        existingCardBasicCheckoutFlow(existingCcHelper: existingCcHelper, vaultedShopperId: vaultedShopperId, fullBilling: fullBilling, withShipping: withShipping, withEmail: withEmail)
    }
    
    /* -------------------------------- Returning Shopper Private Functions Tests ---------------------------------------- */
    
    // Return expected display configuration for full billing, shipping and email
    private func getDisplayConfiguration(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool) -> (Bool, Bool, Bool) {
        
        let fullBillingDisplay = sdkRequest.shopperConfiguration.fullBilling && shopperWithFullBilling
        let emailDisplay = sdkRequest.shopperConfiguration.withEmail && shopperWithEmail
        let shippingDisplay = sdkRequest.shopperConfiguration.withShipping && shopperWithShipping
        
        return (fullBillingDisplay, emailDisplay, shippingDisplay)
    }
    
    /*
     This test verifies that the summarized billing/shipping contact info and the
     billing/shipping contact info presents the correct content.
     Pre-condition: current screen is ExistingCC
     */
    private func existingCardPaymentAndShippingInfoVisibilityTest(isBilling: Bool, fullBillingDisplay: Bool, emailDisplay: Bool, shippingDisplay: Bool, screenHelper: BSCreditCardScreenUITestHelperBase){
        
        // check summarized info visibility in existing cc screen
        existingCcHelper.checkNameLabelContent(sdkRequest: sdkRequest, isBilling: isBilling)
        existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: isBilling, fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, shippingDisplay: shippingDisplay)
        
        // check that the component info presents the correct content (when pressing edit)
        existingCcHelper.pressEditButton(editBilling: isBilling)
        screenHelper.checkInputsVisibility(sdkRequest: sdkRequest)
        
        //go back to ExistingCC screen
        BSUITestUtils.pressBackButton(app: app)
    }
    
    /*
     Pre-condition: current screen is ExistingCC
     */
    private func existingCardPaymentAndShippingEditInfoTest(fullBillingDisplay: Bool, emailDisplay: Bool, shippingDisplay: Bool){
        
        // check that the summarized billing info presents the old content after editing but not pressing "Done" button (but "back")
        editBillingDetailsValidation(fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, useDoneButton: false)
        
        // check that the summarized billing info presents the new content after editing and pressing "Done" button (not "back")
        editBillingDetailsValidation(fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, useDoneButton: true)
        
        if (sdkRequest.shopperConfiguration.withShipping){

            // check that the summarized shipping info presents the old content after editing but not pressing "Done" button (but "back")
            editShippingDetailsValidation(fullBillingDisplay: fullBillingDisplay, shippingDisplay: shippingDisplay, useDoneButton: false)
            
            // check that the summarized shipping info presents the new content after editing and pressing "Done" button (not "back")
            editShippingDetailsValidation(fullBillingDisplay: fullBillingDisplay, shippingDisplay: shippingDisplay, useDoneButton: true)
        }
    }
    
    /*
     This test verifies that the summarized billing contact info and the
     billing contact info presents the correct content after editing the info,
     If useDoneButton is true then it uses "Done" button and verifies the info changes,
     o.w. it uses the "Back" button and verifies the info doesn't change.
     Pre-condition: current screen is ExistingCC
     */
    private func editBillingDetailsValidation(fullBillingDisplay: Bool, emailDisplay: Bool, useDoneButton: Bool){
        existingCcHelper.editBillingButton.tap()
        
        if (useDoneButton){
            setBillingDetails(billingDetails: BSUITestUtils.getDummyEditBillingDetails())
            paymentHelper.pressPayButton()
            existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: true, fullBillingDisplay: sdkRequest.shopperConfiguration.fullBilling, emailDisplay: sdkRequest.shopperConfiguration.withEmail, shippingDisplay: false)
        }
        
        else {
            // fill in billing info without saving in sdkRequest
            paymentHelper.setFieldValues(billingDetails: BSUITestUtils.getDummyEditBillingDetails(), sdkRequest: sdkRequest)
            BSUITestUtils.pressBackButton(app: app)
            existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: true, fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, shippingDisplay: false)
        }
        
        existingCcHelper.editBillingButton.tap()
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        BSUITestUtils.pressBackButton(app: app)
    }
    
    /*
     This test verifies that the summarized shipping contact info and the
     billing contact info presents the correct content after editing the info,
     If useDoneButton is true then it uses "Done" button and verifies the info changes,
     o.w. it uses the "Back" button and verifies the info doesn't change.
     Pre-condition: current screen is ExistingCC
     */
    private func editShippingDetailsValidation(fullBillingDisplay: Bool, shippingDisplay: Bool, useDoneButton: Bool){
        existingCcHelper.editShippingButton.tap()

        if (useDoneButton){
            setShippingDetails(shippingDetails: BSUITestUtils.getDummyEditShippingDetails())
            shippingHelper.pressPayButton()
            
            existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: false, fullBillingDisplay: false, emailDisplay: false, shippingDisplay: true)
        }
            
        else {
            // fill in shipping info without saving in sdkRequest
            shippingHelper.setFieldValues(shippingDetails: BSUITestUtils.getDummyEditShippingDetails(), sdkRequest: sdkRequest)

            BSUITestUtils.pressBackButton(app: app)
            existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: false, fullBillingDisplay: fullBillingDisplay, emailDisplay: false, shippingDisplay: shippingDisplay)
        }
        
        existingCcHelper.editShippingButton.tap()
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        BSUITestUtils.pressBackButton(app: app)
    }
    
    /**
     This test verifies that when there is missing info in returning shopper,
     and we press "pay", it passes to the required edit component,
     and not making a transaction.
     Pre-condition: current screen is ExistingCC
     */
    private func checkComponentOpensIfMissingInfo(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        
//        var waitForScreenFunc: ()? = nil
        
        if ((sdkRequest.shopperConfiguration.fullBilling && !shopperWithFullBilling) || (sdkRequest.shopperConfiguration.withEmail && !shopperWithEmail)) {
            existingCcHelper.pressPayButton()
            waitForPaymentScreen()
        }
        
        else if(sdkRequest.shopperConfiguration.withShipping && (!shopperWithShipping && !sdkRequest.shopperConfiguration.fullBilling)){
            existingCcHelper.pressPayButton()
            waitForShippingScreen()
        }
        
    }
    
}
