//
//  BluesnapSDKIntegrationTestsHelper.swift
//  BluesnapSDKIntegrationTests
//
//  Created by Sivani on 11/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
@testable import BluesnapSDK

class BluesnapSDKIntegrationTestsHelper {
    
    static func checkRetrieveVaultedShopperResponse(responseBody: Data, shopperInfo: MockShopper) -> BSErrors? {
        var resultError: BSErrors? = nil
        do {
            // Parse the result JSOn object
            if let jsonData = try JSONSerialization.jsonObject(with: responseBody, options: .allowFragments) as? [String: AnyObject] {
                if shopperInfo.shopperCheckoutRequirements.emailRequired {
                    checkApiCallResult(expectedData: ["email": shopperInfo.email!], resultData: jsonData)
                }

                if let paymentSources = jsonData["paymentSources"] as? [String: AnyObject] {
                    if let creditCardInfo = paymentSources["creditCardInfo"] as? [[String: Any]] {
                        for item in creditCardInfo {
                            if let creditCard = item["creditCard"] as? [String: AnyObject], let billingContactInfo = item["billingContactInfo"] as? [String: AnyObject] {
                                let cardLastFourDigits = creditCard["cardLastFourDigits"] as? String
                                checkApiCallResult(expectedData: shopperInfo.creditCardInfo[cardLastFourDigits!]!.billingContactInfo, resultData: billingContactInfo)
                                checkApiCallResult(expectedData: shopperInfo.creditCardInfo[cardLastFourDigits!]!.creditCard, resultData: creditCard)
                            }
                        }
                    }
                }

                if shopperInfo.shopperCheckoutRequirements.shippingRequired {
                    if let shippingContactInfo = jsonData["shippingContactInfo"] as? [String: AnyObject] {
                        checkApiCallResult(expectedData: shopperInfo.shippingContactInfo!, resultData: shippingContactInfo)

                    }
                }

            } else {
                NSLog("Error parsing BS result on Retrieve vaulted shopper")
                resultError = .unknown
            }
        } catch let error as NSError {
            NSLog("Error parsing BS result on Retrieve vaulted shopper: \(error.localizedDescription)")
            resultError = .unknown
        }

        return resultError

    }


    static func checkApiCallResult(expectedData: [String: String], resultData: [String: AnyObject]) {
        for (fieldName, fieldValue) in expectedData {
            let actualValue = resultData[fieldName] as! String
            checkFieldContent(expectedValue: fieldValue, actualValue: actualValue, fieldName: fieldName)
        }
    }

    static func checkFieldContent(expectedValue: String, actualValue: String, fieldName: String) {
        XCTAssertTrue(expectedValue == actualValue, "Field \(fieldName) was not saved correctly in DataBase")
    }

    //------------------------------------------------------
    // MARK: private functions Shopper, Address & CC Creation
    //------------------------------------------------------

    static func initBSToken(tokenStr: String) -> BSToken!{
        var result: BSToken!
        
        do {
            try result = BSToken(tokenStr: tokenStr)
        } catch {
            XCTFail(error.localizedDescription)
            NSLog("Unexpected error: \(error).")
        }

        return result
    }
    
    static func createShopperForUpdate(add2: Bool = false, vaultedShopperId: Int? = nil, chosenPaymentMethodType: String? = nil, creditCard: BSCreditCard? = nil) -> BSShopper {
        let shopper = BSShopper()


        shopper.name = "John Doe" + (add2 ? "2" : "")
        shopper.country = "US"
        shopper.state = "AK"
        shopper.address = "some address" + (add2 ? "2" : "")
        shopper.address2 = "some address2" + (add2 ? "2" : "")
        shopper.city = "some city" + (add2 ? "2" : "")
        shopper.email = "some" + (add2 ? "2@email.com" : "@email.com")
        shopper.zip = "123456" + (add2 ? "2" : "")
        shopper.phone = "0541234567" + (add2 ? "2" : "")

        if let vaultedShopperId = vaultedShopperId {
            shopper.vaultedShopperId = vaultedShopperId
        }

        if let chosenPaymentMethodType = chosenPaymentMethodType {
            shopper.chosenPaymentMethod = BSChosenPaymentMethod(chosenPaymentMethodType: chosenPaymentMethodType, creditCard: creditCard)
        }

        return shopper
    }

    static func getShippingDetails(add2: Bool = false) -> BSShippingAddressDetails {
        let shippingDetails = BSShippingAddressDetails()
        shippingDetails.name = "Shipping John" + (add2 ? "2" : "")
        shippingDetails.country = "BR"
        shippingDetails.state = "AC"
        shippingDetails.address = "shipping address" + (add2 ? "2" : "")
        shippingDetails.city = "shipping city" + (add2 ? "2" : "")
        shippingDetails.zip = "123456" + (add2 ? "2" : "")
        return shippingDetails
    }

    static func getBillingDetails(add2: Bool = false) -> BSBillingAddressDetails {
        let billingDetails = BSBillingAddressDetails()
        billingDetails.name = "Billing John" + (add2 ? "2" : "")
        billingDetails.country = "CA"
        billingDetails.state = "ON"
        billingDetails.address = "billing address" + (add2 ? "2" : "")
        billingDetails.city = "billing city" + (add2 ? "2" : "")
        billingDetails.zip = "123456" + (add2 ? "2" : "")
        billingDetails.email = "billing" + (add2 ? "2@email.com" : "@email.com")
        return billingDetails
    }

    static func getVisa() -> [String: String] {
        return ["ccn": "4111111111111111", "exp": "10/2025", "cvv": "111", "ccType": "VISA", "last4Digits": "1111", "issuingCountry": "US"]
    }

    static func getMasterCard() -> [String: String] {
        return ["ccn": "5555555555555557", "exp": "11/2025", "cvv": "123", "ccType": "MASTERCARD", "last4Digits": "5557", "issuingCountry": "BR"]
    }

    static func getBSCreditCardVisa() -> BSCreditCard {
        return getBSCreditCard(cc: getVisa())
    }

    static func getBSCreditCardMasterCard() -> BSCreditCard {
        return getBSCreditCard(cc: getMasterCard())
    }

    static func getBSCreditCard(cc: [String: String]) -> BSCreditCard {
        let creditCard: BSCreditCard = BSCreditCard()
        creditCard.ccType = cc["ccType"]
        creditCard.last4Digits = cc["last4Digits"]
        let expArr = cc["exp"]?.components(separatedBy: "/")
        creditCard.expirationMonth = expArr![0]
        creditCard.expirationYear = expArr![1]
        return creditCard
    }

}
