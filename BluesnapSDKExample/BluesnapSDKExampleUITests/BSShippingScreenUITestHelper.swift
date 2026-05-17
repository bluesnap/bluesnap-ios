//
//  BSShippingScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 12/09/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK

class BSShippingScreenUITestHelper: BSCreditCardScreenUITestHelperBase {
    
    override init(app: XCUIApplication!) {
        super.init(app: app)
        
        let elementsQuery = app.scrollViews.otherElements
        nameInput = elementsQuery.element(matching: .any, identifier: "ShippingName")
        zipInput = elementsQuery.element(matching: .any, identifier: "ShippingZip")
        cityInput = elementsQuery.element(matching: .any, identifier: "ShippingCity")
        addressInput = elementsQuery.element(matching: .any, identifier: "ShippingAddress")
        stateInput = elementsQuery.element(matching: .any, identifier: "ShippingState")
    }
    

    // check visibility of inputs - make sure fields are shown according to configuration
    override func checkInputsVisibility(sdkRequest: BSSdkRequest, shopperDetails: BSBaseAddressDetails? = nil, zipLabel: String = "Shipping Zip") {
        super.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: zipLabel)
        let shippingDetails = sdkRequest.shopperConfiguration.shippingDetails
        checkInput(input: cityInput, expectedExists: true, expectedValue: shippingDetails?.city ?? "City")
        checkInput(input: addressInput, expectedExists: true, expectedValue: shippingDetails?.address ?? "Address")
        
        if let countryCode = shippingDetails?.country {
            // check country image - this does not work, don't know how to access the image
            
            // state should be visible for US/Canada/Brazil
            let stateIsVisible = BSCountryManager.getInstance().countryHasStates(countryCode: countryCode)
            var expectedStateValue = "State"
            if let stateName = bsCountryManager.getStateName(countryCode : countryCode, stateCode: shippingDetails?.state ?? "") {
                expectedStateValue = stateName
            }
            checkInput(input: stateInput, expectedExists: stateIsVisible, expectedValue: expectedStateValue)
        }
        
    }
    
    override func checkPayWithEmptyInputs(sdkRequest: BSSdkRequest, shopperDetails: BSBaseAddressDetails?, payButtonId: String, zipPlaceholder: String) {
        super.checkPayWithEmptyInputs(sdkRequest: sdkRequest, shopperDetails: shopperDetails, payButtonId: payButtonId, zipPlaceholder: zipPlaceholder)
        checkInput(input: addressInput, expectedValue: "Address", expectedValid: false)
        checkInput(input: cityInput, expectedValue: "City", expectedValid: false)
        checkInput(input: stateInput, expectedValue: "State", expectedValid: false)
    }
    
    /**
     This test verifies the invalid error messages appearance for the shipping details
     in shipping screen
     Pre-condition: country is USA (for zip existence)
     */
    override func checkInvalidInfoInputs(payButtonId: String) {
        super.checkInvalidInfoInputs(payButtonId: payButtonId)
        checkInvalidFieldInputs(input: zipInput, invalidValuesToCheck: ["12"], validValue: "12345 abcde", inputToTap: addressInput)
    }

    func setFieldValues(shippingDetails: BSShippingAddressDetails, sdkRequest: BSSdkRequest) {
        
        setInputValue(input: nameInput, value: shippingDetails.name ?? "")
        setInputValue(input: zipInput, value: shippingDetails.zip ?? "")
        setInputValue(input: cityInput, value: shippingDetails.city ?? "")
        setInputValue(input: addressInput, value: shippingDetails.address ?? "")
        if let countryCode = shippingDetails.country {
            setCountry(countryCode: countryCode)
            if let stateCode = shippingDetails.state {
                setState(countryCode: countryCode, stateCode: stateCode)
            }
        }
    }
    
    override func checkPayButton(sdkRequest: BSSdkRequest, shippingSameAsBilling: Bool=false, subscriptionHasPriceDetails: Bool? = nil) {

        let country = sdkRequest.shopperConfiguration.shippingDetails?.country
        let state = sdkRequest.shopperConfiguration.shippingDetails?.state
        
        let expectedPayText = BSUITestUtils.getPayButtonText(sdkRequest: sdkRequest, country: country ?? "", state: state ?? "", subscriptionHasPriceDetails: subscriptionHasPriceDetails)

        BSUITestUtils.checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: expectedPayText)
    }
    
    override func checkDoneButton() {
        BSUITestUtils.checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Done")
    }
    
    override func pressPayButton() {
        closeKeyboard()
        app.buttons["ShippingPayButton"].tap()
    }

}
