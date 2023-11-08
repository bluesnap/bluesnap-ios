//
//  BSPaypalHandler.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 01/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSPaypalHandler {
    
    // MARK: Constants
    
    internal static let PAYPAL_PROCEED_URL = "https://sandbox.bluesnap.com/jsp/dev_scripts/iframeCheck/pay_pal_proceed.html"
    internal static let PAYPAL_CANCEL_URL = "https://sandbox.bluesnap.com/jsp/dev_scripts/iframeCheck/pay_pal_cancel.html"
    internal static let PAYPAL_PROD_URL = "https://www.paypal.com/";
    internal static let PAYPAL_SAND_URL = "https://www.sandbox.paypal.com/"
    
    
    internal static var paypalURL: String = ""
    
    static func getPayPalToken() -> String {
        return paypalURL
    }

    static func clearPayPalToken() {
        paypalURL = ""
    }
    
    static func isPayPalProceedUrl(url: String) -> Bool {
        return BSStringUtils.startsWith(theString: url, subString: PAYPAL_PROCEED_URL)
    }
    
    static func isPayPalCancelUrl(url: String) -> Bool {
        return BSStringUtils.startsWith(theString: url, subString: PAYPAL_CANCEL_URL)
    }
    
    static func parsePayPalResultDetails(url: String, purchaseDetails: BSPayPalSdkResult) {
        
        if let invoiceId = URLComponents(string: url)?.queryItems?.first(where: { $0.name == "INVOICE_ID"})?.value {
            purchaseDetails.payPalInvoiceId = invoiceId
        }
    }
}
