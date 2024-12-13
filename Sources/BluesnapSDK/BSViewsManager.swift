//
//  BSViewsManager.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 23/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import UIKit

class BSViewsManager {
    
    // MARK: - Constants
    
    static let bundleIdentifier = "com.bluesnap.BluesnapSDK"
    static let storyboardName = "BlueSnap"
    static let currencyScreenStoryboardId = "BSCurrenciesStoryboardId"
    static let startScreenStoryboardId = "BSStartScreenStoryboardId"
    static let purchaseScreenStoryboardId = "BSPaymentScreenStoryboardId"
    static let existingCcScreenStoryboardId = "BSExistingCcScreenStoryboardId"
    static let countryScreenStoryboardId = "BSCountriesStoryboardId"
    static let stateScreenStoryboardId = "BSStatesStoryboardId"
    static let webScreenStoryboardId = "BSWebViewController"

    fileprivate static var currencyScreen: BSCurrenciesViewController!
    fileprivate static var bsBundle: Bundle = createBundle()

    /**
     Create the bundle containing BlueSnap assets
     */
    private static func createBundle() -> Bundle {

        let bundleforURL = Bundle(for: BSViewsManager.self)
        if let bundleurl = bundleforURL.url(forResource: "BluesnapUI", withExtension: "bundle") {
            return Bundle(url: bundleurl)!
        } else {
            //return Bundle(identifier: BSViewsManager.bundleIdentifier)!;
            //return Bundle(for: self)
            #if canImport(KountWrapper)
            return Bundle.module
            #else
            return Bundle(identifier: BSViewsManager.bundleIdentifier)!;
            #endif
        }
    }

    /**
     Get the bundle containing BlueSnap assets
     */
    public static func getBundle() -> Bundle {

        return bsBundle
    }

    /**
     Open the check-out start screen, where the shopper chooses CC/ApplePay.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     */
    public static func showStartScreen(
        inNavigationController: UINavigationController!,
        animated: Bool) {
        
        let bundle = BSViewsManager.getBundle()
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
        let startScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.startScreenStoryboardId) as! BSStartViewController

        startScreen.initScreen()

        inNavigationController.pushViewController(startScreen, animated: animated)
    }
    
    /**
     Open the check-out screen, where the shopper payment details are entered.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     */
    open class func showCCDetailsScreen(
        existingCcPurchaseDetails: BSExistingCcSdkResult?,
        inNavigationController: UINavigationController!,
        animated: Bool) {
        
        if let sdkRequestBase = BlueSnapSDK.sdkRequestBase {
            let bundle = BSViewsManager.getBundle()
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle);
            let purchaseScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.purchaseScreenStoryboardId) as! BSPaymentViewController
            
            let purchaseDetails = existingCcPurchaseDetails ?? BSCcSdkResult(sdkRequestBase: sdkRequestBase)
            purchaseScreen.initScreen(purchaseDetails: purchaseDetails)

            inNavigationController.pushViewController(purchaseScreen, animated: animated)
        }
    }
    
    /**
     Open the check-out screen for an existing CC, For returning shopper.
     
     - parameters:
     - purchaseDetails: returning shopper details in the payment request
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     */
    open class func showExistingCCDetailsScreen(
        purchaseDetails: BSExistingCcSdkResult!,
        inNavigationController: UINavigationController!,
        animated: Bool) {
        
        let bundle = BSViewsManager.getBundle()
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle);
        let existingCcScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.existingCcScreenStoryboardId) as! BSExistingCCViewController
        
        existingCcScreen.initScreen(purchaseDetails: purchaseDetails)
        
        inNavigationController.pushViewController(existingCcScreen, animated: animated)
    }
    
    /**
    Open the shipping screen
     - parameters:
     - purchaseDetails: payment request (new or existing)
     - submitPaymentFields: function to be called when clicking "Pay"
     - validateOnEntry: true if you want to run validation
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
    */
    open class func showShippingScreen(
        purchaseDetails: BSCcSdkResult!,
        submitPaymentFields: @escaping () -> Void,
        validateOnEntry: Bool,
        inNavigationController: UINavigationController!,
        animated: Bool) {
        
        let bundle = BSViewsManager.getBundle()
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle);
        let shippingScreen = storyboard.instantiateViewController(withIdentifier: "BSShippingDetailsScreen") as! BSShippingViewController

        shippingScreen.initScreen(purchaseDetails: purchaseDetails, submitPaymentFields: submitPaymentFields, validateOnEntry: validateOnEntry)
        inNavigationController.pushViewController(shippingScreen, animated: true)
    }

    /**
     Navigate to the country list, allow changing current selection.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - selectedCountryCode: ISO country code
     - updateFunc: callback; will be called each time a new value is selected
     */
    open class func showCountryList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        selectedCountryCode : String!,
        updateFunc: @escaping (String, String)->Void) {

        let bundle = BSViewsManager.getBundle()
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
        let screen : BSCountryViewController! = storyboard.instantiateViewController(withIdentifier: BSViewsManager.countryScreenStoryboardId) as? BluesnapSDK.BSCountryViewController

        screen.initCountries(selectedCode: selectedCountryCode, updateFunc: updateFunc)
        
        inNavigationController.pushViewController(screen, animated: animated)
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
        selectedCurrencyCode : String!,
        updateFunc: @escaping (BSCurrency?, BSCurrency)->Void,
        errorFunc: @escaping ()->Void) {
        
        if currencyScreen == nil {
            let bundle = BSViewsManager.getBundle()
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
            currencyScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.currencyScreenStoryboardId) as? BSCurrenciesViewController
        }
        currencyScreen.initCurrencies(
            currencyCode: selectedCurrencyCode,
            currencies: BSApiManager.bsCurrencies!,
            updateFunc: updateFunc)
        DispatchQueue.main.async {
            inNavigationController.pushViewController(currencyScreen, animated: animated)
        }
    }

    
    /**
     Navigate to the state list, allow changing current selection.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - selectedCountryCode: ISO country code
     - selectedStateCode: state code
     - updateFunc: callback; will be called each time a new value is selected
     */
    open class func showStateList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        addressDetails: BSBaseAddressDetails,
        updateFunc: @escaping (String, String)->Void) {
        
        let selectedCountryCode = addressDetails.country ?? ""
        let selectedStateCode = addressDetails.state ?? ""

        let countryManager = BSCountryManager.getInstance()
        if let states = countryManager.getCountryStates(countryCode: selectedCountryCode) {
            
            let bundle = BSViewsManager.getBundle()
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
            let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.stateScreenStoryboardId) as! BSStatesViewController
            
            screen.initStates(selectedCode: selectedStateCode, allStates: states, updateFunc: updateFunc)
            
            inNavigationController.pushViewController(screen, animated: animated)
        } else {
            NSLog("No state data available for \(selectedCountryCode)")
        }
    }
    
    open class func getImage(imageName: String!) -> UIImage? {
        
        var result : UIImage?
        let myBundle = BSViewsManager.getBundle()
        if let image = UIImage(named: imageName, in: myBundle, compatibleWith: nil) {
            result = image
        }
        return result
    }
    
    open class func createErrorAlert(title: BSLocalizedString, message: BSLocalizedString) -> UIAlertController {
        let messageText = BSLocalizedStrings.getString(message)
        return createErrorAlert(title: title, message: messageText)
    }

    open class func createErrorAlert(title: BSLocalizedString, message: String) -> UIAlertController {
        let titleText = BSLocalizedStrings.getString(title)
        let okButtonText = BSLocalizedStrings.getString(BSLocalizedString.Alert_OK_Button_Text)
        let alert = UIAlertController(title: titleText, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: okButtonText, style: .default, handler: { (action) -> Void in })
        alert.addAction(cancel)
        return alert
        //After you create alert, you show it like this: present(alert, animated: true, completion: nil)
    }
    
    open class func createActivityIndicator(view: UIView!) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        view.addSubview(indicator)
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.style = .gray
        return indicator
    }
    
    open class func startActivityIndicator(activityIndicator: UIActivityIndicatorView!, blockEvents: Bool) {
        
        if blockEvents {
           UIApplication.shared.beginIgnoringInteractionEvents() 
        }
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                activityIndicator.startAnimating()
            }
        }
    }

    open class func stopActivityIndicator(activityIndicator: UIActivityIndicatorView?, stopProgressBar: Bool = true) {
        
        UIApplication.shared.endIgnoringInteractionEvents()
        if let activityIndicator = activityIndicator {
            if (stopProgressBar) {
                DispatchQueue.global(qos: .default).async {
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
        
    /*
     Create the popup menu for payment screen
    */
    open class func openPopupMenu(purchaseDetails: BSBaseSdkResult?,
            inNavigationController : UINavigationController,
            updateCurrencyFunc: @escaping (BSCurrency?, BSCurrency)->Void,
            errorFunc: @escaping ()->Void) -> UIAlertController {
        
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)

        // Add change currency menu item
        if BlueSnapSDK.sdkRequestBase?.allowCurrencyChange ?? true {
            let currencyMenuTitle = BSLocalizedStrings.getString(BSLocalizedString.Menu_Item_Currency)
            let currencyMenuOption = UIAlertAction(title: currencyMenuTitle, style: UIAlertAction.Style.default) { _ in
                if let purchaseDetails = purchaseDetails {
                    BSViewsManager.showCurrencyList(
                            inNavigationController: inNavigationController,
                            animated: true,
                            selectedCurrencyCode: purchaseDetails.getCurrency(),
                            updateFunc: updateCurrencyFunc,
                            errorFunc: errorFunc)
                }
            }
            menu.addAction(currencyMenuOption)
        }
        // Add Cancel menu item
        let cancelMenuTitle = BSLocalizedStrings.getString(BSLocalizedString.Menu_Item_Cancel)
        let cancelMenuOption = UIAlertAction(title: cancelMenuTitle, style: UIAlertAction.Style.cancel, handler: nil)
        menu.addAction(cancelMenuOption)
        
        //presentViewController(otherAlert, animated: true, completion: nil)
        return menu
    }
    
    /**
     Navigate to the web browser screen, showing the given URL.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - url : URL for the browser
     */
    open class func showBrowserScreen(
        inNavigationController: UINavigationController!,
        url: String!, shouldGoToUrlFunc: ((_ url : String) -> Bool)?) {
        
        let bundle = BSViewsManager.getBundle()
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
        let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.webScreenStoryboardId) as! BSWebViewController
        screen.initScreen(url: url, shouldGoToUrlFunc: shouldGoToUrlFunc)
        inNavigationController.pushViewController(screen, animated: true)
    }
    
    /**
    Generate the Pay button text according to the amounts
    */
    open class func getPayButtonText(subtotalAmount: Double!, taxAmount: Double!, toCurrency: String!) -> String {
        let amount = subtotalAmount + taxAmount
        let currencyCode = (toCurrency == "USD" ? "$" : toCurrency) ?? ""
        let payFormat = BSLocalizedStrings.getString(BSLocalizedString.Payment_Pay_Button_Format)
        let result = String(format: payFormat, currencyCode, CGFloat(amount))
        return result
    }
    
    /**
     Generate the Pay button text according to the amounts
     */
    open class func getPayButtonText(purchaseDetails : BSCcSdkResult) -> String {
        var result: String
        var payFormat: String
        
        if (purchaseDetails.isShopperRequirements()){
            payFormat = BSLocalizedStrings.getString(BSLocalizedString.Keyboard_Done_Button_Text)
        }
            
        else if (purchaseDetails.isSubscriptionCharge()){
            payFormat = (purchaseDetails.isSubscriptionHasPriceDetails() ?? false) ? BSLocalizedStrings.getString(BSLocalizedString.Subscription_with_price_details_Pay_Button_Format) : BSLocalizedStrings.getString(BSLocalizedString.Subscription_Pay_Button_Format)
        }
        
        else{
            payFormat = BSLocalizedStrings.getString(BSLocalizedString.Payment_Pay_Button_Format)
        }
        
        if (purchaseDetails.hasPriceDetails()){
            let toCurrency = purchaseDetails.getCurrency() ?? ""
            let subtotalAmount = purchaseDetails.getAmount() ?? 0.0
            let taxAmount = purchaseDetails.getTaxAmount() ?? 0.0
            
            let currencyCode = (toCurrency == "USD" ? "$" : toCurrency) 
            let amount = subtotalAmount + taxAmount
            result = String(format: payFormat, currencyCode, CGFloat(amount))
        }
            
        else{
            result = payFormat
        }
        
        return result
    }
}
