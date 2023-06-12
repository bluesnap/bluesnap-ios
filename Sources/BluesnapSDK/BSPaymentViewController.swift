//
//  BSPaymentViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 21/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSPaymentViewController: UIViewController, UITextFieldDelegate, BSCcInputLineDelegate {


    // MARK: private properties

    fileprivate var newCardMode = true
    fileprivate var hideStoreCardSwitch = false
    fileprivate var withShipping = false
    fileprivate var fullBilling = false
    fileprivate var withEmail = true
    fileprivate var cardType: String?
    fileprivate var activityIndicator: UIActivityIndicatorView?
    fileprivate var firstTime: Bool = true
    fileprivate var firstTimeShipping: Bool = true
    fileprivate var payButtonText: String?
    fileprivate var zipTopConstraintOriginalConstant: CGFloat?
    fileprivate var purchaseDetails: BSCcSdkResult!
    fileprivate var existingPurchaseDetails: BSCcSdkResult?
    fileprivate var updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)?
    fileprivate var countryManager = BSCountryManager.getInstance()
    @IBOutlet var menuButton: [UIBarButtonItem]!

    // MARK: - Outlets

    @IBOutlet weak var topMenuButton: UIBarButtonItem!

    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var subtotalAndTaxDetailsView: BSSubtotalUIView!

    @IBOutlet weak var ccInputLine: BSCcInputLine!
    @IBOutlet weak var existingCcView: BSExistingCcUIView!

    @IBOutlet weak var nameInputLine: BSBaseTextInput!
    @IBOutlet weak var emailInputLine: BSBaseTextInput!
    @IBOutlet weak var addressInputLine: BSBaseTextInput!
    @IBOutlet weak var zipInputLine: BSBaseTextInput!
    @IBOutlet weak var cityInputLine: BSBaseTextInput!
    @IBOutlet weak var stateInputLine: BSBaseTextInput!

    @IBOutlet weak var shippingSameAsBillingView: UIView!
    @IBOutlet weak var shippingSameAsBillingSwitch: UISwitch!
    @IBOutlet weak var shippingSameAsBillingLabel: UILabel!

    @IBOutlet weak var storeCardView: UIView!
    @IBOutlet weak var storeCardSwitch: UISwitch!
    @IBOutlet weak var storeCardLabel: UILabel!

    @IBOutlet weak var zipTopConstraint: NSLayoutConstraint!

    // MARK: init

    public func initScreen(purchaseDetails: BSCcSdkResult!) {

        self.firstTime = true
        self.firstTimeShipping = true
        if let data = BlueSnapSDK.sdkRequestBase {
            self.fullBilling = data.shopperConfiguration.fullBilling
            self.withEmail = data.shopperConfiguration.withEmail
            self.withShipping = data.shopperConfiguration.withShipping
            self.updateTaxFunc = data.updateTaxFunc
            self.hideStoreCardSwitch = data.hideStoreCardSwitch
        }
        if let _ = purchaseDetails as? BSExistingCcSdkResult {
            newCardMode = false
            self.existingPurchaseDetails = purchaseDetails
            self.purchaseDetails = purchaseDetails.copy() as! BSCcSdkResult as? BSExistingCcSdkResult
        } else {
            self.purchaseDetails = purchaseDetails
        }
    }

    // MARK: Keyboard functions

    let scrollOffset: Int = -64 // this is the Y of scrollView
    var movedUp = false
    var fieldBottom: Int?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fieldsView: UIView!

    override func viewDidLayoutSubviews() {
        let scrollViewBounds = scrollView.bounds
        //let containerViewBounds = fieldsView.bounds

        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = scrollViewBounds.size.height / 2.0;
        scrollViewInsets.top -= fieldsView.bounds.size.height / 2.0;

        scrollViewInsets.bottom = scrollViewBounds.size.height / 2.0
        scrollViewInsets.bottom -= fieldsView.bounds.size.height / 2.0;
        scrollViewInsets.bottom += 1

        scrollView.contentInset = scrollViewInsets
    }

    @IBAction func editingDidBegin(_ sender: BSBaseTextInput) {

        fieldBottom = Int(sender.frame.origin.y + sender.frame.height)
    }

    private func scrollForKeyboard(direction: Int) {

        self.movedUp = (direction > 0)
        let y = 200 * direction
        let point: CGPoint = CGPoint(x: 0, y: y)
        self.scrollView.setContentOffset(point, animated: false)
    }

    @objc func keyboardWillShow(notification: NSNotification) {

        var moveUp = false
        if let fieldBottom = fieldBottom {
            let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
            let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! CGRect
            let keyboardHeight = Int(keyboardFrame.height)
            let viewHeight: Int = Int(self.view.frame.height)
            let offset = fieldBottom + keyboardHeight - scrollOffset
            if (offset > viewHeight) {
                moveUp = true
            }
        }

        if !self.movedUp && moveUp {
            scrollForKeyboard(direction: 1)
        } else if self.movedUp && !moveUp {
            scrollForKeyboard(direction: 0)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {

        if self.movedUp {
            scrollForKeyboard(direction: 0)
        }
    }

    func registerTapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {

        self.ccInputLine.dismissKeyboard()
        self.nameInputLine.dismissKeyboard()
        self.emailInputLine.dismissKeyboard()
        self.zipInputLine.dismissKeyboard()
        self.addressInputLine.dismissKeyboard()
        self.cityInputLine.dismissKeyboard()
    }

    // MARK: BSCcInputLineDelegate methods


    func startEditCreditCard() {
//        hideShowFields()
    }

    func endEditCreditCard() {
//        hideShowFields()
    }

    func willCheckCreditCard() {
    }

    func didCheckCreditCard(creditCard: BSCreditCard, error: BSErrors?) {
        if error == nil {
            purchaseDetails.creditCard = creditCard
            if let issuingCountry = creditCard.ccIssuingCountry {
                self.updateWithNewCountry(countryCode: issuingCountry, countryName: "")
            }
        }
    }

    func didSubmitCreditCard(creditCard: BSCreditCard, error: BSErrors?) {

        if let navigationController = self.navigationController {

            let viewControllers = navigationController.viewControllers
            let topController = viewControllers[viewControllers.count - 1]
            let inShippingScreen = topController != self
            self.stopActivityIndicator()
            
            if error == nil {
                purchaseDetails.creditCard = creditCard
                purchaseDetails.threeDSAuthenticationResult = BSCardinalManager.instance.getThreeDSAuthResult()
                // return to merchant screen
                
                let merchantControllerIndex = viewControllers.count - (inShippingScreen ? 4 : 3) + (BSApiManager.isNewCCOnlyPaymentMethod() ? 1 : 0)

                _ = navigationController.popToViewController(viewControllers[merchantControllerIndex], animated: false)
                // execute callback
                BlueSnapSDK.sdkRequestBase?.purchaseFunc(self.purchaseDetails)
            } else {
                // error
                if inShippingScreen {
                    _ = navigationController.popViewController(animated: false)
                }
            }
        }
    }


    func showAlert(_ message: String) {
        let alert = BSViewsManager.createErrorAlert(title: BSLocalizedString.Error_Title_Payment, message: message)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }


    // MARK: - UIViewController's methods

    override func viewDidLoad() {
        super.viewDidLoad()

        ccInputLine.delegate = self

        emailInputLine.fieldKeyboardType = .emailAddress
        activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        if let zipTopConstraint = self.zipTopConstraint {
            zipTopConstraintOriginalConstant = zipTopConstraint.constant
        }

        /*NotificationCenter.default.addObserver(
            self,
            selector:  #selector(deviceDidRotate),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )*/
        registerTapToHideKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.navigationController!.isNavigationBarHidden = false

        shippingSameAsBillingView.isHidden = !newCardMode || !self.withShipping || !self.fullBilling || self.purchaseDetails.getShippingDetails()?.name ?? "" != ""
        
        // set the 'shipping same as billing' to be true if no shipping name is supplied
        if self.firstTime == true {

            shippingSameAsBillingSwitch.isOn = !shippingSameAsBillingView.isHidden

            // in case of empty shipping country - fill with default and call updateTaxFunc
            if withShipping {
                if purchaseDetails.shippingDetails!.country ?? "" == "" {
                    let defaultCountry = NSLocale.current.regionCode ?? BSCountryManager.US_COUNTRY_CODE
                    purchaseDetails.shippingDetails!.country = defaultCountry
                }
                callUpdateTax(ifSameAsBilling: false, ifNotSameAsBilling: true)
            }
        }

        updateTexts()
        updateAmounts()

        if self.firstTime == true {
            self.firstTime = false
            if let billingDetails = self.purchaseDetails.getBillingDetails() {
                self.nameInputLine.setValue(billingDetails.name)
                self.emailInputLine.setValue(billingDetails.email)
                self.zipInputLine.setValue(billingDetails.zip)
                if fullBilling {
                    self.addressInputLine.setValue(billingDetails.address)
                    self.cityInputLine.setValue(billingDetails.city)
                }
            }
            nameInputLine.hideError()
            emailInputLine.hideError()
            addressInputLine.hideError()
            zipInputLine.hideError()
            cityInputLine.hideError()
            stateInputLine.hideError()
            if (!newCardMode) {
                ccInputLine.closeOnLeave()
            } else {
                ccInputLine.reset()
            }
            
            storeCardSwitch.isOn = false
        }
        hideShowFields()
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        if newCardMode && ccInputLine.ccnIsOpen == true {
            self.ccInputLine.focusOnCcnField()
        } else {
            self.nameInputLine.becomeFirstResponder()
        }
        //adjustToPageRotate()
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        if newCardMode {
            ccInputLine.closeOnLeave()
        }
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }

    private func isShippingSameAsBilling() -> Bool {
        return newCardMode && self.withShipping && self.fullBilling && self.shippingSameAsBillingSwitch.isOn
    }

    private func hideShowFields() {

        if let purchaseDetails = purchaseDetails as? BSExistingCcSdkResult {
            ccInputLine.isHidden = true
            existingCcView.isHidden = false
            let creditCard = purchaseDetails.creditCard
            existingCcView.setCc(ccType: creditCard.ccType ?? "", last4Digits: creditCard.last4Digits ?? "", expiration: creditCard.getExpiration())
            topMenuButton.isEnabled = false
            storeCardView.isHidden = true

        } else {
            ccInputLine.isHidden = false
            existingCcView.isHidden = true
            // check if is allowed to show currency if not do not give option to change if yes do change
            topMenuButton.isEnabled = BlueSnapSDK.sdkRequestBase?.allowCurrencyChange ?? true
            storeCardView.isHidden = self.hideStoreCardSwitch
        }
        
        nameInputLine.isHidden = false
        emailInputLine.isHidden = !self.withEmail
        let hideFields = !self.fullBilling
        addressInputLine.isHidden = hideFields
        let countryCode = self.purchaseDetails.getBillingDetails().country ?? ""
        updateZipByCountry(countryCode: countryCode)
        updateFlagImage(countryCode: countryCode)
        cityInputLine.isHidden = hideFields
        updateState()
        
        shippingSameAsBillingView.isHidden = !newCardMode || !self.withShipping || !self.fullBilling || self.purchaseDetails.getShippingDetails()?.name ?? "" != ""
        subtotalAndTaxDetailsView.isHidden = !newCardMode || self.purchaseDetails.getTaxAmount() == 0 || purchaseDetails.isShopperRequirements() || (purchaseDetails.isSubscriptionCharge() && !purchaseDetails.isSubscriptionHasPriceDetails()!)
        updateZipFieldLocation()
    }

    /*func deviceDidRotate() {
    }*/

    private func updateState() {

        if (fullBilling) {
            BSValidator.updateState(addressDetails: purchaseDetails.getBillingDetails(), stateInputLine: stateInputLine)
        } else {
            stateInputLine.isHidden = true
        }
    }

    private func updateTexts() {

        if self.newCardMode {
            self.title = BSLocalizedStrings.getString(BSLocalizedString.Title_Payment_Screen)
        } else {
            self.title = BSLocalizedStrings.getString(BSLocalizedString.Label_Billing)
        }
        updateAmounts()

        self.nameInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_Name)
        self.emailInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_Email)
        self.addressInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_Address)
        self.cityInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_City)
        self.stateInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_State)

        self.shippingSameAsBillingLabel.text = BSLocalizedStrings.getString(BSLocalizedString.Label_Shipping_Same_As_Billing)
        self.storeCardLabel.text = BSLocalizedStrings.getString(BSLocalizedString.Label_Store_Card)
    }

    private func updateAmounts() {

        subtotalAndTaxDetailsView.isHidden = !newCardMode || self.purchaseDetails.getTaxAmount() == 0

        let toCurrency = purchaseDetails.getCurrency() ?? ""
        let subtotalAmount = purchaseDetails.getAmount() ?? 0.0
        let taxAmount = purchaseDetails.getTaxAmount() ?? 0.0
        subtotalAndTaxDetailsView.setAmounts(subtotalAmount: subtotalAmount, taxAmount: taxAmount, currency: toCurrency)

        if newCardMode {
            payButtonText = BSViewsManager.getPayButtonText(purchaseDetails: purchaseDetails)
        } else {
            payButtonText = BSLocalizedStrings.getString(BSLocalizedString.Keyboard_Done_Button_Text)
        }
        updatePayButtonText()
    }

    private func updatePayButtonText() {

        if (newCardMode && self.withShipping && !isShippingSameAsBilling()) {
            let shippingButtonText = BSLocalizedStrings.getString(BSLocalizedString.Payment_Shipping_Button)
            payButton.setTitle(shippingButtonText, for: UIControl.State())
        } else {
            payButton.setTitle(payButtonText, for: UIControl.State())
        }
    }

    func submitPaymentFields() {

        self.ccInputLine.submitPaymentFields(purchaseDetails: self.purchaseDetails, { ccn, creditCard, error in
            self.stopActivityIndicator(stopProgressBar: false)
            BSCardinalManager.instance.authWith3DS(currency: self.purchaseDetails.getCurrency(), amount: String(self.purchaseDetails.getAmount()), creditCardNumber: ccn,
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
                                                            self.ccInputLine.delegate?.didSubmitCreditCard(creditCard: creditCard, error: error)
                                                        }
                                                        
                                                    } else { // cardinal success (success/bypass/unavailable/unsupported)
                                                        DispatchQueue.main.async {
                                                            self.ccInputLine.delegate?.didSubmitCreditCard(creditCard: creditCard, error: error)
                                                        }
                                                    }
                                                    
            })
        })
    }
    
    /**
     Show 3DS required pop-up
     */
    private func show3DSRequiredAlert() {
        let alert = createAlert(title: "Oops", message: "3DS Authentication is required")
        present(alert, animated: true, completion: nil)
    }
    
    private func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(cancel)
        return alert
        //After you create alert, you show it like this: present(alert, animated: true, completion: nil)
    }

    private func gotoShippingScreen() {

        BSViewsManager.showShippingScreen(
                purchaseDetails: purchaseDetails,
                submitPaymentFields: submitPaymentFields,
                validateOnEntry: !firstTimeShipping,
                inNavigationController: self.navigationController!,
                animated: true)
    }


    private func updateWithNewCountry(countryCode: String, countryName: String) {

        purchaseDetails.getBillingDetails().country = countryCode
        updateZipByCountry(countryCode: countryCode)
        updateState()

        // load the flag image
        updateFlagImage(countryCode: countryCode.uppercased())

        callUpdateTax(ifSameAsBilling: true, ifNotSameAsBilling: false)
    }

    private func updateZipByCountry(countryCode: String) {

        let hideZip = BSCountryManager.getInstance().countryHasNoZip(countryCode: countryCode)
        self.zipInputLine.placeHolder = BSValidator.getZipPlaceholderText(countryCode: countryCode, forBilling: true)
        self.zipInputLine.fieldKeyboardType = BSValidator.getZipKeyboardType(countryCode: countryCode)
        self.zipInputLine.isHidden = hideZip
        self.zipInputLine.hideError()
        //self.streetInputLine.fieldKeyboardType = .numbersAndPunctuation
    }

    private func updateWithNewState(stateCode: String, stateName: String) {

        purchaseDetails.getBillingDetails().state = stateCode
        self.stateInputLine.setValue(stateName)
        callUpdateTax(ifSameAsBilling: true, ifNotSameAsBilling: false)
    }

    private func updateFlagImage(countryCode: String) {

        // load the flag image
        if let image = BSViewsManager.getImage(imageName: countryCode.uppercased()) {
            nameInputLine.image = image
        }
    }

    private func updateZipFieldLocation() {

        if !zipInputLine.isHidden {
            if withEmail {
                zipTopConstraint.constant = zipTopConstraintOriginalConstant ?? 1
            } else {
                zipTopConstraint.constant = -1 * emailInputLine.frame.height
            }
        } else {
            if withEmail {
                zipTopConstraint.constant = -1 * emailInputLine.frame.height
            } else {
                zipTopConstraint.constant = -2 * emailInputLine.frame.height
            }
        }
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

    // MARK: button actions

    @IBAction func shippingSameAsBillingValueChanged(_ sender: Any) {

        callUpdateTax(ifSameAsBilling: true, ifNotSameAsBilling: true)
        updateAmounts()
    }

    @IBAction func storeCardValueChanged(_ sender: Any) {
        purchaseDetails.storeCard = storeCardSwitch.isOn
        storeCardLabel.textColor = BSColorCompat.label
    }

    private func callUpdateTax(ifSameAsBilling: Bool, ifNotSameAsBilling: Bool) {

        if updateTaxFunc != nil && self.withShipping {
            var country: String = ""
            var state: String?
            var callFunc: Bool = false
            if ifSameAsBilling && isShippingSameAsBilling() {
                country = purchaseDetails.billingDetails.country!
                state = purchaseDetails.billingDetails.state
                callFunc = true
            } else if ifNotSameAsBilling && !isShippingSameAsBilling() {
                let defaultCountry = NSLocale.current.regionCode ?? BSCountryManager.US_COUNTRY_CODE
                country = purchaseDetails.shippingDetails?.country ?? defaultCountry
                state = purchaseDetails.shippingDetails?.state
                callFunc = true
            }
            if callFunc {
                updateTaxFunc!(country, state, purchaseDetails.priceDetails)
            }
        }
    }

    @IBAction func clickPay(_ sender: UIButton) {

        if (validateForm()) {

            if !newCardMode {
                updateExistingPurchaseDetailsAndGoBack()
            } else if (withShipping && !isShippingSameAsBilling()) {
                updateAmounts()
                gotoShippingScreen()
            } else {
                startActivityIndicator()
                submitPaymentFields()
            }
        } else {
            //return false
        }
    }

    private func updateExistingPurchaseDetailsAndGoBack() {

        // copy billing values from payment request to existingPurchaseDetails
        existingPurchaseDetails?.billingDetails = purchaseDetails.billingDetails

        if isShippingSameAsBilling() {
            // copy shipping values from payment request to existingPurchaseDetails
            existingPurchaseDetails?.shippingDetails = purchaseDetails.shippingDetails
        }

        // go back to existing page
        navigationController?.popViewController(animated: true)
    }

    // MARK: Validation methods

    func validateForm() -> Bool {

        let ok1 = validateName(ignoreIfEmpty: false)
        let ok2 = newCardMode ? ccInputLine.validate() : true
        let ok3 = validateEmail(ignoreIfEmpty: false)
        let ok4 = validateStoreCard(isShopperRequirements: purchaseDetails.isShopperRequirements(), isSubscriptionCharge: purchaseDetails.isSubscriptionCharge())
        var result = ok1 && ok2 && ok3 && ok4

        if fullBilling {
            let ok1 = validateZip(ignoreIfEmpty: false)
            let ok2 = validateAddress(ignoreIfEmpty: false)
            let ok3 = validateCity(ignoreIfEmpty: false)
            let ok4 = validateState(ignoreIfEmpty: false)
            result = result && ok1 && ok2 && ok3 && ok4
        } else {
            let ok1 = zipInputLine.isHidden ? true : validateZip(ignoreIfEmpty: false)
            result = result && ok1
        }

        if result && isShippingSameAsBilling() {
            // copy billing details to shipping
            if let shippingDetails = self.purchaseDetails.getShippingDetails(), let billingDetails = self.purchaseDetails.getBillingDetails() {
                shippingDetails.address = billingDetails.address
                shippingDetails.city = billingDetails.city
                shippingDetails.country = billingDetails.country
                shippingDetails.name = billingDetails.name
                shippingDetails.state = billingDetails.state
                shippingDetails.zip = billingDetails.zip
            }
        }

        return result
    }

    func validateName(ignoreIfEmpty: Bool) -> Bool {

        let result: Bool = BSValidator.validateName(ignoreIfEmpty: ignoreIfEmpty, input: nameInputLine, addressDetails: purchaseDetails.getBillingDetails())
        return result
    }

    func validateEmail(ignoreIfEmpty: Bool) -> Bool {

        if emailInputLine.isHidden {
            return true
        }
        let result: Bool = BSValidator.validateEmail(ignoreIfEmpty: ignoreIfEmpty, input: emailInputLine, addressDetails: purchaseDetails.getBillingDetails())
        return result
    }

    func validateAddress(ignoreIfEmpty: Bool) -> Bool {

        let result: Bool = BSValidator.validateAddress(ignoreIfEmpty: ignoreIfEmpty, input: addressInputLine, addressDetails: purchaseDetails.getBillingDetails())
        return result
    }

    func validateCity(ignoreIfEmpty: Bool) -> Bool {

        let result: Bool = BSValidator.validateCity(ignoreIfEmpty: ignoreIfEmpty, input: cityInputLine, addressDetails: purchaseDetails.getBillingDetails())
        return result
    }

    func validateZip(ignoreIfEmpty: Bool) -> Bool {

        if (zipInputLine.isHidden) {
            purchaseDetails.getBillingDetails().zip = ""
            zipInputLine.setValue("")
            return true
        }

        // make zip optional for cards other than visa/discover
        var ignoreEmptyZip = ignoreIfEmpty
        let ccType = self.ccInputLine.getCardType().lowercased()
        if !ignoreIfEmpty && !fullBilling && ccType != "visa" && ccType != "discover" {
            ignoreEmptyZip = true
        }

        let result = BSValidator.validateZip(ignoreIfEmpty: ignoreEmptyZip, input: zipInputLine, addressDetails: purchaseDetails.getBillingDetails())
        return result
    }

    func validateState(ignoreIfEmpty: Bool) -> Bool {

        let result: Bool = BSValidator.validateState(ignoreIfEmpty: ignoreIfEmpty, input: stateInputLine, addressDetails: purchaseDetails.getBillingDetails())
        return result
    }

    func validateStoreCard(isShopperRequirements: Bool, isSubscriptionCharge: Bool) -> Bool {
        let result: Bool = BSValidator.validateStoreCard(isShopperRequirements: isShopperRequirements, isSubscriptionCharge: isSubscriptionCharge, isStoreCard: storeCardSwitch.isOn, isExistingCC: purchaseDetails is BSExistingCcSdkResult)
        if !result {
            storeCardLabel.textColor = UIColor.systemRed
            storeCardSwitch.tintColor = BSColorCompat.label
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


    // MARK: real-time formatting and Validations on text fields

    @IBAction func nameEditingChanged(_ sender: BSBaseTextInput) {

        BSValidator.nameEditingChanged(sender)
    }

    @IBAction func nameEditingDidEnd(_ sender: BSBaseTextInput) {
        _ = validateName(ignoreIfEmpty: true)
    }

    @IBAction func countryFlagClick(_ sender: BSBaseTextInput) {

        // open the country screen
        let selectedCountryCode = purchaseDetails.getBillingDetails().country ?? ""
        BSViewsManager.showCountryList(
                inNavigationController: self.navigationController,
                animated: true,
                selectedCountryCode: selectedCountryCode,
                updateFunc: updateWithNewCountry)
    }

    @IBAction func emailEditingChanged(_ sender: BSBaseTextInput) {
        BSValidator.emailEditingChanged(sender)
    }

    @IBAction func emailEditingDidEnd(_ sender: BSBaseTextInput) {
        _ = validateEmail(ignoreIfEmpty: true)
    }

    @IBAction func addressEditingChanged(_ sender: BSBaseTextInput) {
        BSValidator.addressEditingChanged(sender)
    }

    @IBAction func addressEditingDidEnd(_ sender: BSBaseTextInput) {
        _ = validateAddress(ignoreIfEmpty: true)
    }

    @IBAction func addressEditingDidBegin(_ sender: BSBaseTextInput) {

        editingDidBegin(sender)
        if addressInputLine.getValue() == "" {
            addressInputLine.fieldKeyboardType = .numbersAndPunctuation
        } else {
            addressInputLine.fieldKeyboardType = .default
        }
    }

    @IBAction func cityEditingChanged(_ sender: BSBaseTextInput) {
        BSValidator.cityEditingChanged(sender)
    }

    @IBAction func cityEditingDidEnd(_ sender: BSBaseTextInput) {
        _ = validateCity(ignoreIfEmpty: true)
    }

    @IBAction func zipEditingChanged(_ sender: BSBaseTextInput) {
        BSValidator.zipEditingChanged(sender)
    }

    @IBAction func zipEditingDidEnd(_ sender: BSBaseTextInput) {
        _ = validateZip(ignoreIfEmpty: true)
    }

    @IBAction func stateClick(_ sender: BSBaseTextInput) {

        // open the state screen
        BSViewsManager.showStateList(
                inNavigationController: self.navigationController,
                animated: true,
                addressDetails: purchaseDetails.getBillingDetails(),
                updateFunc: updateWithNewState)
    }

    // MARK: Prevent rotation, support only Portrait mode

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

}
