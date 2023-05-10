//
//  BSInputLine.swift
//  BluesnapSDK
//
//  Custom control with one label, one text field, one image button showing on a white
//  strip with a shadow. Inherits all the configurable properties from BSBaseTextInput.
//
//  Created by Shevie Chen on 17/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

//import UIKit
//
//@IBDesignable
//public class BSInputLine: BSBaseTextInput {
//
//    // MARK: Additional Configurable properties
//
//    /**
//     labelText (default = "Label") determines the label text
//     */
//    @IBInspectable var labelText: String = "Label" {
//        didSet {
//            label.text = labelText
//        }
//    }
//    /**
//     labelTextColor (default = darkGray) determines the label text color
//     */
//    @IBInspectable var labelTextColor: UIColor = UIColor.darkGray {
//        didSet {
//            label.textColor = labelTextColor
//        }
//    }
//    /**
//     labelBkdColor (default = clear) determines the label background color
//     */
//    @IBInspectable var labelBkdColor: UIColor = UIColor.clear {
//        didSet {
//            label.backgroundColor = labelBkdColor
//        }
//    }
//    /**
//     labelWidth (default = 104) determines the label width (value will change at runtime according to the device)
//     */
//    @IBInspectable var labelWidth : CGFloat = 104 {
//        didSet {
//            if designMode {
//                _ = initRatios()
//                resizeElements()
//            }
//        }
//    }
//
//    /**
//     labelHeight (default = 17) determines the label height (value will change at runtime according to the device)
//     */
//    @IBInspectable var labelHeight : CGFloat = 17 {
//        didSet {
//            if designMode {
//                _ = initRatios()
//                resizeElements()
//            }
//        }
//    }
//
//    /**
//     labelFontSize (default = 14) determines the label font size (value will change at runtime according to the device)
//     */
//    @IBInspectable var labelFontSize : CGFloat = 14 {
//        didSet {
//            if designMode {
//                _ = initRatios()
//                resizeElements()
//            }
//        }
//    }
//
//    
//    // MARK: private properties
//    
//    internal var label : UILabel = UILabel()
//    var actualLabelWidth : CGFloat = 104
//    var actualLabelHeight : CGFloat = 17
//    var actualLabelFontSize : CGFloat = 14
//    
//    
//    // MARK: Override functions
//    
//    override func buildElements() {
//        super.buildElements()
//        label.accessibilityIdentifier = "InputLabel"
//        self.addSubview(label)
//        self.textField.autocorrectionType = .no
//    }
//    
//    override func initRatios() -> (hRatio: CGFloat, vRatio: CGFloat) {
//        
//        let ratios = super.initRatios()
//        
//        actualLabelFontSize = (labelFontSize * ratios.vRatio).rounded()
//        actualLabelWidth = (labelWidth * ratios.hRatio).rounded()
//        actualLabelHeight = (labelHeight * ratios.vRatio).rounded()
//        
//        return ratios
//    }
//    
//    override func setElementAttributes() {
//        
//        super.setElementAttributes()
//        
//        label.backgroundColor = self.labelBkdColor
//        label.shadowColor = UIColor.clear
//        label.shadowOffset = CGSize.zero
//        label.layer.shadowRadius = 0
//        label.layer.shadowColor = UIColor.clear.cgColor
//        label.textColor = self.labelTextColor
//    }
//
//    override func resizeElements() {
//        
//        super.resizeElements()
//        
//        if let labelFont : UIFont = UIFont(name: self.fontName, size: actualLabelFontSize) {
//            label.font = labelFont
//        }
//        
//        label.frame = CGRect(x: actualLeftMargin, y: (self.frame.height-actualLabelHeight)/2, width: actualLabelWidth, height: actualLabelHeight)
//    }
//    
//    override func getFieldWidth() -> CGFloat {
//        
//        let actualFieldWidth : CGFloat = self.frame.width - actualLabelWidth - (image != nil ? actualImageWidth : 0) - actualLeftMargin - actualRightMargin - actualMiddleMargin*2
//        return actualFieldWidth
//    }
//    
//    override func getFieldX() -> CGFloat {
//        
//        let fieldX = actualLeftMargin + actualLabelWidth + actualMiddleMargin
//        return fieldX
//    }
//
//}
