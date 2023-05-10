//
//  ShippingViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 03/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSShippingViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: internal properties
    internal var activityIndicator : UIActivityIndicatorView?

    // MARK: private properties
    fileprivate var newCardMode = true
    fileprivate var purchaseDetails : BSCcSdkResult!
    fileprivate var existingPurchaseDetails : BSCcSdkResult?
    fileprivate var submitPaymentFields : () -> Void = { print("This will be overridden by payment screen") }
    fileprivate var updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)?
    fileprivate var countryManager : BSCountryManager!
    fileprivate var zipTopConstraintOriginalConstant : CGFloat?
    fileprivate var firstTime : Bool = true
    fileprivate var validateOnEntry : Bool = false

    // MARK: outlets
        
    @IBOutlet weak var payUIButton: UIButton!
    @IBOutlet weak var nameInputLine: BSBaseTextInput!
    @IBOutlet weak var addressInputLine: BSBaseTextInput!
    @IBOutlet weak var zipInputLine: BSBaseTextInput!
    @IBOutlet weak var cityInputLine: BSBaseTextInput!
    @IBOutlet weak var stateInputLine: BSBaseTextInput!
    @IBOutlet weak var zipTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subtotalAndTaxDetailsView: BSSubtotalUIView!

    // MARK: init

    func initScreen(purchaseDetails: BSCcSdkResult!, submitPaymentFields: @escaping () -> Void, validateOnEntry: Bool) {
        
        if let _ = purchaseDetails as? BSExistingCcSdkResult {
            newCardMode = false
            self.existingPurchaseDetails = purchaseDetails
            self.purchaseDetails = purchaseDetails.copy() as! BSCcSdkResult as? BSExistingCcSdkResult
        } else {
            self.purchaseDetails = purchaseDetails
        }
        self.submitPaymentFields = submitPaymentFields
        self.firstTime = true
        self.validateOnEntry = validateOnEntry
        self.updateTaxFunc = BlueSnapSDK.sdkRequestBase?.updateTaxFunc
    }
    
    // MARK: Keyboard functions
    
    let scrollOffset : Int = -64 // this is the Y of scrollView
    var movedUp = false
    var fieldBottom : Int?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fieldsView: UIView!
    
    override func viewDidLayoutSubviews()
    {
        let scrollViewBounds = scrollView.bounds
        //let containerViewBounds = fieldsView.bounds
        
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = scrollViewBounds.size.height/2.0;
        scrollViewInsets.top -= fieldsView.bounds.size.height/2.0;
        
        scrollViewInsets.bottom = scrollViewBounds.size.height/2.0
        scrollViewInsets.bottom -= fieldsView.bounds.size.height/2.0;
        scrollViewInsets.bottom += 1
        
        scrollView.contentInset = scrollViewInsets
    }
    
    @IBAction func editingDidBegin(_ sender: BSBaseTextInput) {
        
        fieldBottom = Int(sender.frame.origin.y + sender.frame.height)
    }

    private func scrollForKeyboard(direction: Int) {
        
        self.movedUp = (direction > 0)
        let y = 200*direction
        let point : CGPoint = CGPoint(x: 0, y: y)
        self.scrollView.setContentOffset(point, animated: false)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        var moveUp = false
        if let fieldBottom = fieldBottom {
            let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
            let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! CGRect
            let keyboardHeight = Int(keyboardFrame.height)
            let viewHeight : Int = Int(self.view.frame.height)
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
        
        self.nameInputLine.dismissKeyboard()
        self.zipInputLine.dismissKeyboard()
        self.addressInputLine.dismissKeyboard()
        self.cityInputLine.dismissKeyboard()
    }

    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTapToHideKeyboard()
        activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        if let zipTopConstraint = self.zipTopConstraint {
            zipTopConstraintOriginalConstant = zipTopConstraint.constant
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let shippingDetails = self.purchaseDetails.getShippingDetails() {
            nameInputLine.setValue(shippingDetails.name)
//            phoneInputLine.setValue(shippingDetails.phone)
            addressInputLine.setValue(shippingDetails.address)
            cityInputLine.setValue(shippingDetails.city)
            zipInputLine.setValue(shippingDetails.zip)
            if (shippingDetails.country == "") {
                shippingDetails.country = Locale.current.regionCode ?? ""
            }
            let countryCode = purchaseDetails.getShippingDetails()?.country ?? ""
            updateZipByCountry(countryCode: countryCode)
            updateFlagImage(countryCode: countryCode)
        }
        if firstTime {
            firstTime = false
            if (validateOnEntry) {
                _ = validateForm()
            } else {
                nameInputLine.hideError()
//                phoneInputLine.hideError()
                addressInputLine.hideError()
                zipInputLine.hideError()
                cityInputLine.hideError()
                stateInputLine.hideError()
            }
            updateTexts()
            updateAmounts()
        }
        updateState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        //adjustToPageRotate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    // MARK: Payment click
    
    @IBAction func SubmitClick(_ sender: Any) {        
        if (validateForm()) {
            if newCardMode {
                BSViewsManager.startActivityIndicator(activityIndicator: self.activityIndicator, blockEvents: true)
                submitPaymentFields()
            } else {
                // copy shipping values from payment request to existingPurchaseDetails
                existingPurchaseDetails?.shippingDetails = purchaseDetails.shippingDetails
                // go back to existing page
                navigationController?.popViewController(animated: true)
            }
        } else {
            //return false
        }
    }
    
    
    // MARK: Validation methods
    
    func validateForm() -> Bool {
        
        let ok1 = validateName(ignoreIfEmpty: false)
        let ok2 = validateAddress(ignoreIfEmpty: false)
        let ok3 = validateCity(ignoreIfEmpty: false)
        let ok4 = validateZip(ignoreIfEmpty: false)
        let ok5 = validateState(ignoreIfEmpty: false)
//        let ok6 = validatePhone(ignoreIfEmpty: true)
        return ok1 && ok2 && ok3 && ok4 && ok5 //11&& ok6
    }
    
    func validateName(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateName(ignoreIfEmpty: ignoreIfEmpty, input: nameInputLine, addressDetails: purchaseDetails.getShippingDetails())
        return result
    }
    
    func validateAddress(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateAddress(ignoreIfEmpty: ignoreIfEmpty, input: addressInputLine, addressDetails: purchaseDetails.getShippingDetails())
        return result
    }
    
    func validateCity(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateCity(ignoreIfEmpty: ignoreIfEmpty, input: cityInputLine, addressDetails: purchaseDetails.getShippingDetails())
        return result
    }
    
    func validateZip(ignoreIfEmpty : Bool) -> Bool {
        
        if (zipInputLine.isHidden) {
            if let shippingDetails = purchaseDetails.getShippingDetails() {
                shippingDetails.zip = ""
            }
            zipInputLine.setValue("")
            return true
        }
        
        let result = BSValidator.validateZip(ignoreIfEmpty: ignoreIfEmpty, input: zipInputLine, addressDetails: purchaseDetails.getShippingDetails())
        return result
    }
    
    func validateState(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateState(ignoreIfEmpty: ignoreIfEmpty, input: stateInputLine, addressDetails: purchaseDetails.getShippingDetails())
        return result
    }
    
//    func validatePhone(ignoreIfEmpty : Bool) -> Bool {
//
//        let result : Bool = BSValidator.validatePhone(ignoreIfEmpty: ignoreIfEmpty, input: phoneInputLine, addressDetails: purchaseDetails.getShippingDetails())
//        return result
//    }

    
    // MARK: real-time formatting and Validations on text fields
    
    @IBAction func nameEditingChanged(_ sender: BSBaseTextInput) {
        BSValidator.nameEditingChanged(sender)
    }
    
    @IBAction func nameEditingDidEnd(_ sender: BSBaseTextInput) {
        _ = validateName(ignoreIfEmpty: true)
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
    
    // enter state field - open the state screen
    @IBAction func stateTouchUpInside(_ sender: BSBaseTextInput) {
        
        BSViewsManager.showStateList(
            inNavigationController: self.navigationController,
            animated: true,
            addressDetails: purchaseDetails.getShippingDetails()!,
            updateFunc: updateWithNewState)
    }

    @IBAction func flagTouchUpInside(_ sender: BSBaseTextInput) {
        
        let selectedCountryCode = purchaseDetails.getShippingDetails()?.country ?? ""
        BSViewsManager.showCountryList(
            inNavigationController: self.navigationController,
            animated: true,
            selectedCountryCode: selectedCountryCode,
            updateFunc: updateWithNewCountry)
    }
    
    
    // MARK: private functions
    
    /*private func adjustToPageRotate() {
        
        DispatchQueue.main.async{
            
            self.nameInputLine.deviceDidRotate()
            self.streetInputLine.deviceDidRotate()
            self.zipInputLine.deviceDidRotate()
            self.cityInputLine.deviceDidRotate()
            self.stateInputLine.deviceDidRotate()
            
            self.viewDidLayoutSubviews()
        }
    }*/

    private func updateAmounts() {

        subtotalAndTaxDetailsView.isHidden = !newCardMode || self.purchaseDetails.getTaxAmount() == 0
        let toCurrency = purchaseDetails.getCurrency() ?? ""
        let subtotalAmount = purchaseDetails.getAmount() ?? 0.0
        let taxAmount = (purchaseDetails.getTaxAmount() ?? 0.0)
        subtotalAndTaxDetailsView.setAmounts(subtotalAmount: subtotalAmount, taxAmount: taxAmount, currency: toCurrency)
        
        var payButtonText = "";
        if newCardMode {
            payButtonText = BSViewsManager.getPayButtonText(purchaseDetails: purchaseDetails)

        } else {
            payButtonText = BSLocalizedStrings.getString(BSLocalizedString.Keyboard_Done_Button_Text)
        }
        payUIButton.setTitle(payButtonText, for: UIControl.State())
    }

    private func updateTexts() {

        self.title = BSLocalizedStrings.getString(BSLocalizedString.Title_Shipping_Screen)
        self.nameInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_Name)
        self.addressInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_Address)
        self.cityInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_City)
        self.stateInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_State)
    }
    
    private func updateWithNewCountry(countryCode : String, countryName : String) {
        
        if let shippingDetails = purchaseDetails.getShippingDetails() {
            shippingDetails.country = countryCode
            updateZipByCountry(countryCode: countryCode)
        }
        updateFlagImage(countryCode: countryCode)
        updateState()
        if let shippingDetails = purchaseDetails.getShippingDetails(), let updateTaxFunc = updateTaxFunc {
            updateTaxFunc(shippingDetails.country!, shippingDetails.state, purchaseDetails.priceDetails)
            updateAmounts()
        }
    }
    
    private func updateFlagImage(countryCode : String) {
        
        // load the flag image
        if let image = BSViewsManager.getImage(imageName: countryCode.uppercased()) {
            nameInputLine.image = image
        }
    }
    
    private func updateZipByCountry(countryCode: String) {

        let hideZip = BSCountryManager.getInstance().countryHasNoZip(countryCode: countryCode)
        
        self.zipInputLine.placeHolder = BSValidator.getZipPlaceholderText(countryCode: countryCode, forBilling: false)
        self.zipInputLine.fieldKeyboardType = BSValidator.getZipKeyboardType(countryCode: countryCode)
//        self.phoneInputLine.fieldKeyboardType = .phonePad
        zipInputLine.isHidden = hideZip
        zipInputLine.hideError()
        updateZipFieldLocation()
    }
    
    private func updateState() {

        BSValidator.updateState(addressDetails: purchaseDetails.getShippingDetails()!, stateInputLine: stateInputLine)
    }
    
    private func updateWithNewState(stateCode : String, stateName : String) {
        
        if let shippingDetails = purchaseDetails.getShippingDetails() {
            shippingDetails.state = stateCode
        }
//        self.stateInputLine.setValue(stateName)
//        _ = validateState(ignoreIfEmpty: false)

//        updateState()
        
        if let shippingDetails = purchaseDetails.getShippingDetails(), let updateTaxFunc = updateTaxFunc {
            updateTaxFunc(shippingDetails.country!, shippingDetails.state, purchaseDetails.priceDetails)
            updateAmounts()
        }
    }
    
    private func updateZipFieldLocation() {
        
        if !zipInputLine.isHidden {
            zipTopConstraint.constant = zipTopConstraintOriginalConstant ?? 1
        } else {
            zipTopConstraint.constant = -1 * nameInputLine.frame.height
        }
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
