//
//  BSPaymentTypeView.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 02/11/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BSPaymentTypeView: BSBaseBoxWithShadowView {
    
    /**
     icon image to be displayed at the center
     */
    @IBInspectable var iconImage: UIImage? {
        didSet {
            setImageButtom()
        }
    }
    
    /**
     icon image width
     */
    @IBInspectable var iconWidth: CGFloat = 35 {
        didSet {
            setElementAttributes()
        }
    }
    
    /**
     icon image height
     */
    @IBInspectable var iconHeight: CGFloat = 21 {
        didSet {
            setElementAttributes()
        }
    }
    
    // MARK: internal UI elements
    
    internal var imageButton : UIButton = UIButton(type: UIButton.ButtonType.custom)
    
    
    // MARK: UIView override functions
    
    // called at design time (StoryBoard) to init the component
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //designMode = true
        buildElements()
    }
    
    // called at runtime to init the component
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        //designMode = false
        buildElements()
    }
    
    internal func buildElements() {
        
        if let iconImage = iconImage {
            setImageButtom()
        }
        self.addSubview(self.imageButton)
        //setElementAttributes()
        imageButton.addTarget(self, action: #selector(BSPaymentTypeView.touchUpInside(_:)), for: .touchUpInside)
    }
    
    internal func setImageButtom() {
        self.imageButton.setImage(iconImage, for: .normal)
    }
    
    /**
     set the attributes that are not affected by resizing
     */
    internal func setElementAttributes() {
        
        let centerX : CGFloat = (self.frame.width - iconWidth) / 2.0
        let centerY : CGFloat = (self.frame.height - iconHeight) / 2.0
        imageButton.frame = CGRect(x: centerX, y: centerY, width: iconWidth, height:iconHeight)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        setElementAttributes()
    }
    
    /**
     Propagate the touch up inside action to the one defined on the view
     */
    @objc func touchUpInside(_ sender: Any) {
        
        sendActions(for: UIControl.Event.touchUpInside)
    }

}
