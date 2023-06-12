//
//  BSBaseTextInput.swift
//  BluesnapSDK
//
//  Base control with one text field, one image button showing on a white
//  strip with a shadow. The field can be editable or not.
//
//  Created by Shevie Chen on 22/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

@IBDesignable
public class BSBaseTextInput: UIControl, UITextFieldDelegate {

    // MARK: Configurable properties
    

    // Mark: Text input configurable properties
    
    /**
        isEditable (default = true) determines if the field can be edited; otherwise it is covered by
        a clear button. Clicking on that button sets the touchUpInside action
     */
    @IBInspectable var isEditable: Bool = true
    
    /**
        placeHolder (default = blank) determines the placeholder on the text field, meaning: 
        grayed text that appears when the field is empty
    */
    @IBInspectable var placeHolder: String = "" {
        didSet {
            textField.placeholder = placeHolder
        }
    }
    /**
        textColor (default = black) determines the text color of the text field
    */
    @IBInspectable var textColor: UIColor = BSColorCompat.label {
        didSet {
            if designMode {
                setElementAttributes()
            }
        }
    }
    /**
        fieldBkdColor (default = white) determines the background color of the text field (just the field, not the whole component)
     */
    @IBInspectable var fieldBkdColor: UIColor = UIColor.clear {
        didSet {
            if designMode {
                setElementAttributes()
            }
        }
    }
    /**
        fieldKeyboardType (default = .normal) determines the keyboard type for the text field
    */
    @IBInspectable var fieldKeyboardType : UIKeyboardType = UIKeyboardType.default {
        didSet {
            setKeyboardType()
        }
    }
    /**
        fontName (default = "Helvetica Neue") determines the type of font used in the text field
     */
    @IBInspectable var fontName : String = "Helvetica Neue" {
        didSet {
            self.setFont()
        }
    }
    /**
        fieldFontSize (default = 17) determines the font size for the text field. Note that the actual size may change on different devices; this font size should match the design you're working on (see remark below about sizes)
     */
    @IBInspectable var fieldFontSize : CGFloat = 17 {
        didSet {
            self.setFont()
        }
    }
    /**
        fieldCornerRadius (default = 0) sets the radius for rounded corners on the text field. This value will not change on different devices.
     */
    @IBInspectable var fieldCornerRadius : CGFloat = 1 {
        didSet {
            if designMode {
                resizeElements()
            }
        }
    }
    /**
        fieldBorderWidth (default = 0) sets the border for the text field. This value will not change on different devices.
     */
    @IBInspectable var fieldBorderWidth : CGFloat = 0 {
        didSet {
            if designMode {
                setElementAttributes()
            }
        }
    }
    /**
        fieldBorderColor (no default but optional) determines the border color for the text field.
     */
    @IBInspectable var fieldBorderColor: UIColor? {
        didSet {
            if designMode {
                setElementAttributes()
            }
        }
    }
    
    // Mark: image configurable properties
    
    /**
        image (optional) - if contains a value - will be displayed on the right of the text field (in a button). Clicking on it triggers the TouchUpInside handler.
     */
    @IBInspectable var image: UIImage? {
        didSet {
            self.imageButton.setImage(image, for: .normal)
        }
    }
    
    // Mark: Size and margin size configurable properties
    
    /** Set the sizes according to your design width and height; the component will be resized at runtime using horizontal and vertical ratio between this size and the actual screen size. If you leave as-is, you can resize the component on the storyboard and that will work fine - just the proportions will remain according to these sizes; so if you want to change margins etc, I recommend setting designWidth and designHeight as well.
    */
    @IBInspectable var designWidth : CGFloat = 335 {
        didSet {
            if designMode {
                resizeElements()
            }
        }
    }
    @IBInspectable var designHeight : CGFloat = 43 {
        didSet {
            if designMode {
                resizeElements()
            }
        }
    }
    /**
        leftMargin (default = 16) determines the space on the left of the component, before the text field. Value will change according to the device at runtime.
     */
    @IBInspectable var leftMargin : CGFloat = 16 {
        didSet {
            if designMode {
                resizeElements()
            }
        }
    }
    /**
        middleMargin (default = 8) determines the space between the text field and the image. Value will change according to the device at runtime.
     */
    @IBInspectable var middleMargin : CGFloat = 8 {
        didSet {
            if designMode {
                resizeElements()
            }
        }
    }
    /**
        leftMargin (default = 16) determines the space on the right of the component, after the image. Value will change according to the device at runtime.
     */
    @IBInspectable var rightMargin : CGFloat = 16 {
        didSet {
            if designMode {
                resizeElements()
            }
        }
    }
    /**
     fieldHeight (default = 20) determines the text field height. Value will change according to the device at runtime.
     The text field width is calculated according to the space left after subtracting the image and margins.
     */
    @IBInspectable var fieldHeight : CGFloat = 20 {
        didSet {
            if designMode {
                resizeElements()
            }
        }
    }
    /**
        imageWidth (default = 21) determines the width of the image button. Value will change according to the device at runtime.
     */
    @IBInspectable var imageWidth : CGFloat = 28 {
        didSet {
            if designMode {
                resizeElements()
            }
        }
    }
    /**
     imageHeight (default = 15) determines the width of the image button. Value will change according to the device at runtime.
     */
    @IBInspectable var imageHeight : CGFloat = 20 {
        didSet {
            if designMode {
                resizeElements()
            }
        }
    }

    // Mark: Error message configurable properties
    
    /**
        errorHeight (default = 12) determines the height of the error label
     */
    @IBInspectable var errorHeight : CGFloat = 12
    /**
        errorFontSize (default = 10) determines the font size of the error label
     */
    @IBInspectable var errorFontSize : CGFloat = 10
    /**
        errorColor (default = red) determines the color of the error label text
     */
    @IBInspectable var errorColor : UIColor = UIColor.systemRed

    
    // Mark: background, border and shadow configurable properties
    
    /**
    cornerRadius (default = 5) determines the corner radius (for rounded corners) of the component - not the text field itself (for that we have the property fieldCornerRadius)
     */
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            if designMode {
                drawBoundsAndShadow()
            }
        }
    }
    /**
     borderColor (default = a kind of dark gray) determines the border color of the component
     */
    @IBInspectable var borderColor: UIColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1) {
        didSet {
            if designMode {
                drawBoundsAndShadow()
            }
        }
    }
    /**
     borderWidth (default = 05) determines the border width of the component
     */
    @IBInspectable var borderWidth: CGFloat = 0.5 {
        didSet {
            if designMode {
                drawBoundsAndShadow()
            }
        }
    }
    /**
     backgroundColor (default = white) determines the background color for the inside of the component
     */
    private var customBackgroundColor = BSColorCompat.systemBackground
    @IBInspectable override public var backgroundColor: UIColor? {
        didSet {
            customBackgroundColor = BSColorCompat.systemBackground
            //super.backgroundColor = BSColorCompat.systemBackground
        }
    }
    /**
     shadowDarkColor (default = lightGray) determines the darkest color of the component's shadow
     */
    @IBInspectable var shadowDarkColor: UIColor = UIColor.systemGray {
        didSet {
            if designMode {
                setElementAttributes()
            }
        }
    }
    /**
     shadowRadius (default = 15) determines the radius of the component's shadow (the shadow will not work if you have the property "clip to bounds" set to true)
     */
    @IBInspectable var shadowRadius: CGFloat = 15.0 {
        didSet {
            if designMode {
                setElementAttributes()
            }
        }
    }
    /**
     shadowOpacity (default = 0.5) determines the opacity the component's shadow
     */
    @IBInspectable var shadowOpacity: CGFloat = 0.5 {
        didSet {
            if designMode {
                setElementAttributes()
            }
        }
    }
    
    // MARK: Other public properties
    
    /**
     fieldBorderStyle (default = .none) determines the border type for the text field
     */
    public var fieldBorderStyle : UITextField.BorderStyle = .none
    
    
    // MARK: internal UI elements
    
    internal var textField : UITextField = UITextField()
    internal var imageButton : UIButton!
    internal var errorLabel : UILabel?
    internal var fieldCoverButton : UIButton?
    
    // MARK: private properties
    
    var shouldSetupConstraints = true
    var designMode = false
    
    var actualFieldFontSize : CGFloat = 17
    var actualLeftMargin : CGFloat = 16
    var actualMiddleMargin : CGFloat = 8
    var actualRightMargin : CGFloat = 16
    var actualFieldHeight : CGFloat = 20
    var actualImageWidth : CGFloat = 21
    var actualImageHeight : CGFloat = 15
    var actualErrorHeight : CGFloat = 12
    var actualErrorFontSize : CGFloat = 10


    // MARK: public functions
    
    /**
     Returns the text in the field
    */
    public func getValue() -> String! {
        
        return textField.text
    }
    
    /**
    Sets the text in the field
     */
    public func setValue(_ newValue: String!) {
        
        textField.text = newValue
    }
    
    /*
    Shows the given text as an error below the text field
    */
    public func showError(_ errorText : String?) {
        
        if errorLabel == nil {
            self.errorLabel = UILabel()
            errorLabel?.accessibilityIdentifier = "ErrorLabel"
            initErrorLabel(errorLabel: errorLabel)
        }
        showErrorByField(field: self.textField, errorLabel: errorLabel, errorText: errorText)
    }
    
    /*
     Hides the error below the text field
     */
    public func hideError() {
        
        hideErrorByField(field: textField, errorLabel: errorLabel)
    }
    
    /*
     Shows the given text as an error below the given text field
     [For inheriting components that may have mnore than one text field, this specifies the field under which we display the error, as well as the error text.]
    */
    public func showErrorByField(field: UITextField!, errorLabel: UILabel?, errorText: String?) {
        
        field.textColor = self.errorColor
        if let errorLabel = errorLabel {
            if let errorText = errorText {
                errorLabel.text = errorText
                errorLabel.isHidden = false
                resizeError()
            }
        }
    }
    
    /*
     Hide the error below the given text field
     [For inheriting components that may have mnore than one text field, this specifies the field]
     */
    public func hideErrorByField(field: UITextField?, errorLabel: UILabel?) {
        
        if let errorLabel = errorLabel {
            errorLabel.isHidden = true
        }
        if let field = field {
            field.textColor = self.textColor
        }
    }
    
    public func dismissKeyboard() {
        
        if self.textField.isFirstResponder {
            self.textField.resignFirstResponder()
        }
    }
    
    // MARK: TextFieldDelegate functions

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    // MARK: UIView override functions
    
    // called at design time (StoryBoard) to init the component
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        designMode = true
        buildElements()
    }
    
    // called at runtime to init the component
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        designMode = false
        buildElements()
        /*NotificationCenter.default.addObserver(
            self,
            selector:  #selector(deviceDidRotate),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )*/
    }

    override public func draw(_ rect: CGRect) {
        
        _ = initRatios()
        resizeElements()
        drawBoundsAndShadow()
    }
    
    override public func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        setElementAttributes()
        resizeElements()
    }
    
    override public func updateConstraints() {
        
        if (shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
    
    // MARK: Internal/private functions
    
    /**
    Called by observer to re-draw after devioce rotation.
    */
    /*internal func deviceDidRotate() {
        draw(CGRect(x: 0, y: 0, width: 0, height: 0))
    }*/
    
    /**
    Handle drawing of the component's round corners and shadow
    */
    private func drawBoundsAndShadow() {
        
        // set rounded corners
        
        //customBackgroundColor.setFill()
        //UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
        
        // set shadow
        
        let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
        borderColor.setStroke()
        borderPath.lineWidth = borderWidth
        borderPath.stroke()
        UIColor.clear.setStroke()
        //self.layer.shouldRasterize = true
    }
    
    /**
    Calculate the horizontal and vertical ratios between the design width and height and the actual component width and height (which can be affected by the device and constraints) - then re-calculate the actual sizes of the inner components - text field, image - and the margins according to these ratios.
    */
    internal func initRatios() -> (hRatio: CGFloat, vRatio: CGFloat) {
                
        // To make sure we fit in the givemn size, we set all widths and horizontal margins
        // according to this ratio.
        let hRatio = self.frame.width / self.designWidth
        let vRatio = self.frame.height / self.designHeight
        
        actualRightMargin = (rightMargin * hRatio).rounded()
        actualLeftMargin = (leftMargin * hRatio).rounded()
        actualMiddleMargin = (middleMargin * hRatio).rounded()
        
        // image ratio should be kept within itself
        let imageRatio = min(hRatio, vRatio)
        actualImageWidth = (imageWidth * imageRatio).rounded()
        actualImageHeight = (imageHeight * imageRatio).rounded()
        
        actualFieldFontSize = (fieldFontSize * vRatio).rounded()
        actualFieldHeight = (fieldHeight * vRatio).rounded()
        actualErrorFontSize = (errorFontSize*vRatio).rounded()
        actualErrorHeight = (errorHeight * vRatio).rounded()
        
        //NSLog("width=\(self.frame.width), hRatio=\(hRatio), height=\(self.frame.height), vRatio=\(vRatio)")
        
        return (hRatio: hRatio, vRatio: vRatio)
    }
    
    /**
    Create the UI elements for the component (text field and image for this base implementation).
    This code needs to run only once (as opposed to sizes that may change).
    */
    internal func buildElements() {

        textField.accessibilityIdentifier = "TextField"
        self.addSubview(textField)
        
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        textField.delegate = self
        
        self.imageButton = UIButton(type: UIButton.ButtonType.custom)
        imageButton.accessibilityIdentifier = "ImageButton"
        self.addSubview(imageButton)
        imageButton.addTarget(self, action: #selector(BSBaseTextInput.imageTouchUpInside(_:)), for: .touchUpInside)
        imageButton.contentVerticalAlignment = .fill
        imageButton.contentHorizontalAlignment = .fill
        
        setElementAttributes()
    }
    
    /**
    Set the keyboard type for the text field
     */
    internal func setKeyboardType() {
        
        textField.keyboardType = fieldKeyboardType
        if fieldKeyboardType == .numberPad || fieldKeyboardType == .phonePad {
            self.setNumericKeyboard()
        } else {
            self.removeNumericKeyboard()
        }
    }
    
    /**
    set the attributes that are not affected by resizing
     */
    internal func setElementAttributes() {
        
//        // set stuff for shadow
//        layer.shadowColor = shadowDarkColor.cgColor
//        layer.shadowOffset = CGSize.zero
//        layer.shadowRadius = shadowRadius
//        layer.shadowOpacity = Float(shadowOpacity)
//        super.backgroundColor = BSColorCompat.systemBackground
//
//        setKeyboardType()
//        //textField.backgroundColor = self.backgroundColor
//        textField.textColor = self.textColor
//        textField.returnKeyType = UIReturnKeyType.done
//
//        textField.borderStyle = fieldBorderStyle
//        textField.layer.borderWidth = fieldBorderWidth
//
////        if let fieldBorderColor = self.fieldBorderColor {
////            self.textField.layer.borderColor = fieldBorderColor.cgColor
////        }
    }
    
    /**
     set the font for the text field
     */
    internal func setFont() {
        
        if let fieldFont : UIFont = UIFont(name: self.fontName, size: actualFieldFontSize) {
            textField.font = fieldFont
        }
    }
    
    /**
     Set the width/height/position/font-size and all that stuff we change according to the ratios; this code may be called many times.
     */
    internal func resizeElements() {
        
        if designMode {
            // re-calculate the actual sizes
            _ = initRatios()
        }
        
        setFont()
        
        if image == nil {
            imageButton.isHidden = true
        } else {
            imageButton.isHidden = false
            imageButton.setImage(image, for: UIControl.State.normal)
            imageButton.frame = getImageRect()
        }
        
        let actualFieldWidth : CGFloat = getFieldWidth()
        let fieldX = getFieldX()
        let fieldY = (self.frame.height-actualFieldHeight)/2
        textField.frame = CGRect(x: fieldX, y: fieldY, width: actualFieldWidth, height: actualFieldHeight)
        
        adjustCoverButton()
        resizeError()
        
        if fieldCornerRadius != 0 {
            self.textField.layer.cornerRadius = fieldCornerRadius
        }
    }
    
    internal func getCoverButtonWidth() -> CGFloat {
        return getFieldWidth()
    }
    
    internal func adjustCoverButton() {
        
        buildFieldCoverButton()
        if let fieldCoverButton = fieldCoverButton {
            
            let actualFieldWidth = getCoverButtonWidth()
            let fieldX = textField.frame.minX
            let fieldY = textField.frame.minY
            fieldCoverButton.frame = CGRect(x: fieldX - 5, y: fieldY - 5, width: actualFieldWidth + 10, height: actualFieldHeight + 10)
            
            fieldCoverButton.alpha = 0.1
            textField.isUserInteractionEnabled = self.isEditable
        }
    }
    
    /**
     Return the position of the image inside the component
    */
    internal func getImageRect() -> CGRect {
        return CGRect(x: self.frame.width-actualRightMargin-actualImageWidth, y: (self.frame.height-actualImageHeight)/2, width: actualImageWidth, height: actualImageHeight)
    }
    
    /**
     Return the text field width (what is left after subtracting the margins and image width from the actual width)
     */
    internal func getFieldWidth() -> CGFloat {
        
        let actualFieldWidth : CGFloat = self.frame.width - (image != nil ? actualImageWidth : 0) - actualLeftMargin - actualRightMargin - actualMiddleMargin
        return actualFieldWidth
    }
    
    /**
     Return the X position of the text field width 
     */
    internal func getFieldX() -> CGFloat {
        
        return actualLeftMargin
    }
    
    /**
     Create the clear button that covers the text field if it is marked as isEditable = false
     */
    private func buildFieldCoverButton() {
        
        if !self.isEditable && fieldCoverButton == nil {
            fieldCoverButton = UIButton()
            fieldCoverButton?.accessibilityIdentifier = "FieldCoverButton"
            if let fieldCoverButton = fieldCoverButton {
                fieldCoverButton.backgroundColor = BSColorCompat.systemBackground
                self.addSubview(fieldCoverButton)
                fieldCoverButton.addTarget(self, action: #selector(BSBaseTextInput.fieldCoverButtonTouchUpInside(_:)), for: .touchUpInside)
            }
        }
    }
    
    /**
     Init the label for the error
     */
    internal func initErrorLabel(errorLabel: UILabel!) {
        
        if let errorLabel = errorLabel {
            self.addSubview(errorLabel)
            errorLabel.backgroundColor = BSColorCompat.systemBackground
            errorLabel.textColor = self.errorColor
            errorLabel.isHidden = true
            errorLabel.textAlignment = .left
        }
    }
    
    /**
     Resize and re-locate the label for the error
     */
    internal func resizeError() {
        if let errorLabel = errorLabel {
            if !errorLabel.isHidden {
                if let labelFont : UIFont = UIFont(name: self.fontName, size: actualErrorFontSize) {
                    errorLabel.font = labelFont
                }
                errorLabel.frame = CGRect(x: textField.frame.minX, y: self.frame.height-actualErrorHeight, width: textField.frame.width, height: actualErrorHeight)
            }
        }
    }
    
    
    // MARK:- ---> Action methods
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        hideError()
        sendActions(for: UIControl.Event.editingDidBegin)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        sendActions(for: UIControl.Event.editingDidEnd)
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        
        sendActions(for: UIControl.Event.editingChanged)
    }
    
    @objc func imageTouchUpInside(_ sender: Any) {
        
        sendActions(for: UIControl.Event.touchUpInside)
    }
    
    @objc func fieldCoverButtonTouchUpInside(_ sender: Any) {
        
        sendActions(for: UIControl.Event.touchUpInside)
    }

    // MARK: Numeric Keyboard "done" button enhancement
    
    internal func createDoneButtonForKeyboard() -> UIToolbar {
        
        let doneButtonText = BSLocalizedStrings.getString(BSLocalizedString.Keyboard_Done_Button_Text)
        let viewForDoneButtonOnKeyboard = UIToolbar()
        viewForDoneButtonOnKeyboard.sizeToFit()
        let btnDoneOnKeyboard = UIBarButtonItem(title: doneButtonText, style: .plain, target: self, action: #selector(self.doneBtnfromKeyboardClicked))
        viewForDoneButtonOnKeyboard.semanticContentAttribute = .forceRightToLeft
        viewForDoneButtonOnKeyboard.items = [btnDoneOnKeyboard]
        return viewForDoneButtonOnKeyboard
     }

    @IBAction func doneBtnfromKeyboardClicked (sender: Any) {
        //Hide Keyboard by endEditing
        self.endEditing(true)
    }
    
    internal func setNumericKeyboard() {
        
        let viewForDoneButtonOnKeyboard = createDoneButtonForKeyboard()
        self.textField.inputAccessoryView = viewForDoneButtonOnKeyboard
    }
    
    internal func removeNumericKeyboard() {
        
        self.textField.inputAccessoryView = nil
    }

}
