//
//  ViewController.swift
//  This is an example of a view controller using the SDK
//
////

import UIKit
import BluesnapSDK

class ViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var withShippingSwitch: UISwitch!
    @IBOutlet weak var taxTextField: UITextField!
    @IBOutlet weak var fullBillingSwitch: UISwitch!
    @IBOutlet weak var withEmailSwitch: UISwitch!
    @IBOutlet weak var coverAllView: UIView!
    @IBOutlet weak var coverAllLabel: UILabel!
    @IBOutlet weak var returningShopperSwitch: UISwitch!
    @IBOutlet weak var returningShopperIdLabel: UILabel!
    @IBOutlet var returningShopperIdTextField: UITextField!
    @IBOutlet weak var storeCurrencyButton: UIButton!
    @IBOutlet weak var allowCurrencyChangeSwitch: UISwitch!
    @IBOutlet weak var hideStoreCardSwitch: UISwitch!
    @IBOutlet weak var daysNumberTextField: UITextField!
    @IBOutlet weak var use3DSSwitch: UISwitch!
    
    // MARK: private properties

    fileprivate var bsToken: BSToken?
    fileprivate var shouldInitKount = true
    fileprivate var sdkRequestBase: BSSdkRequestProtocol?
    fileprivate var isShopperRequirements: Bool!
    fileprivate var hideCoverView: Bool = false
    final fileprivate let LOADING_MESSAGE = "Loading, please wait"
    final fileprivate let PROCESSING_MESSAGE = "Processing, please wait"
    final fileprivate let GENERATING_TOKEN_MESSAGE = "Generating a new token, please wait"
    final fileprivate let initialShippingCoutry = "US"
    final fileprivate let initialShippingState = "MA"
    final fileprivate var storeCurrency = "USD"
    final fileprivate let applePayMerchantIdentifier = "merchant.com.example.bluesnap"
    final fileprivate var returningShopperId : Int = 22061813
    final fileprivate var shopperId : Int? = nil
    final fileprivate var vaultedShopperId : String? = nil
    final fileprivate var threeDSResult : String? = nil
    final fileprivate var allowCurrencyChange: Bool! = true
    final fileprivate var hideStoreCard: Bool! = false
    final fileprivate var trialPeriodDays: Int? = nil


    // MARK: - UIViewController's methods

    override func viewDidLoad() {
        super.viewDidLoad()

        registerTapToHideKeyboard()

        // Example of using BSImageLibrary
        //if let img = BSImageLibrary.getFlag(countryCode: "US") {
        //}
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        if hideCoverView {
            coverAllView.isHidden = true
            hideCoverView = true
        }
        
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil { //Demo-App run, NOT Test
            if bsToken == nil {
                initBsToken(returningShopper: returningShopperSwitch.isOn)
            }
        }
        self.navigationController?.isNavigationBarHidden = true
        self.returningShopperIdLabel.isHidden = !returningShopperSwitch.isOn
        self.returningShopperIdTextField.isHidden = !returningShopperSwitch.isOn
        self.storeCurrencyButton.setTitle(storeCurrency, for: UIControl.State())
        amountValueDidChange(valueTextField)
    }

    // MARK: - Dismiss keyboard

    func registerTapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        if valueTextField.isFirstResponder {
            valueTextField.resignFirstResponder()
        } else if taxTextField.isFirstResponder {
            taxTextField.resignFirstResponder()
        } else if self.returningShopperIdTextField.isFirstResponder {
            self.returningShopperIdTextField.resignFirstResponder()
        } else if self.daysNumberTextField.isFirstResponder {
            self.daysNumberTextField.resignFirstResponder()
        }
    }


    // MARK: - Actions
    func buttonGeneralAction() {

        // Make sure a new token is created for the shopper
        if returningShopperIdTextField.isFirstResponder {
            returningShopperIdTextField.resignFirstResponder()
            return
        }
        dismissKeyboard()

        // Override the navigation name, so that the next screen navigation item will say "Cancel"
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem

        coverAllLabel.text = PROCESSING_MESSAGE
        coverAllView.isHidden = false
        hideCoverView = true
    }

    @IBAction func convertButtonAction(_ sender: UIButton) {
        buttonGeneralAction()
        DispatchQueue.main.async {
            // open the purchase screen
            self.fillSdkRequest(isShopperRequirements: false, isSubscriptionCharge: false)
            do {
                try BlueSnapSDK.showCheckoutScreen(
                        inNavigationController: self.navigationController,
                        animated: true,
                        sdkRequest: self.sdkRequestBase as! BSSdkRequest)
            } catch {
                NSLog("Unexpected error: \(error).")
                self.showErrorAlert(message: "Unexpected error: \(error).")
            }
        }
    }

    @IBAction func chooseButtonAction(_ sender: UIButton) {
        buttonGeneralAction()
        DispatchQueue.main.async {
            // open the purchase screen
            self.fillSdkRequest(isShopperRequirements: true, isSubscriptionCharge: false)
            do {
                try BlueSnapSDK.showChoosePaymentScreen(
                        inNavigationController: self.navigationController,
                        animated: true,
                        sdkRequestShopperRequirements: self.sdkRequestBase as! BSSdkRequestShopperRequirements)
            } catch {
                NSLog("Unexpected error: \(error).")
                self.showErrorAlert(message: "Unexpected error: \(error).")
            }
        }
    }

    @IBAction func createButtonAction(_ sender: UIButton) {
        buttonGeneralAction()
        coverAllView.isHidden = true
        hideCoverView = false
        DispatchQueue.main.async {
            // open the purchase screen
            self.fillSdkRequest(isShopperRequirements: false, isSubscriptionCharge: false)
            do {
                try BlueSnapSDK.showCreatePaymentScreen(
                        inNavigationController: self.navigationController,
                        animated: true,
                        sdkRequest: self.sdkRequestBase as! BSSdkRequest)
            } catch {
                NSLog("Unexpected error: \(error).")
                self.showErrorAlert(message: "Unexpected error: \(error).")
            }
        }
    }
    
    @IBAction func SubscriptionButtonAction(_ sender: UIButton) {
        buttonGeneralAction()
        DispatchQueue.main.async {
            // open the purchase screen
            self.fillSdkRequest(isShopperRequirements: false, isSubscriptionCharge: true)
            do {
                try BlueSnapSDK.showCheckoutScreen(
                    inNavigationController: self.navigationController,
                    animated: true,
                    sdkRequest: self.sdkRequestBase as! BSSdkRequest)
            } catch {
                NSLog("Unexpected error: \(error).")
                self.showErrorAlert(message: "Unexpected error: \(error).")
            }
        }
    }
    
    @IBAction func currencyButtonAction(_ sender: UIButton) {

        coverAllLabel.text = LOADING_MESSAGE
        coverAllView.isHidden = false
        hideCoverView = true

        DispatchQueue.main.async {
            self.fillSdkRequest(isShopperRequirements: self.isShopperRequirements, isSubscriptionCharge: false)
            BlueSnapSDK.showCurrencyList(
                    inNavigationController: self.navigationController,
                    animated: true,
                    selectedCurrencyCode: self.sdkRequestBase!.priceDetails.currency,
                    updateFunc: self.updateViewWithNewCurrency,
                    errorFunc: {
                        self.showErrorAlert(message: "Failed to display currency List, please try again")
                    })
        }
    }

    @IBAction func storeCurrencyButtonAction(_ sender: UIButton) {
        coverAllLabel.text = LOADING_MESSAGE
        coverAllView.isHidden = false
        hideCoverView = true

        DispatchQueue.main.async {
            self.fillSdkRequest(isShopperRequirements: self.isShopperRequirements ?? false , isSubscriptionCharge: false)
            BlueSnapSDK.showCurrencyList(
                    inNavigationController: self.navigationController,
                    animated: true,
                    selectedCurrencyCode: self.storeCurrency,
                    updateFunc: self.updateViewWithNewStoreCurrency,
                    errorFunc: {
                        self.showErrorAlert(message: "Failed to display currency List, please try again")
                    })
        }
    }

    // MARK: - UIPopoverPresentationControllerDelegate

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // MARK: private methods

    /**
        If you have the shopper details, you can supply initial values to the BlueSnap purchasde flow.
        This is just an exmaple with hard-coded values.
        You can supply partial data as you have it.
    */
    private func setInitialShopperDetails() {

        sdkRequestBase?.shopperConfiguration.billingDetails = BSBillingAddressDetails(email: "john@gmail.com", name: "John Doe", address: "333 elm st", city: "New York", zip: "532464", country: "US", state: "MA")

        if withShippingSwitch.isOn {
            sdkRequestBase?.shopperConfiguration.shippingDetails = BSShippingAddressDetails(name: "Mary Doe", address: "333 elm st", city: "Boston", zip: "111222", country: initialShippingCoutry, state: initialShippingState)
        }
    }

    /**
     Show error pop-up
     */
    private func showErrorAlert(message: String) {
        let alert = createErrorAlert(title: "Oops", message: message)
        present(alert, animated: true, completion: nil)
    }

    private func createErrorAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(cancel)
        return alert
        //After you create alert, you show it like this: present(alert, animated: true, completion: nil)
    }

    /**
     Here we adjust the checkout details with the latest amounts from the fields on our view.
    */
    private func fillSdkRequest(isShopperRequirements: Bool, isSubscriptionCharge: Bool) {

        let amount = (valueTextField.text! as NSString).doubleValue
        let taxAmount = (!isShopperRequirements) ? (taxTextField.text! as NSString).doubleValue : nil
        let currency = currencyButton.titleLabel?.text ?? "USD"
        let priceDetails = (!isShopperRequirements) ? BSPriceDetails(amount: amount, taxAmount: taxAmount, currency: currency) : nil
        let withShipping = withShippingSwitch.isOn
        let fullBilling = fullBillingSwitch.isOn
        let withEmail = withEmailSwitch.isOn
        if (!isShopperRequirements && !isSubscriptionCharge) {
            sdkRequestBase = BSSdkRequest(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: self.completePurchase, updateTaxFunc: self.updateTax)

        } else if (isSubscriptionCharge) {
            if ((trialPeriodDays ?? 0) > 0){ // initialize sdk for subscription flow without price details
                sdkRequestBase = BSSdkRequestSubscriptionCharge(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, billingDetails: nil, shippingDetails: nil, purchaseFunc: self.completePurchase)
            } else { // initialize sdk for subscription flow with price details
                sdkRequestBase = BSSdkRequestSubscriptionCharge(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: self.completePurchase, updateTaxFunc: self.updateTax)
            }
    
        } else {
            sdkRequestBase = BSSdkRequestShopperRequirements(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, billingDetails: nil, shippingDetails: nil, purchaseFunc: self.completePurchase)
        }
        
        sdkRequestBase?.allowCurrencyChange = self.allowCurrencyChange
        sdkRequestBase?.hideStoreCardSwitch = self.hideStoreCard
        sdkRequestBase?.activate3DS = use3DSSwitch.isOn
//        sdkRequestBase?.applePayCustomizePayLine = "Some Merchant via BlueSnap"
        NSLog("sdkRequestBase store Card = \(sdkRequestBase?.hideStoreCardSwitch)")

    }

    @IBAction func hideStoreCardSwitchChanged(_ sender: Any) {
        self.hideStoreCard = hideStoreCardSwitch.isOn
        NSLog("store Card = \(self.hideStoreCard)")
    }

    @IBAction func allowCurrencyChangeSwitchChanged(_ sender: Any) {
        self.allowCurrencyChange = allowCurrencyChangeSwitch.isOn
        NSLog("allow Currency Change = \(self.allowCurrencyChange)")
    }

    /**
     This function is called by the change currency flow when the user changes the currency.
     Here we update the checkout details and the fields in our view according tp the new currency.
    */
    private func updateViewWithNewCurrency(oldCurrency: BSCurrency?, newCurrency: BSCurrency?) {

        if let priceDetails = sdkRequestBase?.priceDetails {
            priceDetails.changeCurrencyAndConvertAmounts(newCurrency: newCurrency)
            valueTextField.text = String(format: "%.2f", CGFloat(truncating: priceDetails.amount ?? 0))
            taxTextField.text = String(format: "%.2f", CGFloat(truncating: priceDetails.taxAmount ?? 0))
            currencyButton.titleLabel?.text = priceDetails.currency
        }
    }

    /**
     This function is called by the change store currency flow when the user chooses a currency.
     Here we update the base currency.
     */
    private func updateViewWithNewStoreCurrency(oldCurrency: BSCurrency?, newCurrency: BSCurrency?) {

        if let newCurrency = newCurrency {
            if newCurrency.getCode() != self.storeCurrency {
                self.storeCurrency = newCurrency.getCode()
                self.storeCurrencyButton.setTitle(storeCurrency, for: UIControl.State())
                coverAllLabel.text = LOADING_MESSAGE
                coverAllView.isHidden = false
                hideCoverView = true
                DispatchQueue.main.async {
                    self.initBluesnap()
                }
            }
        }
    }


    /**
     This is the callback we pass to BlueSnap SDK; it will be called when all the shopper details have been
     enetered, and the secured payment details have been successfully submitted to BlueSnap server.
     In a real app, you would send the checkout details to your app server, which then would call BlueSnap API
     to execute the purchase.
     In this sample app we do it client-to-server, but this is not the way to do it in a real app.
     Note that after a transaction was created with the token, you need to clear it or generate a new one for the next transaction.
    */

    private func completePurchase(purchaseDetails: BSBaseSdkResult!) {
        NSLog("BlueSnapSDKExample Completion func")

        if purchaseDetails.isShopperRequirements() {
            NSLog("Shopper Configuration completed Successfully!")
            NSLog("ChosenPaymentMethodType: \(purchaseDetails.getChosenPaymentMethodType().rawValue)")
            if purchaseDetails is BSCcSdkResult, let ccPurchaseDetails = purchaseDetails as? BSCcSdkResult{
                let creditCard = ccPurchaseDetails.creditCard
            
            }
            showThankYouScreen(errorText: nil)
            return // no need to complete purchase via BlueSnap API
        }

        if let paypalPurchaseDetails = purchaseDetails as? BSPayPalSdkResult {

            NSLog("PayPal transaction completed Successfully! invoice ID: \(paypalPurchaseDetails.payPalInvoiceId ?? "")")
            showThankYouScreen(errorText: nil)
            return // no need to complete purchase via BlueSnap API
        }

        hideCoverView = false
        coverAllView.isHidden = false
        coverAllLabel.text = PROCESSING_MESSAGE

        var isSubscription: Bool = false
        
        if let _ = purchaseDetails as? BSApplePaySdkResult {
            NSLog("Apple Pay details accepted")
            
        } else if let ccPurchaseDetails = purchaseDetails as? BSCcSdkResult {
            let creditCard = ccPurchaseDetails.creditCard
            isSubscription = purchaseDetails.isSubscriptionCharge()
        }

        // The creation of BlueSnap Demo transaction here should be done in the merchant server!!!
        // This is just for demo purposes
        if (isSubscription){
            DispatchQueue.main.async {
                if let purchaseDetails = purchaseDetails {
                    let amount = purchaseDetails.hasPriceDetails() ? purchaseDetails.getAmount()! : (self.valueTextField.text! as NSString).doubleValue
                    let currency = purchaseDetails.hasPriceDetails() ? purchaseDetails.getCurrency()! : self.currencyButton.titleLabel?.text ?? "USD"
                    var result: (success: Bool, data: String?) = (false, nil)
                    DemoAPIHelper.createSubscriptionPlan(
                        amount: amount,
                        currency: currency,
                        trialPeriodDays: self.trialPeriodDays,
                        completion: { isSuccess, data, planId in
                            result.data = data
                            result.success = isSuccess
                            self.logResultDetails(result: result, purchaseDetails: purchaseDetails)

                            if (!isSuccess){
                                self.showThankYouScreen(result)
                            } else {
                                var result: (success: Bool, data: String?) = (false, nil)
                                DemoAPIHelper.createSubscriptionCharge(planId: planId!, bsToken: self.bsToken, completion: { isSuccess, data, shopperId in
                                    result.data = data
                                    result.success = isSuccess
                                    self.vaultedShopperId = shopperId
                                    self.logResultDetails(result: result, purchaseDetails: purchaseDetails)
                                    self.showThankYouScreen(result)
                                    
                                })
                            }
                            
                    })
                }
            }
            
        } else {
            DispatchQueue.main.async {
                var result: (success: Bool, data: String?) = (false, nil)
                if let purchaseDetails = purchaseDetails {
                    DemoAPIHelper.createTokenizedTransaction(
                        purchaseDetails: purchaseDetails,
                        bsToken: self.bsToken!,
                        completion: { isSuccess, data, shopperId in
                            result.data = data
                            result.success = isSuccess
                            self.vaultedShopperId = shopperId
                            self.threeDSResult = (purchaseDetails as? BSCcSdkResult)?.threeDSAuthenticationResult
                            self.logResultDetails(result: result, purchaseDetails: purchaseDetails)
                            self.showThankYouScreen(result)
                    })
                }
            }
        }
    }

    func showThankYouScreen(_ result: (success: Bool, data: String?)) {
        // Show success/fail screen
        NSLog("- - - - - - - - - - - - - -")
        if result.success == true {
            NSLog("BLS transaction created Successfully!\n\n\(result.data!)")
            showThankYouScreen(errorText: nil)
        } else {
            let errorText = result.data ?? ""
            NSLog("An error occurred trying to create BLS transaction.\n\n\(errorText)")
            showThankYouScreen(errorText: errorText)
        }
        hideCoverView = true
    }

    /**
    Called when value is typed in the amount field; this function is used to auto-calculate the tax value
     */
    @IBAction func amountValueDidChange(_ sender: UITextField) {

        let amount = (valueTextField.text! as NSString).doubleValue
        if (amount > 0 && withShippingSwitch.isOn) {
            let currency = currencyButton.titleLabel?.text ?? "USD"
            let priceDetails = BSPriceDetails(amount: amount, taxAmount: 0, currency: currency)
            updateTax(initialShippingCoutry, initialShippingState, priceDetails)
            taxTextField.text = "\(priceDetails.taxAmount ?? 0)"
        } else {
            taxTextField.text = "0"
        }
    }

    /**
     Called when the "with shipping" switch changes, to re-calculate the tax
    */
    @IBAction func withShippingValueChanged(_ sender: UISwitch) {
        amountValueDidChange(valueTextField)
    }

    /**
     Called when the "new shopper" switch changes, to create a new token with/without shopper
     */
    @IBAction func returningShopperValueChanged(_ sender: UISwitch) {

        self.returningShopperIdLabel.isHidden = !sender.isOn
        self.returningShopperIdTextField.isHidden = !sender.isOn

        initBsToken(returningShopper: sender.isOn)
    }

    /**
        This function is called to recalculate the tax amoutn based on the country/state.
        In this example we give tax only to US states, with 5% for all states, except NY which has 8%.
    */
    func updateTax(_ shippingCountry: String,
                   _ shippingState: String?,
                   _ priceDetails: BSPriceDetails) -> Void {

        var taxPercent: NSNumber = 0
        if shippingCountry.uppercased() == "US" {
            taxPercent = 5
            if let state = shippingState {
                if state == "NY" {
                    taxPercent = 8
                }
            }
        } else if shippingCountry.uppercased() == "CA" {
            taxPercent = 1
        }
        let newTax: NSNumber = priceDetails.amount.doubleValue * taxPercent.doubleValue / 100.0 as NSNumber
        NSLog("Changing tax amount from \(String(describing: priceDetails.taxAmount)) to \(newTax)")
        priceDetails.taxAmount = newTax
    }

    private func showThankYouScreen(errorText: String?) {

        // clear the used token
        bsToken = nil

        // Show thank you screen (ThankYouViewController)
        if let thankYouScreen = storyboard?.instantiateViewController(withIdentifier: "ThankYouViewController") as? ThankYouViewController {
            thankYouScreen.errorText = errorText
            thankYouScreen.vaultedShopperId = self.vaultedShopperId
            thankYouScreen.threeDSResult = self.threeDSResult
            self.navigationController?.pushViewController(thankYouScreen, animated: true)
        }
    }

    private func logResultDetails(result: (success: Bool, data: String?), purchaseDetails: BSBaseSdkResult!) {

        NSLog("--------------------------------------------------------")
        NSLog("Result success: \(result.success)")

        NSLog(" amount=\(purchaseDetails.getAmount() ?? 0.0)")
        NSLog(" tax=\(purchaseDetails.getTaxAmount() ?? 0.0)")
        NSLog(" currency=\(purchaseDetails.getCurrency() ?? "")")

        if let purchaseDetails = purchaseDetails as? BSCcSdkResult {
            NSLog(" payment type= Credit Card")
            if let billingDetails = purchaseDetails.getBillingDetails() {
                NSLog("Result Data: Name:\(billingDetails.name ?? "")")
                if let zip = billingDetails.zip {
                    NSLog(" Zip code:\(zip)")
                }
                if let email = billingDetails.email {
                    NSLog(" Email:\(email)")
                }
                if self.fullBillingSwitch.isOn {
                    NSLog(" Street address:\(billingDetails.address ?? "")")
                    NSLog(" City:\(billingDetails.city ?? "")")
                    NSLog(" Country code:\(billingDetails.country ?? "")")
                    NSLog(" State code:\(billingDetails.state ?? "")")
                }
            }

            if let shippingDetails = purchaseDetails.getShippingDetails() {
                NSLog("Shipping Data: Name:\(shippingDetails.name ?? "")")
                NSLog(" Zip code:\(shippingDetails.zip ?? "")")
                NSLog(" Street address:\(shippingDetails.address ?? "")")
                NSLog(" City:\(shippingDetails.city ?? "")")
                NSLog(" Country code:\(shippingDetails.country ?? "")")
                NSLog(" State code:\(shippingDetails.state ?? "")")
            }

        } else if let _ = purchaseDetails as? BSApplePaySdkResult {
            NSLog(" payment type= Apple Pay")
            NSLog("No extra data")

        } else if let purchaseDetails = purchaseDetails as? BSPayPalSdkResult {
            NSLog(" payment type= Pay Pal")
            NSLog("PayPal invoice ID:\(purchaseDetails.payPalInvoiceId ?? "")")
        }
        NSLog("--------------------------------------------------------")
    }


    // MARK: BS Token functions

    /**
     Create a test BS token and set it in BlueSnapSDK.
     In a real app, you would get the token from your app server.
     */
    func initBsToken(returningShopper: Bool) {

        // To simulate expired token use:
        //    bsToken = BSToken(tokenStr: "5e2e3f50e287eab0ba20dc1712cf0f64589c585724b99c87693a3326e28b1a3f_")

        coverAllLabel.text = GENERATING_TOKEN_MESSAGE
        coverAllView.isHidden = false
        hideCoverView = true

        shopperId = returningShopper ? returningShopperId : nil
        
        DemoAPIHelper.createToken(shopperId: shopperId, completion: { resultToken, errors in
            
            if let resultToken = resultToken {
                self.bsToken = resultToken
                self.initBluesnap()
            } else {
                NSLog("Failed to obtain Bluesnap Token")
                DispatchQueue.main.async {
                    self.coverAllView.isHidden = true
                    self.hideCoverView = true
                    self.showErrorAlert(message: "Failed to obtain BlueSnap Token, please try again.")
                }
            }
        })
    }

    private func initBluesnap() {

        DispatchQueue.main.async {
            self.coverAllLabel.text = self.LOADING_MESSAGE
        }
        do {
            try BlueSnapSDK.initBluesnap(
                bsToken: self.bsToken,
                generateTokenFunc: self.generateAndSetBsToken,
                initKount: self.shouldInitKount,
                fraudSessionId: nil,
                applePayMerchantIdentifier: self.applePayMerchantIdentifier,
                merchantStoreCurrency: self.storeCurrency,
                completion: { error in
                    if let error = error {
                        print("\(error.description())")
                    } else {
                        DispatchQueue.main.async {
                            self.coverAllView.isHidden = true
                            self.hideCoverView = true
                        }
                    }
            })
            
        } catch {
            NSLog("Unexpected error: \(error).")
            self.showErrorAlert(message: "Unexpected error: \(error).")
        }

    }

    /**
    Called by the BlueSnapSDK when token expired error is recognized.
    Here we generate and set a new token, so that when the action re-tries, it will succeed.
    In your real app you should get the token from your app server, then call
    BlueSnapSDK.setBsToken to set it.
    */
    func generateAndSetBsToken(completion: @escaping (_ token: BSToken?, _ error: BSErrors?) -> Void) {

        NSLog("Got BS token expiration notification!")
        
        DemoAPIHelper.createToken(shopperId: shopperId, completion: { resultToken, errors in
            self.bsToken = resultToken
            
            do {
                try BlueSnapSDK.setBsToken(bsToken: self.bsToken)
                NSLog("Got BS token= \(self.bsToken?.getTokenStr() ?? "")")
                DispatchQueue.main.async {
                    completion(resultToken, errors)
                }
                
            } catch {
                NSLog("Unexpected error: \(error).")
                self.showErrorAlert(message: "Unexpected error: \(error).")
            }
   
        })
    }

    @IBAction func returningShopperIdEditingDidEnd(_ sender: UITextField) {

        if sender.text != "\(self.returningShopperId)" {
            if let newShopperId = Int(sender.text ?? "") {
                self.returningShopperId = newShopperId
                if returningShopperSwitch.isOn {
                    initBsToken(returningShopper: true)
                }
            }
        }
    }
    
    @IBAction func numberOfTrialDaysChanged(_ sender: UITextField) {
        trialPeriodDays = (daysNumberTextField.text! as NSString).integerValue
    }
}
