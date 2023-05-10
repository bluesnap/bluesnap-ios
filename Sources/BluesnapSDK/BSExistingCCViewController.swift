//
//  BSExistingCCViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 06/11/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSExistingCCViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var existingCcView: BSExistingCcUIView!
    @IBOutlet weak var billingLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var editBillingButton: UIButton!
    @IBOutlet weak var editShippingButton: UIButton!
    @IBOutlet weak var shippingBoxView: BSBaseBoxWithShadowView!
    @IBOutlet weak var billingNameLabel: UILabel!
    @IBOutlet weak var billingAddressTextView: UITextView!
    @IBOutlet weak var shippingNameLabel: UILabel!
    @IBOutlet weak var shippingAddressTextView: UITextView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var topMenuButton: UIBarButtonItem!
    @IBOutlet weak var subtotalAndTaxDetailsView: BSSubtotalUIView!

    // MARK: private variables
    fileprivate var purchaseDetails: BSExistingCcSdkResult!
    fileprivate var activityIndicator: UIActivityIndicatorView?

    // MARK: init

    public func initScreen(purchaseDetails: BSExistingCcSdkResult!) {
        self.purchaseDetails = purchaseDetails
    }

    // MARK: - UIViewController's methods

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        self.title = BSLocalizedStrings.getString(BSLocalizedString.Title_Payment_Screen)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        existingCcView.setCc(ccType: purchaseDetails.creditCard.ccType ?? "", last4Digits: purchaseDetails.creditCard.last4Digits ?? "", expiration: purchaseDetails.creditCard.getExpiration())

        // update tax if needed
        callUpdateTax()

        // load label translations
        billingLabel.text = BSLocalizedStrings.getString(BSLocalizedString.Label_Billing)
        shippingLabel.text = BSLocalizedStrings.getString(BSLocalizedString.Label_Shipping)
        let editButtonTitle = BSLocalizedStrings.getString(BSLocalizedString.Edit_Button_Title)
        editBillingButton.setTitle(editButtonTitle, for: UIControl.State())
        editShippingButton.setTitle(editButtonTitle, for: UIControl.State())
        updateAmounts()

        // for removing inner padding from text view
        let textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)

        let billingDetails = purchaseDetails.billingDetails
        billingNameLabel.text = billingDetails?.name ?? ""
        billingAddressTextView.text = getDisplayAddress(addr: billingDetails)
        billingAddressTextView.isScrollEnabled = false
        billingAddressTextView.textContainerInset = textContainerInset

        shippingBoxView.isHidden = true
        shippingLabel.isHidden = true
        if let data = BlueSnapSDK.sdkRequestBase {
            if data.shopperConfiguration.withShipping {
                shippingBoxView.isHidden = false
                shippingLabel.isHidden = false
                shippingAddressTextView.isScrollEnabled = false
                shippingAddressTextView.textContainerInset = textContainerInset
                if let shippingDetails = purchaseDetails.shippingDetails {
                    shippingNameLabel.text = shippingDetails.name
                    shippingAddressTextView.text = getDisplayAddress(addr: shippingDetails)
                } else {
                    shippingNameLabel.text = ""
                    shippingAddressTextView.text = ""
                }
            }
        }

        // check if is allowed to show currency if not do not give option to change if yes do change
        topMenuButton.isEnabled = BlueSnapSDK.sdkRequestBase?.allowCurrencyChange ?? true
    }


    // MARK: button actions

    @IBAction func clickPay(_ sender: Any) {

        if !validateBilling() {
            editBilling(sender)
        } else if !validateShipping() {
            editShipping(sender)
        } else {
            startActivityIndicator()
            submitPaymentFields()
        }
    }

    @IBAction func editBilling(_ sender: Any) {
        _ = BSViewsManager.showCCDetailsScreen(existingCcPurchaseDetails: purchaseDetails, inNavigationController: self.navigationController, animated: true)
    }

    @IBAction func editShipping(_ sender: Any) {
        BSViewsManager.showShippingScreen(
                purchaseDetails: purchaseDetails,
                submitPaymentFields: {},
                validateOnEntry: false,
                inNavigationController: self.navigationController!,
                animated: true)
    }

    // MARK: menu actions

    private func updateCurrencyFunc(oldCurrency: BSCurrency?, newCurrency: BSCurrency) {

        purchaseDetails.priceDetails.changeCurrencyAndConvertAmounts(newCurrency: newCurrency)
        updateAmounts()
    }

    @IBAction func MenuClick(_ sender: UIBarButtonItem) {

        let menu: UIAlertController = BSViewsManager.openPopupMenu(purchaseDetails: purchaseDetails, inNavigationController: self.navigationController!, updateCurrencyFunc: updateCurrencyFunc, errorFunc: {
            let errorMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_General_Payment_error)
            self.showAlert(errorMessage)
        })
        present(menu, animated: true, completion: nil)
    }


    // MARK: private functions

    func showAlert(_ message: String) {
        let alert = BSViewsManager.createErrorAlert(title: BSLocalizedString.Error_Title_Payment, message: message)
        present(alert, animated: true, completion: nil)
    }

    private func updateAmounts() {

        callUpdateTax()

        subtotalAndTaxDetailsView.isHidden = self.purchaseDetails.getTaxAmount() == 0

        let toCurrency = purchaseDetails.getCurrency() ?? ""
        let subtotalAmount = purchaseDetails.getAmount() ?? 0.0
        let taxAmount = purchaseDetails.getTaxAmount() ?? 0.0
        subtotalAndTaxDetailsView.setAmounts(subtotalAmount: subtotalAmount, taxAmount: taxAmount, currency: toCurrency)

        let payButtonText = BSViewsManager.getPayButtonText(purchaseDetails: purchaseDetails)
        payButton.setTitle(payButtonText, for: UIControl.State())
    }

    private func callUpdateTax() {

        let sdkRequest = BlueSnapSDK.sdkRequestBase!
        let updateTaxFunc = sdkRequest.updateTaxFunc
        if updateTaxFunc != nil && sdkRequest.shopperConfiguration.withShipping && purchaseDetails.shippingDetails?.country != nil {
            let country: String = purchaseDetails.shippingDetails!.country!
            let state: String? = purchaseDetails.shippingDetails?.state
            updateTaxFunc!(country, state, purchaseDetails.priceDetails)
        }
    }

    private func submitPaymentFields() {

        BSApiManager.submitPurchaseDetails(purchaseDetails: purchaseDetails, completion: {
            creditCard, error in

            if let error = error {
                if (error == .invalidCcNumber) {
                    self.showError(BSValidator.ccnInvalidMessage)
                } else if (error == .invalidExpDate) {
                    self.showError(BSValidator.expInvalidMessage)
                } else if (error == .invalidCvv) {
                    self.showError(BSValidator.cvvInvalidMessage)
                } else {
                    NSLog("Unexpected error submitting Payment Fields to BS; error: \(error)")
                    let message = BSLocalizedStrings.getString(BSLocalizedString.Error_General_CC_Submit_Error)
                    self.showError(message)
                }
                
                self.stopActivityIndicator(stopProgressBar: false)
                
            } else if (!self.purchaseDetails!.isShopperRequirements() && BlueSnapSDK.sdkRequestBase?.activate3DS ?? false ) { // regular checkout and 3DS enabled
                
                self.cardinalAuthentication(error: error)
                
            } else if (!self.purchaseDetails!.isShopperRequirements()){ // regular checkout and 3DS disabled
                self.finishSubmitPaymentFields(error: error)
                
            } else { // shopper requirements
                BSApiManager.shopper?.chosenPaymentMethod = BSChosenPaymentMethod(chosenPaymentMethodType: BSPaymentType.CreditCard.rawValue)
                BSApiManager.shopper?.chosenPaymentMethod?.creditCard = self.purchaseDetails.creditCard
                BSApiManager.updateShopper(completion: {
                    result, error in

                    if let error = error {
                        NSLog("Unexpected error submitting Payment Fields to BS; error: \(error)")
                        let message = BSLocalizedStrings.getString(BSLocalizedString.Error_General_CC_Submit_Error)
                        self.showError(message)
                    }
                    
                    self.finishSubmitPaymentFields(error: error)
                })
            }
        })
    }

    private func cardinalAuthentication(error: BSErrors?) {
        self.stopActivityIndicator(stopProgressBar: false)
        BSCardinalManager.instance.authWith3DS(currency: self.purchaseDetails.getCurrency(), amount: String(self.purchaseDetails.getAmount()),
                                               { cardinalResult, error2 in
                                                
                                                if (cardinalResult == ThreeDSManagerResponse.AUTHENTICATION_CANCELED.rawValue) { // cardinal challenge canceled
                                                    NSLog(BSLocalizedStrings.getString(BSLocalizedString.Three_DS_Authentication_Required_Error))
                                                    self.stopActivityIndicator()
                                                    self.showAlert(BSLocalizedStrings.getString(BSLocalizedString.Three_DS_Authentication_Required_Error))
                                                    
                                                } else if (cardinalResult == ThreeDSManagerResponse.THREE_DS_ERROR.rawValue) { // server or cardinal internal error
                                                    NSLog("Unexpected BS server error in 3DS authentication; error: \(error2)")
                                                    let message = BSLocalizedStrings.getString(BSLocalizedString.Error_Three_DS_Authentication_Error) + "\n" + (error2?.description() ?? "")
                                                    self.stopActivityIndicator()
                                                    self.showAlert(message)
                                                    
                                                } else if (cardinalResult == ThreeDSManagerResponse.AUTHENTICATION_FAILED.rawValue) { // authentication failure
                                                    DispatchQueue.main.async {
                                                        self.finishSubmitPaymentFields(error: error)
                                                    }
                                                    
                                                } else { // cardinal success (success/bypass/unavailable/unsupported)
                                                    DispatchQueue.main.async {
                                                        self.finishSubmitPaymentFields(error: error)
                                                    }
                                                }
                                                
        })
    }
    
    private func finishSubmitPaymentFields(error: BSErrors?) {
        DispatchQueue.main.async {
            // complete the purchase - go back to merchant screen and call the merchant purchaseFunc
            self.stopActivityIndicator()
            if error == nil {
                self.purchaseDetails.threeDSAuthenticationResult = BSCardinalManager.instance.getThreeDSAuthResult()
                if let navigationController = self.navigationController {
                    // return to merchant screen
                    let viewControllers = navigationController.viewControllers
                    let merchantControllerIndex = viewControllers.count - 3
                    _ = navigationController.popToViewController(viewControllers[merchantControllerIndex], animated: false)
                }
                // execute callback
                BlueSnapSDK.sdkRequestBase?.purchaseFunc(self.purchaseDetails)
            }
        }
    }

    private func getDisplayAddress(addr: BSBaseAddressDetails?) -> String {

        var result = ""
        if let addr = addr as? BSBillingAddressDetails {
            if let email = addr.email {
                result = result + email + "\n"
            }
        }
        if let addr = addr {
            if let address = addr.address {
                result = result + address + ", "
            }
            if let city = addr.city {
                result = result + city + " "
            }
            if let state = addr.state {
                result = result + state + " "
            }
            if let zip = addr.zip {
                result = result + zip + " "
            }
            if let country = addr.country {
                let countryName = BSCountryManager.getInstance().getCountryName(countryCode: country)
                result = result + (countryName ?? country)
            }
        }
        return result
    }

    private func showError(_ message: String) {
        // TODO
    }

    // MARK: Validation methods

    func validateBilling() -> Bool {

        var result = false
        if let data = BlueSnapSDK.sdkRequestBase {

            // not validating CC, seeing as it is an existing one

            result = BSValidator.isValidName(purchaseDetails.billingDetails.name)
            if data.shopperConfiguration.withEmail {
                result = result && BSValidator.isValidEmail(purchaseDetails.billingDetails.email ?? "")
            }
            result = result && BSValidator.isValidZip(countryCode: purchaseDetails.billingDetails.country ?? "", zip: purchaseDetails.billingDetails.zip ?? "")
            if data.shopperConfiguration.fullBilling {
                let ok1 = BSValidator.isValidCity(purchaseDetails.billingDetails.city ?? "")
                let ok2 = BSValidator.isValidAddress(purchaseDetails.billingDetails.address ?? "")
                let ok3 = BSValidator.isValidCountry(countryCode: purchaseDetails.billingDetails.country)
                let ok4 = BSValidator.isValidState(countryCode: purchaseDetails.billingDetails.country ?? "", stateCode: purchaseDetails.billingDetails.state)
                result = result && ok1 && ok2 && ok3 && ok4
            }
        }
        return result
    }

    func validateShipping() -> Bool {

        var result = true
        if let data = BlueSnapSDK.sdkRequestBase {
            if data.shopperConfiguration.withShipping {
                if let shippingDetails = purchaseDetails.shippingDetails {
                    let ok1 = BSValidator.isValidName(shippingDetails.name)
                    let ok2 = BSValidator.isValidCity(shippingDetails.city ?? "")
                    let ok3 = BSValidator.isValidAddress(shippingDetails.address ?? "")
                    let ok4 = BSValidator.isValidCountry(countryCode: shippingDetails.country)
                    let ok5 = BSValidator.isValidState(countryCode: shippingDetails.country ?? "", stateCode: shippingDetails.state)
                    let ok6 = BSValidator.isValidZip(countryCode: shippingDetails.country ?? "", zip: shippingDetails.zip ?? "")
                    result = ok1 && ok2 && ok3 && ok4 && ok5 && ok6
                }
            }
        }
        return result
    }
    
    // MARK: activity indicator methods

    func startActivityIndicator() {
        BSViewsManager.startActivityIndicator(activityIndicator: self.activityIndicator, blockEvents: true)
    }

    func stopActivityIndicator(stopProgressBar: Bool = true) {
        BSViewsManager.stopActivityIndicator(activityIndicator: self.activityIndicator, stopProgressBar: stopProgressBar)
    }
}
