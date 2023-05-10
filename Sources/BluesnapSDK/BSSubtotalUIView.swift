//
//  SubtotalUIView.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 14/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

@IBDesignable
class BSSubtotalUIView: UIView {

    // MARK: public properties
    
    var subtotalAmount: Double = 10.0
    var taxAmount: Double = 2.0
    var currency: String = "USD"
    
    // MARK: private properties
    
    var shouldSetupConstraints = true
    var designMode = false
    var taxLabel : UILabel = UILabel()
    var taxValueLabel : UILabel = UILabel()
    var subtotalLabel : UILabel = UILabel()
    var subtotalValueLabel : UILabel = UILabel()
    
    // MARK: public functions
    
    public func setAmounts(subtotalAmount: Double, taxAmount: Double, currency: String) {
        self.subtotalAmount = subtotalAmount
        self.taxAmount = taxAmount
        self.currency = currency
        setElementAttributes()
    }
    
    /**
     Set the width/height/font-size of the view content; this code may be called many times.
     */
    internal func resizeElements() {
        
        let halfWidth = (self.frame.width / 2).rounded()
        let halfHeight = (self.frame.height / 2).rounded()
        
        subtotalLabel.frame = CGRect(x: 0, y: 0, width: halfWidth, height: halfHeight)
        subtotalValueLabel.frame = CGRect(x: halfWidth, y: 0, width: halfWidth, height: halfHeight)
        taxLabel.frame = CGRect(x: 0, y: halfHeight, width: halfWidth, height: halfHeight)
        taxValueLabel.frame = CGRect(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight)
        
        // for height 40 we want font size 12
        let actualFieldFontSize = (self.frame.height * 12 / 40).rounded()
        if let fieldFont : UIFont = UIFont(name: subtotalLabel.font.fontName, size: actualFieldFontSize) {
            subtotalLabel.font = fieldFont
            subtotalValueLabel.font = fieldFont
            taxLabel.font = fieldFont
            taxValueLabel.font = fieldFont
        }
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
    }
    
    override public func draw(_ rect: CGRect) {
        
        resizeElements()
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
     Create the UI elements for the component 
     This code needs to run only once (as opposed to sizes that may change).
     */
    internal func buildElements() {
        
        self.addSubview(taxLabel)
        self.addSubview(taxValueLabel)
        self.addSubview(subtotalLabel)
        self.addSubview(subtotalValueLabel)
        
        setElementAttributes()
    }
    
    
    /**
     set the attributes that are not affected by resizing
     */
    internal func setElementAttributes() {
        
        if taxAmount == 0 {
            self.isHidden = true
            return
        }
        
        subtotalLabel.text = BSLocalizedStrings.getString(BSLocalizedString.Label_Subtotal_Amount)
        taxLabel.text = BSLocalizedStrings.getString(BSLocalizedString.Label_Tax_Amount)
        
        let subTotalFormat = BSLocalizedStrings.getString(BSLocalizedString.Payment_subtotal_and_tax_format)
        let currencyCode = (currency == "USD" ? "$" : currency)
        subtotalValueLabel.text = String(format: subTotalFormat, currencyCode, CGFloat(self.subtotalAmount))
        taxValueLabel.text = String(format: subTotalFormat, currencyCode, CGFloat(taxAmount))

        subtotalLabel.textAlignment = .right
        subtotalValueLabel.textAlignment = .right
        taxLabel.textAlignment = .right
        taxValueLabel.textAlignment = .right

        //self.backgroundColor = UIColor.white
        
        subtotalLabel.textColor = BSColorCompat.label
        subtotalValueLabel.textColor = BSColorCompat.label
        taxLabel.textColor = BSColorCompat.label
        taxValueLabel.textColor = BSColorCompat.label
    }

}

