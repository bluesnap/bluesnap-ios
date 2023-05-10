//
//  BSApiManager.swift
//  BluesnapSDK
//
// Contains methods that access BlueSnap API
//
//  Created by Shevie Chen on 06/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

  class BSApiManager: NSObject {

    // MARK: Constants
    internal static let BS_PRODUCTION_DOMAIN_PART1 = "https://ws"
    internal static let BS_PRODUCTION_DOMAIN_PART2 = ".bluesnap.com/"
    internal static let BS_SANDBOX_DOMAIN = "https://sandbox.bluesnap.com/"

    internal static let TIME_DIFF_TO_RELOAD: Double = -60 * 60
    // every hour (interval should be negative, and in seconds)
 
    // MARK: private properties
    internal static var bsCurrencies: BSCurrencies?
    internal static var merchantName: String?
    internal static var supportedPaymentMethods: [String]?
    internal static var lastSupportedPaymentMethodsFetchDate: Date?
    internal static var shopper: BSShopper?
    internal static var threeDSEnabledInDashboard: Bool!
    internal static var apiToken: BSToken?
    internal static var payPalToken : String?
    internal static var apiGenerateTokenFunc: (_ completion: @escaping (BSToken?, BSErrors?) -> Void) -> Void = { completion in
        NSLog("no token regeneration method was supplied")
        completion(nil, BSErrors.invalidInput)
    }
    internal static var sdkIsInitialized: Bool = false

    // MARK: bsToken functions

    /**
    Set the bsToken used in all API calls
    */
    static func setBsToken(bsToken: BSToken!) {
        apiToken = bsToken
        payPalToken = nil
    }

    /**
     Set the token re-generation method to be used for BS API when token expires
     - parameters:
     - completion: function to be called after token is generated; will receive optional token and optional error
     */
    open class func setGenerateBsTokenFunc(generateTokenFunc: @escaping (_ completion: @escaping (BSToken?, BSErrors?) -> Void) -> Void) {
        
        apiGenerateTokenFunc = generateTokenFunc
    }

    /**
     Get the bsToken used in all API calls - if empty, throw fatal error
     */
    static func getBsToken() -> BSToken! {

        return apiToken
    }
    
    // TODO: use token.isProduction instead
    static func isProductionToken() -> Bool {
        
        let bsToken = getBsToken()
        return bsToken?.serverUrl != BS_SANDBOX_DOMAIN
    }
    
    // MARK: Main functions
    
    /**
     Return a list of currencies and their rates from BlueSnap server
     - parameters:
     - baseCurrency: optional base currency for currency rates; default = USD
     - completion: function to be called after data is received; will receive optional currency data and optional error
     */
    static func getSdkData(baseCurrency: String?, completion: @escaping (BSSdkConfiguration?, BSErrors?) -> Void) {
        
        let bsToken = getBsToken()
        
        NSLog("BlueSnap; getSdkData")
        BSApiCaller.getSdkData(bsToken: bsToken, baseCurrency: baseCurrency, completion: {
            sdkData, resultError in
            
            NSLog("BlueSnap; getSdkData completion")
            if resultError == .unAuthorised {
                
                // regenerate Token and try again
                regenerateToken(executeAfter: {
                    BSApiCaller.getSdkData(bsToken: getBsToken(), baseCurrency: baseCurrency, completion: { sdkData2, resultError2 in
                        
                        if resultError2 == nil {
                            self.lastSupportedPaymentMethodsFetchDate = Date()
                        }
                        if let sdkData = sdkData2 {
                            initSdkDataProperties(sdkData: sdkData)
                        }
                        completion(sdkData2, resultError2)
                    })
                })
            } else {
                if resultError == nil {
                    self.lastSupportedPaymentMethodsFetchDate = Date()
                }
                if let sdkData = sdkData {
                    initSdkDataProperties(sdkData: sdkData)
                }
                completion(sdkData, resultError)
            }
        })
    }
    
    static private func initSdkDataProperties(sdkData: BSSdkConfiguration){
        supportedPaymentMethods = sdkData.supportedPaymentMethods
        bsCurrencies = sdkData.currencies
        merchantName = sdkData.merchantName
        shopper = sdkData.shopper
        sdkIsInitialized = true
        threeDSEnabledInDashboard = sdkData.cardinalToken != nil
    }

    /**
     Submit Existing CC request to BlueSnap server
     - parameters:
     - purchaseDetails: BSExistingCcSdkResult
     - completion: callback with either result details if OK, or error details if not OK
     */
    static func submitPurchaseDetails(purchaseDetails: BSExistingCcSdkResult, completion: @escaping (BSCreditCard, BSErrors?) -> Void) {
        
        let cc = purchaseDetails.creditCard
        BSApiManager.submitPurchaseDetails(ccNumber: nil, expDate: cc.getExpirationForSubmit(), cvv: nil, last4Digits: cc.last4Digits, cardType: cc.ccType, billingDetails: purchaseDetails.billingDetails, shippingDetails: purchaseDetails.shippingDetails, storeCard: true, fraudSessionId: BlueSnapSDK.fraudSessionId, completion: completion)
    }
    
    /**
     Submit CC details to BlueSnap server
     - parameters:
     - ccNumber: Credit card number (in case of new CC)
     - expDate: CC expiration date in format MM/YYYY  (in case of new/existing CC)
     - cvv: CC security code (CVV)  (in case of new CC)
     - last4Digits: Credit card last 4 digits (in case of existing CC)
     - cardType: Credit card type (in case of existing CC)
     - completion: callback with either result details if OK, or error details if not OK
     */
    static func submitPurchaseDetails(ccNumber: String?, expDate: String?, cvv: String?, last4Digits: String?, cardType: String?, billingDetails: BSBillingAddressDetails?, shippingDetails: BSShippingAddressDetails?, storeCard: Bool?, fraudSessionId: String?, completion: @escaping (BSCreditCard, BSErrors?) -> Void) {
        
        let tokenizeRequest = BSTokenizeRequest()
        if let ccNumber = ccNumber {
            tokenizeRequest.paymentDetails = BSTokenizeNewCCDetails(ccNumber: ccNumber, cvv: cvv, ccType: cardType, expDate: expDate)
        } else {
            tokenizeRequest.paymentDetails = BSTokenizeExistingCCDetails(lastFourDigits: last4Digits, ccType: cardType, expDate: expDate)
        }
        tokenizeRequest.billingDetails = billingDetails
        tokenizeRequest.shippingDetails = shippingDetails
        tokenizeRequest.storeCard = storeCard
        submitCcDetails(tokenizeRequest: tokenizeRequest, completion: completion)
    }

    
    /**
     Submit CCN only to BlueSnap server
     - parameters:
     - ccNumber: Credit card number
     - completion: callback with either result details if OK, or error details if not OK
     */
    static func submitCcn(ccNumber: String, completion: @escaping (BSCreditCard, BSErrors?) -> Void) {
        
        submitPurchaseDetails(ccNumber: ccNumber, expDate: nil, cvv: nil, last4Digits: nil, cardType: nil, billingDetails: nil, shippingDetails: nil, storeCard: nil, fraudSessionId: nil, completion: completion)
    }
    

    /**
     Fetch a list of merchant-supported payment methods from BlueSnap server
     - parameters:
     - completion: function to be called after data is fetched; will receive optional string list and optional error
     */
    static func getSupportedPaymentMethods(completion: @escaping ([String]?, BSErrors?) -> Void) {
        
        let bsToken = getBsToken()
        
        if let lastSupportedPaymentMethodsFetchDate = lastSupportedPaymentMethodsFetchDate, let supportedPaymentMethods = supportedPaymentMethods {
            let diff = lastSupportedPaymentMethodsFetchDate.timeIntervalSinceNow as Double // interval in seconds
            if (diff > TIME_DIFF_TO_RELOAD) {
                completion(supportedPaymentMethods, nil)
                return
            }
        }
        
        NSLog("BlueSnap; getSupportedPaymentMethods")
        BSApiCaller.getSupportedPaymentMethods(bsToken: bsToken, completion: {
            resultSupportedPaymentMethods, resultError in
            
            NSLog("BlueSnap; getSupportedPaymentMethods completion")
            if resultError == .unAuthorised {
                BSApiCaller.isTokenExpired(bsToken: bsToken, completion: { isExpired in
                    if isExpired {
                        // regenerate Token and try again
                        regenerateToken(executeAfter: {
                            NSLog("BlueSnap; getSupportedPaymentMethods retry")
                            BSApiCaller.getSupportedPaymentMethods(bsToken: getBsToken(), completion: { resultSupportedPaymentMethods2, resultError2 in
                                
                                NSLog("BlueSnap; getSupportedPaymentMethods retry completion")
                                if resultError2 == nil {
                                    supportedPaymentMethods = resultSupportedPaymentMethods2
                                    self.lastSupportedPaymentMethodsFetchDate = Date()
                                }
                                completion(supportedPaymentMethods, resultError2)
                            })
                        })
                    } else {
                        completion(supportedPaymentMethods, resultError)
                    }
                })
                
            } else {
                if resultError == nil {
                    supportedPaymentMethods = resultSupportedPaymentMethods
                    self.lastSupportedPaymentMethodsFetchDate = Date()
                }
                completion(supportedPaymentMethods, resultError)
            }
        })
    }
    
    /**
     Return a list of merchant-supported payment methods from BlueSnap server
     */
    static func isSupportedPaymentMethod(paymentType: BSPaymentType, supportedPaymentMethods: [String]?) -> Bool {
        
        if let supportedPaymentMethods = supportedPaymentMethods {
            let exists = supportedPaymentMethods.firstIndex(of: paymentType.rawValue)
            return exists != nil
        } else {
            return false
        }
    }
        
    /**
     Return true if the only payment method supported is new CC
     */
    static func isNewCCOnlyPaymentMethod() -> Bool {
        
        let isPayPalSupported = isSupportedPaymentMethod(paymentType: BSPaymentType.PayPal, supportedPaymentMethods: BSApiManager.supportedPaymentMethods)
        let isApplePaySupported = BlueSnapSDK.applePaySupported(supportedPaymentMethods: BSApiManager.supportedPaymentMethods, supportedNetworks: BlueSnapSDK.applePaySupportedNetworks).canMakePayments
        
        let existingCreditCards = shopper == nil ? false : (shopper?.existingCreditCards.count == 0 ? false : true)
        
        return !isPayPalSupported && !isApplePaySupported && !existingCreditCards
        
    }
    
    /**
     Create PayPal token on BlueSnap server and get back the URL for redirect
     - parameters:
     - bsToken: a token for BlueSnap tokenized services
     - purchaseDetails: details of the purchase: specifically amount and currency are used
     - withShipping: setting for the PayPal flow - do we want to request shipping details from the shopper
     - completion: a callback function to be called once the PayPal token is fetched; receives optional PayPal Token string data and optional error
     */
    static func createPayPalToken(purchaseDetails: BSPayPalSdkResult, withShipping: Bool, completion: @escaping (String?, BSErrors?) -> Void) {
        
        if (payPalToken != nil) {
            completion(payPalToken, nil)
            return
        }
        
        DispatchQueue.global().async {
            let bsToken = getBsToken()
            
            NSLog("BlueSnap; createPayPalToken")
            BSApiCaller.createPayPalToken(bsToken: bsToken, purchaseDetails: purchaseDetails, withShipping: withShipping, completion: {
                resultToken, resultError in
                NSLog("BlueSnap; createPayPalToken completion")
                // todo: ask if error is PAYPAL_TOKEN_ALREADY_USED, if so - call merchant to regenerate token and try again
                if resultError == .paypalUTokenAlreadyUsed {
                    NSLog("BlueSnap; paypalUTokenAlreadyUsed; createPayPalToken retry")
                    // regenerate Token and try again
                    regenerateToken(executeAfter: {
                        BSApiCaller.createPayPalToken(bsToken: getBsToken(), purchaseDetails: purchaseDetails, withShipping: withShipping, completion: { resultToken2, resultError2 in
                            
                            payPalToken = resultToken2
                            completion(resultToken2, resultError2)
                        })
                    })
                }
                else if resultError == .unAuthorised {
                    NSLog("BlueSnap; createPayPalToken retry")
                    BSApiCaller.isTokenExpired(bsToken: bsToken, completion: { isExpired in
                        NSLog("BlueSnap; createPayPalToken retry completion")
                        if isExpired {
                            // regenerate Token and try again
                            regenerateToken(executeAfter: {
                                BSApiCaller.createPayPalToken(bsToken: getBsToken(), purchaseDetails: purchaseDetails, withShipping: withShipping, completion: { resultToken2, resultError2 in
                                    
                                    payPalToken = resultToken2
                                    completion(resultToken2, resultError2)
                                })
                            })
                        } else {
                            completion(resultToken, resultError)
                        }
                    })
                    
                } else {
                    payPalToken = resultToken
                    completion(resultToken, resultError)
                }
            })
        }
    }


    // MARK: Private/internal functions

    /**
     Submit data to be submitted to BLS server under the current token, to be used later for server-to-server actions
     */
    open class func submitTokenizedDetails(tokenizeRequest: BSTokenizeRequest, completion: @escaping ([String:String], BSErrors?) -> Void) {
        
        var requestBody : [String:String] = [:]
        var parseFunction: (Int, Data?) -> ([String:String],BSErrors?) = BSApiCaller.parseGenericResponse
        
        if let applePayDetails = tokenizeRequest.paymentDetails as? BSTokenizeApplePayDetails {
            requestBody["applePayToken"] = applePayDetails.applePayToken
            parseFunction = BSApiCaller.parseApplePayResponse
            
        } else if let ccDetails = tokenizeRequest.paymentDetails as? BSTokenizeBaseCCDetails {
            parseFunction = BSApiCaller.parseCCResponse
            if var cardType = ccDetails.ccType {
                cardType = cardType.uppercased()
                requestBody[BSTokenizeBaseCCDetails.CARD_TYPE_KEY] = cardType
            }
            if let expDate = ccDetails.expDate {
                requestBody["expDate"] = expDate
            }
            if let newCcDetails = ccDetails as? BSTokenizeNewCCDetails {
                if let ccNumber = newCcDetails.ccNumber {
                    requestBody["ccNumber"] = BSStringUtils.removeWhitespaces(ccNumber)
                }
                if let cvv = newCcDetails.cvv {
                    requestBody["cvv"] = cvv
                }
            } else if let exitingCcDetails = ccDetails as? BSTokenizeExistingCCDetails {
                if let last4Digits = exitingCcDetails.lastFourDigits {
                    requestBody["lastFourDigits"] = last4Digits
                }
            }
            if let storeCard = tokenizeRequest.storeCard {
                requestBody["storeCard"] = String(storeCard)
            }
        }
        if let fraudSessionId = BlueSnapSDK.fraudSessionId {
            requestBody["fraudSessionId"] = fraudSessionId
        }
        
        if let billingDetails = tokenizeRequest.billingDetails {
            if let splitName = billingDetails.getSplitName() {
                requestBody["billingFirstName"] = splitName.firstName
                requestBody["billingLastName"] = splitName.lastName
            }
            if let country = billingDetails.country {
                requestBody["billingCountry"] = country
            }
            if let state = billingDetails.state {
                requestBody["billingState"] = state
            }
            if let city = billingDetails.city {
                requestBody["billingCity"] = city
            }
            if let address = billingDetails.address {
                requestBody["billingAddress"] = address
            }
            if let zip = billingDetails.zip {
                requestBody["billingZip"] = zip
            }
            if let email = billingDetails.email {
                requestBody["email"] = email
            }
        }
        
        if let shippingDetails = tokenizeRequest.shippingDetails {
            if let splitName = shippingDetails.getSplitName() {
                requestBody["shippingFirstName"] = splitName.firstName
                requestBody["shippingLastName"] = splitName.lastName
            }
            if let country = shippingDetails.country {
                requestBody["shippingCountry"] = country
            }
            if let state = shippingDetails.state {
                requestBody["shippingState"] = state
            }
            if let city = shippingDetails.city {
                requestBody["shippingCity"] = city
            }
            if let address = shippingDetails.address {
                requestBody["shippingAddress"] = address
            }
            if let zip = shippingDetails.zip {
                requestBody["shippingZip"] = zip
            }
//            if let phone = shippingDetails.phone {
//                requestBody["phone"] = phone
//            }
        }
        
        let checkErrorAndComplete : ([String:String], BSErrors?) -> Void = { resultData, error in
            if let error = error {
                completion(resultData, error)
                return
            }
            completion(resultData, nil)
        }
        
        BSApiCaller.submitPaymentDetails(bsToken: getBsToken(), requestBody: requestBody, parseFunction: parseFunction, completion: { resultData, error in
            NSLog("BlueSnap; submitCcDetails completion")
            if error == BSErrors.expiredToken || error == BSErrors.tokenNotFound || error == BSErrors.tokenAlreadyUsed {
                // regenerate Token and try again
                NSLog("BlueSnap; submitCcDetails retry")
                regenerateToken(executeAfter: {
                    BSApiCaller.submitPaymentDetails(bsToken: getBsToken(), requestBody: requestBody, parseFunction: BSApiCaller.parseCCResponse, completion: checkErrorAndComplete)
                })
            } else {
                checkErrorAndComplete(resultData, error)
            }
        })
    }
    
    /**
     Submit data to be submitted to BLS server under the current token, to be used later for server-to-server actions
     */
    open class func requestAuthWith3ds(currency: String, amount: String, cardinalToken: String, completion: @escaping (BS3DSAuthResponse?, BSErrors?) -> Void) {
        
        let authRequest = BS3DSAuthRequest(currencyCode: currency, amount: amount, jwt: cardinalToken)
        
        BSApiCaller.requestAuthWith3ds(bsToken: getBsToken(), authRequest: authRequest, completion: completion)
    }
    
    /**
     Process 3DS result to BLS server under the current token
     */
    open class func processCardinalResult(cardinalToken: String, resultJwt: String, completion: @escaping (BS3DSProcessResultResponse?, BSErrors?) -> Void) {
        
        let processResultRequest = BS3DSProcessResultRequest(jwt: cardinalToken, resultJwt: resultJwt)
        
        BSApiCaller.processCardinalResult(bsToken: getBsToken(), processResultRequest: processResultRequest, completion: completion)
    }

    /**
     update Shopper to BLS server under the current token, to be used later for server-to-server actions
     */
    open class func updateShopper(completion: @escaping ([String: String], BSErrors?) -> Void) {
        let shopper: BSShopper = self.shopper!
        var requestBody: [String: Any] = shopper.toJson()
        if shopper.chosenPaymentMethod?.chosenPaymentMethodType == BSPaymentType.CreditCard.rawValue {
            requestBody["paymentSources"] = ["creditCardInfo": [["pfToken": getBsToken()!.tokenStr]]]
        }

        let checkErrorAndComplete: ([String: String], BSErrors?) -> Void = { resultData, error in
            if let error = error {
                completion(resultData, error)
                debugPrint(error.description())
                return
            }
            completion(resultData, nil)
        }

        let parseFunction: (Int, Data?) -> ([String: String], BSErrors?) = BSApiCaller.parseGenericResponse

        BSApiCaller.updateShopper(bsToken: getBsToken(), requestBody: requestBody, parseFunction: parseFunction, completion: { resultData, error in
            NSLog("BlueSnap; updateShopper completion")
            if error == BSErrors.expiredToken || error == BSErrors.tokenNotFound {
                // regenerate Token and try again
                NSLog("BlueSnap; updateShopper retry")
                regenerateToken(executeAfter: {
                    BSApiCaller.updateShopper(bsToken: getBsToken(), requestBody: requestBody, parseFunction: parseFunction, completion: checkErrorAndComplete)
                })
            } else {
                checkErrorAndComplete(resultData, error)
            }
        })
    }

    static internal func regenerateToken(executeAfter: @escaping () -> Void) {
        
        NSLog("Regenerating new token")
        apiGenerateTokenFunc({newToken, error in
            if let newToken = newToken {
                setBsToken(bsToken: newToken)
            }
            executeAfter()
        })
    }

    
    private static func submitCcDetails(tokenizeRequest: BSTokenizeRequest, completion: @escaping (BSCreditCard, BSErrors?) -> Void) {
        
        NSLog("BlueSnap; submitCcDetails")
        submitTokenizedDetails(tokenizeRequest: tokenizeRequest, completion: { resultData, error in
            NSLog("BlueSnap; submitCcDetails completion")
            fillCcDetailsAndComplete(tokenizeRequest: tokenizeRequest, resultData: resultData, error: error, completion: completion)
        })
     }
    
    
    internal static func fillCcDetailsAndComplete(tokenizeRequest: BSTokenizeRequest, resultData: [String:String], error: BSErrors?, completion: @escaping (BSCreditCard, BSErrors?) -> Void) {
        
        let cc = BSCreditCard()
        if let error = error {
            completion(cc, error)
            debugPrint(error.description())
            return
        }
        cc.ccIssuingCountry = resultData[BSTokenizeBaseCCDetails.ISSUING_COUNTRY_KEY]
        cc.ccType = resultData[BSTokenizeBaseCCDetails.CARD_TYPE_KEY]
        cc.last4Digits = resultData[BSTokenizeBaseCCDetails.LAST_4_DIGITS_KEY]
        if let ccDetails = tokenizeRequest.paymentDetails as? BSTokenizeBaseCCDetails {
            if let expDate = ccDetails.expDate {
                if let p = expDate.firstIndex(of: "/") {
                    cc.expirationMonth = String(expDate[..<p])
                    let p = expDate.index(after: p)
                    cc.expirationYear = String(expDate[p..<expDate.endIndex])
                }
            }
        }
        completion(cc, nil)
    }

}
