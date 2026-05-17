//
//  BSBaseBoxWithShadowView.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 02/11/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

@IBDesignable
public class BSBaseBoxWithShadowView: UIControl {
    
    // MARK: Configurable properties
    

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
    @IBInspectable var borderColor: UIColor = BSColorCompat.systemGray2 {
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
    private var customBackgroundColor = BSColorCompat.secondarySystemBackground
    @IBInspectable override public var backgroundColor: UIColor? {
        didSet {
            customBackgroundColor = backgroundColor!
            super.backgroundColor = BSColorCompat.secondarySystemBackground
        }
    }
    
    /**
     shadowDarkColor (default = lightGray) determines the darkest color of the component's shadow
     */
    @IBInspectable var shadowDarkColor: UIColor = BSColorCompat.tertiarySystemBackground {
        didSet {
            if designMode {
                setShadowAttributes()
            }
        }
    }
    /**
     shadowRadius (default = 15) determines the radius of the component's shadow (the shadow will not work if you have the property "clip to bounds" set to true)
     */
    @IBInspectable var shadowRadius: CGFloat = 10.0 {
        didSet {
            if designMode {
                setShadowAttributes()
            }
        }
    }
    /**
     shadowOpacity (default = 0.5) determines the opacity the component's shadow
     */
    @IBInspectable var shadowOpacity: CGFloat = 0.8 {
        didSet {
            if designMode {
                setShadowAttributes()
            }
        }
    }
    
    // MARK: Other public properties
    
    
    // MARK: private properties
    
    var shouldSetupConstraints = true
    var designMode = false
    
    
    // MARK: UIView override functions
    
    // called at design time (StoryBoard) to init the component
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        designMode = true
        setShadowAttributes()
    }
    
    // called at runtime to init the component
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        designMode = false
        setShadowAttributes()
        /*NotificationCenter.default.addObserver(
         self,
         selector:  #selector(deviceDidRotate),
         name: .UIDeviceOrientationDidChange,
         object: nil
         )*/
    }
    
    override public func draw(_ rect: CGRect) {
        
        drawBoundsAndShadow()
    }
    
    override public func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        setShadowAttributes()
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
        
        customBackgroundColor.setFill()
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
        
        // set shadow
        
        let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
        borderColor.setStroke()
        borderPath.lineWidth = borderWidth
        borderPath.stroke()
        //UIColor.clear.setStroke()
        //self.layer.shouldRasterize = true
    }
    
    /**
     set the attributes that are not affected by resizing
     */
    internal func setShadowAttributes() {
        
        // set stuff for shadow
        layer.shadowColor = shadowDarkColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)//CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = Float(shadowOpacity)
        super.backgroundColor = BSColorCompat.systemBackground
    }
    
//    override public func layoutSubviews() {
//        super.layoutSubviews()
//        setShadowAttributes()
//    }

    
}
