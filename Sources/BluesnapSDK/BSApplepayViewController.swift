//
// Created by oz on 15/06/2017.
// Copyright (c) 2017 Bluesnap. All rights reserved.
//

import Foundation

import UIKit
import PassKit


//TODO: we can split the delagate from the controller
extension BSStartViewController : PaymentOperationDelegate {


    func applePayPressed(_ sender: Any, completion: @escaping (BSErrors?) -> Void) {

        let InternalQueue = OperationQueue();

        if let sdkRequestBase = BlueSnapSDK.sdkRequestBase {
            let priceDetails = sdkRequestBase.priceDetails!
            let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(floatLiteral: priceDetails.taxAmount.doubleValue), type: .final)
            let payLineContent = "\(sdkRequestBase.applePayCustomizePayLine ?? BSApiManager.merchantName ?? "Payment")"
            let total = PKPaymentSummaryItem(label: payLineContent, amount: NSDecimalNumber(floatLiteral: priceDetails.amount.doubleValue), type: .final)
            
            paymentSummaryItems = [tax, total];
            
            let pkPaymentRequest = PKPaymentRequest()
            pkPaymentRequest.paymentSummaryItems = paymentSummaryItems;
            pkPaymentRequest.merchantIdentifier = BSApplePayConfiguration.getIdentifier()
            pkPaymentRequest.merchantCapabilities = .capability3DS
            // The merchant's ISO country code.
            pkPaymentRequest.countryCode = "US"
            pkPaymentRequest.currencyCode = priceDetails.currency
            
            if sdkRequestBase.shopperConfiguration.withShipping {
//                pkPaymentRequest.requiredShippingAddressFields = [.phone, .postalAddress, .name]
                pkPaymentRequest.requiredShippingAddressFields = [.postalAddress, .name]
            }
            // even without full billing we need zip code, so we need to ask for postal address...
            pkPaymentRequest.requiredBillingAddressFields = [.name, .postalAddress]
            if sdkRequestBase.shopperConfiguration.withEmail {
                pkPaymentRequest.requiredBillingAddressFields.insert(.email)
            }
            
            // todo: populate from merchant settings
            pkPaymentRequest.supportedNetworks = [
                .amex,
                .discover,
                .masterCard,
                .visa
            ]


            // set up the operation with the payment request
            let paymentOperation: PaymentOperation =  PaymentOperation(request: pkPaymentRequest,targetViewController: self, delegate: self,  completion: completion);
            paymentOperation.completionBlock = {[weak op = paymentOperation] in
                NSLog("PK payment completion")
                    completion(op?.error)
            }

            InternalQueue.addOperation(paymentOperation);
        }
    }

    func setupPressed(sender: AnyObject) {
        let passLibrary = PKPassLibrary();
        passLibrary.openPaymentSetup();
    }

    func validate(payment: PKPayment, completion: @escaping (PaymentValidationResult) -> Void) {
        DispatchQueue.main.async {
            completion(.valid);
       }
    }

    func send(paymentInformation: BSApplePayInfo, completion: @escaping (BSErrors?) -> Void) {
        if let jsonData = try? String(data: paymentInformation.toJSON(), encoding: .utf8)!.data(using: String.Encoding.utf8)!.base64EncodedString() {

            //print(String(data: paymentInformation.toJSON(), encoding: .utf8)!)
            let tokenizeRequest = BSTokenizeRequest()
            tokenizeRequest.paymentDetails = BSTokenizeApplePayDetails(applePayToken: jsonData)
            BSApiManager.submitTokenizedDetails(tokenizeRequest: tokenizeRequest, completion: { (result, error) in
                if let error = error {
                        completion(error)
                    debugPrint(error.description())
                    return
                }
                    completion(nil) // no result from BS on 200
            }
            )
        } else {
            NSLog("PaymentInformation parse error")
            //DispatchQueue.main.async {
                completion(BSErrors.applePayOperationError)
            //}
            return
        }
    }

    func didSelectPaymentMethod(method: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
        DispatchQueue.main.async {
            completion(self.paymentSummaryItems);
        }
    }
    
    func didSelectShippingContact(contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
       DispatchQueue.main.async {
            completion(.success, [], self.paymentSummaryItems);
        }
    }
}


