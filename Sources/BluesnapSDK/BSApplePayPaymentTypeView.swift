//
//  BSApplePayPaymentTypeView.swift
//  BluesnapSDK
//
//  Created by sivan on 30/08/2020.
//  Copyright © 2020 Bluesnap. All rights reserved.
//

import Foundation
import PassKit

@IBDesignable
class BSApplePayPaymentTypeView: BSPaymentTypeView {
    
    // MARK: UIView override functions
    
    // called at design time (StoryBoard) to init the component
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // Temporary solution for Dark Mode. Will change paymentButtonStyle to .automatic in iOS 14
        if self.traitCollection.userInterfaceStyle == .light {
            // User Interface is Light
            imageButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        } else {
            // User Interface is Dark
            imageButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .white)
        }
        buildElements()
    }
    
    // called at runtime to init the component
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        // Temporary solution for Dark Mode. Will change paymentButtonStyle to .automatic in iOS 14
        if self.traitCollection.userInterfaceStyle == .light {
            // User Interface is Light
            imageButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        } else {
            // User Interface is Dark
            imageButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .white)
        }
        buildElements()
    }
    
    internal override func setImageButtom() {
    }

}

