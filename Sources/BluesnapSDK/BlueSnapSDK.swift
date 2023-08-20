//
//  BlueSnap.swift
//  BlueSnap
//
//

import Foundation
import PassKit

#if canImport(KountWrapper)
  import KountWrapper
#endif

open class BlueSnapSDK: NSObject {

    // MARK: Supported networks for ApplePay
    static let applePaySupportedNetworks: [PKPaymentNetwork] = [
        .amex,
        .discover,
        .masterCard,
        .visa
    ]
    private(set) public static var fraudSessionId: String?
    public static var sdkRequestBase: BSSdkRequestProtocol?

    

    // MARK: SDK functions

    /**
     Initialize BlueSnap SDK - this function must be called before any other function in the SDK
     
     - parameters:
     - bsToken: BlueSnap token, should be fresh and valid
     - generateTokenFunc: callback function for generating a new token
     - initKount: true if you want to initialize the Kount device data collection for fraud (recommended: True)
     - fraudSessionId: a unique ID (up to 32 characters) for the shopper session - optional (if empty, a new one is generated)
     - applePayMerchantIdentifier: optional identifier for ApplePay
     - merchantStoreCurrency: base currency code for currency rate calculations
     - completion: callback; will be called when the init process is done. Only then can you proceed to call other functions in the SDK
     */
    open class func initBluesnap(
    bsToken: BSToken!,
    generateTokenFunc: @escaping (_ completion: @escaping (BSToken?, BSErrors?) -> Void) -> Void,
    initKount: Bool,
    fraudSessionId: String?,
    applePayMerchantIdentifier: String?,
    merchantStoreCurrency: String?,
    completion: @escaping (BSErrors?) -> Void) throws {
        try initBluesnap(bsToken: bsToken, generateTokenFunc: generateTokenFunc, initKount: initKount, fraudSessionId: fraudSessionId, applePayMerchantIdentifier: applePayMerchantIdentifier, merchantStoreCurrency: merchantStoreCurrency, initCardinal: true, completion: completion)
    }
    
    internal class func initBluesnap(
            bsToken: BSToken!,
            generateTokenFunc: @escaping (_ completion: @escaping (BSToken?, BSErrors?) -> Void) -> Void,
            initKount: Bool,
            fraudSessionId: String?,
            applePayMerchantIdentifier: String?,
            merchantStoreCurrency: String?,
            initCardinal: Bool,
            completion: @escaping (BSErrors?) -> Void) throws {

        // verify that initBluesnap() has been called prior to this function
        guard (bsToken != nil) else {
            let msg: String = "Failed to initialize Bluesnap SDK, bsToken is nil"
            NSLog(msg)
            throw BSSdkRequestBaseError.tokenIsNil(msg)
        }
        
        BSApiManager.setBsToken(bsToken: bsToken)
        BSApiManager.setGenerateBsTokenFunc(generateTokenFunc: generateTokenFunc)

        BSApiManager.getSdkData(baseCurrency: merchantStoreCurrency, completion: { sdkData, error in

            if let error = error {
                NSLog("Failed to fetch data for Bluesnap SDK. error: \(error)")
                completion(error)
                return
            }

            if let sdkData = sdkData {
                if initKount {
                    KountInit(kountMid: sdkData.kountMID! as NSNumber, customFraudSessionId: fraudSessionId)
                }
                if let applePayMerchantIdentifier = applePayMerchantIdentifier {
                    BSApplePayConfiguration.setIdentifier(merchantId: applePayMerchantIdentifier)
                }
                
                BSCardinalManager.instance.setCardinalJWT(cardinalToken: sdkData.cardinalToken)
                if (!bsToken.isProduction ) {
                    NSLog("Cadinal token is  \(sdkData.cardinalToken)");
                }
                if (initCardinal){
                    DispatchQueue.main.async {
                        BSCardinalManager.instance.configureCardinal(isProduction: bsToken.isProduction)
                        BSCardinalManager.instance.setupCardinal {completion(nil)}
                    }
                } else {
                    completion(nil)
                }
                
            } else {
                completion(BSErrors.unknown)
            }

        })

    }

    /**
     Set the token used for BS API
     This needs to be called when you generate a new token after a token expired (in your generateTokenFunc
     function, which you pass in initBluesnap call above)
     
     - parameters:
     - bsToken: BlueSnap token, should be fresh and valid
     */
    open class func setBsToken(bsToken: BSToken!) throws {

        guard (bsToken != nil) else {
            let msg: String = "Failed to set BsToken, bsToken is nil"
            NSLog(msg)
            throw BSSdkRequestBaseError.tokenIsNil(msg)
        }
        
        BSApiManager.setBsToken(bsToken: bsToken)
    }

    /**
     Start the BlueSnap checkout flow
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - sdkRequest: initial payment details + flow settings
     
     throws BSSdkRequestBaseError if initBluesnap() hasn't been called
     */
    open class func showCheckoutScreen(
            inNavigationController: UINavigationController!,
            animated: Bool,
            sdkRequest: BSSdkRequest!) throws {

        try showCheckoutScreen(inNavigationController: inNavigationController, animated: animated, sdkRequestBase: sdkRequest)
    }

    /**
     Start the BlueSnap Choose Payment flow for Shopper Configuration

     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - BSSdkRequestShopperRequirements: initial payment details + flow settings
     
     throws BSSdkRequestBaseError if initBluesnap() hasn't been called or if returning shopper is missing
     */
    open class func showChoosePaymentScreen(
            inNavigationController: UINavigationController!,
            animated: Bool,
            sdkRequestShopperRequirements: BSSdkRequestShopperRequirements!) throws {

        try showCheckoutScreen(inNavigationController: inNavigationController, animated: animated, sdkRequestBase: sdkRequestShopperRequirements)
    }

    /**
     Start the BlueSnap Create Payment flow for Shopper Configuration

     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - BSSdkRequest: initial payment details + flow settings
     
     throws BSSdkRequestBaseError if initBluesnap() hasn't been called or if returning shopper is missing
     */
    open class func showCreatePaymentScreen(
            inNavigationController: UINavigationController!,
            animated: Bool,
            sdkRequest: BSSdkRequest!) throws {

        // verify that initBluesnap() has been called prior to this function
        guard (BSApiManager.sdkIsInitialized) else {
            let msg: String = "Failed to activate Bluesnap SDK, initBluesnap has to be called first"
            NSLog(msg)
            throw BSSdkRequestBaseError.sdkNotInitialized(msg)
        }
        
        guard !(BSApiManager.shopper?.vaultedShopperId == nil) else {
            let msg: String = "Failed to activate Shopper Configuration for Bluesnap SDK, Returning Shopper is missing"
            NSLog(msg)
            throw BSSdkRequestBaseError.missingReturningShopper(msg)
        }

        self.sdkRequestBase = sdkRequest
        self.sdkRequestBase?.adjustSdkRequest()

        let createPaymentViewController: BSCreatePaymentViewController = BSCreatePaymentViewController()
        try createPaymentViewController.start(inNavigationController: inNavigationController)
    }

    /**
    Submit data to BLS server under the current token, to be used later for server-to-server actions
    */
    open class func submitTokenizedDetails(tokenizeRequest: BSTokenizeRequest, completion: @escaping ([String: String], BSErrors?) -> Void) {
        BSApiManager.submitTokenizedDetails(tokenizeRequest: tokenizeRequest, completion: completion)
    }

    /**
  Update Shopper to BLS server under the current token
  */
    open class func updateShopper(completion: @escaping (Bool, String?) -> Void) {
        BSApiManager.updateShopper(completion: { (result, error) in
            if let error = error {
                var message: String
                if (error == .tokenNotFound) {
                    message = BSLocalizedStrings.getString(BSLocalizedString.Error_Cc_Submit_Token_not_found)
                } else {
                    NSLog("Unexpected error Updating Shopper to BS")
                    message = BSLocalizedStrings.getString(BSLocalizedString.Error_General_CC_Submit_Error)
                }
                completion(false, message)
            } else {
                completion(true, nil)
            }
        })
    }

//    /**
//     Submit Payment token fields
//     If you do not want to use our check-out page, you can implement your own.
//     You need to generate a token, and then call this function to submit the CC details to BlueSnap instead of returning them to your server (which is less secure) and then passing them to BlueSnap when you create the transaction.
//     - parameters:
//     - ccNumber: Credit card number
//     - expDate: CC expiration date in format MM/YYYY
//     - cvv: CC security code (CVV)
//     - purchaseDetails: optional purchase details to be tokenized as well as the CC details
//     - completion: callback with either result details if OK, or error details if not OK
//     */
//    open class func submitCcDetails(ccNumber: String, expDate: String, cvv: String, purchaseDetails: BSCcSdkResult?, completion : @escaping (BSCreditCard,BSErrors?)->Void) {
//        
//        BSApiManager.submitPurchaseDetails(ccNumber: ccNumber, expDate: expDate, cvv: cvv, last4Digits: nil, cardType: nil, billingDetails: purchaseDetails?.billingDetails, shippingDetails: purchaseDetails?.shippingDetails, fraudSessionId: BlueSnapSDK.fraudSessionId, completion: completion)
//    }

    /**
     Return a list of currencies and their rates from BlueSnap server
     The list is updated when calling initBluesnap
     */
    open class func getCurrencyRates() -> BSCurrencies? {
        return BSApiManager.bsCurrencies
    }

    /**
     Navigate to the currency list, allow changing current selection.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - selectedCurrencyCode: 3 characters of the current language code (uppercase)
     - updateFunc: callback; will be called each time a new value is selected
     - errorFunc: callback; will be called if we fail to get the currencies
     */
    open class func showCurrencyList(
            inNavigationController: UINavigationController!,
            animated: Bool,
            selectedCurrencyCode: String!,
            updateFunc: @escaping (BSCurrency?, BSCurrency?) -> Void,
            errorFunc: @escaping () -> Void) {

        BSViewsManager.showCurrencyList(inNavigationController: inNavigationController, animated: animated, selectedCurrencyCode: selectedCurrencyCode, updateFunc: updateFunc, errorFunc: errorFunc)
    }


    /**
     Fetch the merchant's supported Payment Methods
     - parameters:
     - completion: function to call once the data is fetched; will receive optional list of strings that are the payment methods, and optional error.
    */
    static func getSupportedPaymentMethods(completion: @escaping ([String]?, BSErrors?) -> Void) {

        BSApiManager.getSupportedPaymentMethods(completion: completion)
    }

    /**
    Check if ApplePay is available
    */
    open class func applePaySupported(supportedPaymentMethods: [String]?,
                                      supportedNetworks: [PKPaymentNetwork]) -> (canMakePayments: Bool, canSetupCards: Bool) {

        if #available(iOS 10, *) {

            let isSupportedByBS = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.ApplePay, supportedPaymentMethods: supportedPaymentMethods)
            if isSupportedByBS {
                return (PKPaymentAuthorizationController.canMakePayments(),
                        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks));
            }
        }

        return (canMakePayments: false, canSetupCards: false)
    }
    
    /**
     Return an array of the last four digits of the shopper's existing credit cards
    */
    open class func getCards() -> [BSCreditCard] {
        return BSApiManager.shopper?.existingCreditCards.map({ (item) -> BSCreditCard in
            item.creditCard
        }) ?? []
    }
    
    /**
     Return the shopper's last payment info
    */
    open class func getLastPaymentInfo() -> [String: Any]? {
        BSApiManager.shopper?.lastPaymentInfo
    }
    
    /**
     Provoke 3DS Authentication
     - parameters:
     - currency: shopper's selected currency
     - amount: purchase amount
     - creditCardNumber: shopper's credit card number
     - completion: function to call once the authentication is done; will receive string that is the authentication result, and optional error.
    */
    open class func authenticationWith3DS(currency: String, amount: String, creditCardNumber: String? = nil, _ completion: @escaping (String, BSErrors?) -> Void) {
        
        BSCardinalManager.instance.authWith3DS(currency: currency, amount: amount, creditCardNumber: creditCardNumber, completion)

    }



    // MARK: Utility functions for quick testing


//    /**
//    Objective C helper method for returning sandbox token
//    */
//      open class func createSandboxTestTokenOrNil() -> BSToken? {
//        do {
//            return try BSApiManager.createSandboxBSToken()!
//        } catch let error {
//            NSLog("Error creating token: \(error.localizedDescription)")
//            return nil
//        }
//    }


    // MARK: Private functions

    /**
     Call Kount SDK to initialize device data collection in a background thread
     - parameters:
     - kountMid: if you have your own Kount MID, send it here; otherwise leave empty
     - fraudSessionID: this unique ID per shopper should be sent later to BlueSnap when creating the transaction
     */
    private static func KountInit(kountMid: NSNumber?, customFraudSessionId: String?) {

        if customFraudSessionId != nil {
            BlueSnapSDK.fraudSessionId = customFraudSessionId!
        } else {
            BlueSnapSDK.fraudSessionId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }

        //// Configure the Data Collector
        //KDataCollector.shared().debug = true
        if (kountMid != nil) {
            KDataCollector.shared().merchantID = kountMid!.intValue
        } else {
            KDataCollector.shared().merchantID = 700000
        }
        // Optional Set the location collection configuration
        KDataCollector.shared().locationCollectorConfig = KLocationCollectorConfig.passive

        if BSApiManager.isProductionToken() {
            KDataCollector.shared().environment = KEnvironment.production
        } else {
            KDataCollector.shared().environment = KEnvironment.test
        }
        NSLog("Kount session ID")
        if let fraudSessionId = BlueSnapSDK.fraudSessionId {
            KDataCollector.shared().collect(forSession: fraudSessionId) { (sessionID, success, error) in
                if success {
                    NSLog("Kount collection success")
                } else {
                    NSLog("Kount collection failed")
                }
            }
        }
    }

    private class func showCheckoutScreen(
            inNavigationController: UINavigationController!,
            animated: Bool,
            sdkRequestBase: BSSdkRequestProtocol!) throws {

        // verify that initBluesnap() has been called prior to this function
        guard (BSApiManager.sdkIsInitialized) else {
            let msg: String = "Failed to activate Bluesnap SDK, initBluesnap has to be called first"
            NSLog(msg)
            throw BSSdkRequestBaseError.sdkNotInitialized(msg)
        }
        
        guard !(sdkRequestBase is BSSdkRequestShopperRequirements && BSApiManager.shopper?.vaultedShopperId == nil) else {
            let msg: String = "Failed to activate Shopper Configuration for Bluesnap SDK, Returning Shopper is missing"
            NSLog(msg)
            throw BSSdkRequestBaseError.missingReturningShopper(msg)
        }
        
        // verify that request to activate3DS does not conflict with Dashboard configuration
        guard !(sdkRequestBase.activate3DS && !BSApiManager.threeDSEnabledInDashboard) else {
            let msg: String = "Failed to activate Bluesnap SDK with 3DS since it has been disabled in Dashboard"
            NSLog(msg)
            throw BSSdkRequestBaseError.threeDSDisabledInDashboard(msg)
        }

        self.sdkRequestBase = sdkRequestBase
        self.sdkRequestBase?.adjustSdkRequest()

        DispatchQueue.main.async {
            
            if (BSApiManager.isNewCCOnlyPaymentMethod()){ //only cc is supported
                BSViewsManager.showCCDetailsScreen(existingCcPurchaseDetails: nil, inNavigationController: inNavigationController,
                                               animated: false)
            } else {
            BSViewsManager.showStartScreen(inNavigationController: inNavigationController,
                    animated: animated)
            }
        }
    }

}

public class BSApplePayConfiguration {

    internal static var identifier: String? = nil

    public static func setIdentifier(merchantId: String!) {
        identifier = merchantId;
    }

    public static func getIdentifier() -> String! {
        return identifier
    }

}
