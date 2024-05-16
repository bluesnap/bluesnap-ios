//
// Created by Roy Biber on 2018-12-30.
// Copyright (c) 2018 Bluesnap. All rights reserved.
//

import Foundation
import UIKit

class BSCreatePaymentViewController: BSStartViewController {
    private var inNavigationController: UINavigationController = UINavigationController()

    func start(inNavigationController: UINavigationController!) throws {
        self.inNavigationController = inNavigationController
        self.supportedPaymentMethods = BSApiManager.supportedPaymentMethods

        // Hide/show the buttons and position them automatically
        showPayPal = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.PayPal, supportedPaymentMethods: supportedPaymentMethods)
        showApplePay = BlueSnapSDK.applePaySupported(supportedPaymentMethods: supportedPaymentMethods, supportedNetworks: BlueSnapSDK.applePaySupportedNetworks).canMakePayments

        let getChosenPaymentMethod = try BSApiManager.shopper?.getChosenPaymentMethod()
        if (getChosenPaymentMethod?.chosenPaymentMethodType == BSPaymentType.CreditCard.rawValue) {
            // return to merchant screen
            let purchaseDetails = BSExistingCcSdkResult(sdkRequestBase: BlueSnapSDK.sdkRequestBase!, shopper: BSApiManager.shopper, existingCcDetails: getChosenPaymentMethod?.creditCardInfo)
            // execute callback
            BlueSnapSDK.sdkRequestBase?.purchaseFunc(purchaseDetails)
        } else if getChosenPaymentMethod?.chosenPaymentMethodType == BSPaymentType.ApplePay.rawValue {
            applePayClick(self.inNavigationController)
        } else if getChosenPaymentMethod?.chosenPaymentMethodType == BSPaymentType.PayPal.rawValue {
            payPalClicked(self.inNavigationController)
        }
    }

    override func paypalUrlListener(url: String) -> Bool {
        if BSPaypalHandler.isPayPalProceedUrl(url: url) {
            // paypal success!
            BSPaypalHandler.parsePayPalResultDetails(url: url, purchaseDetails: self.payPalPurchaseDetails)

            // return to merchant screen
            _ = self.inNavigationController.popViewController(animated: false)

            // execute callback
            BlueSnapSDK.sdkRequestBase?.purchaseFunc(self.payPalPurchaseDetails)
            return false

        } else if BSPaypalHandler.isPayPalCancelUrl(url: url) {
            // PayPal cancel URL detected - close web screen
            _ = self.inNavigationController.popViewController(animated: false)
            return false

        }
        return true
    }

}

