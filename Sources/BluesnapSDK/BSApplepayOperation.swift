//
// Created by oz on 15/06/2017.
// Copyright (c) 2017 Bluesnap. All rights reserved.
//

import Foundation
import PassKit

open class BSApplepayOperation: Operation {

    enum State {
        case initial
        case finished
        case executing
        case canceled
    }

    var state: State = .initial {
        willSet {
            willChangeValue(forKey: "state");
        }
        didSet {
            didChangeValue(forKey: "state");
        }

    }

    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state" as NSObject]
    }

    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }

    class func keyPathsForValuesAffectingIsCancelled() -> Set<NSObject> {
        return ["state" as NSObject]
    }


    override open func start() {
        self.state = .executing;
        self.execute();
    }

    open func execute() {
        NSLog("This method should be implemented")
    }


    func finish() {
        self.state = .finished;
    }

    override open var isFinished: Bool {
        return self.state == .finished;
    }

    override open var isCancelled: Bool {
        return self.state == .canceled;
    }

    override open var isExecuting: Bool {
        return self.state == .executing;
    }
}


public enum PaymentValidationResult {
    case valid
    case invalidShippingContact
    case invalidBillingPostalAddress
    case invalidShippingPostalAddress

    fileprivate func asPKPaymentStatus() -> PKPaymentAuthorizationStatus? {
        switch self {
        case .invalidShippingContact:
            return PKPaymentAuthorizationStatus.failure;
        case .invalidBillingPostalAddress:
            return PKPaymentAuthorizationStatus.failure;
        case .invalidShippingPostalAddress:
            return PKPaymentAuthorizationStatus.failure;
        default:
            return nil;
        }
    }

}

public protocol PaymentOperationDelegate: AnyObject {
    func validate(payment: PKPayment, completion: @escaping(PaymentValidationResult) -> Void)

    func send(paymentInformation: BSApplePayInfo, completion: @escaping (BSErrors?) -> Void)

    func didSelectPaymentMethod(method: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void)

    func didSelectShippingContact(contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void);
}


public class PaymentOperation: BSApplepayOperation, PKPaymentAuthorizationViewControllerDelegate {

    public let request: PKPaymentRequest
    private var requestController: PKPaymentAuthorizationViewController!
    private var status: PKPaymentAuthorizationStatus = .failure;
    public var error: BSErrors?
    private let delegate: PaymentOperationDelegate
    private var finishCompletion: ((BSErrors?) -> Void)
    private let targetViewController : UIViewController?


    public init(request: PKPaymentRequest,targetViewController: UIViewController , delegate: PaymentOperationDelegate, completion: @escaping (BSErrors?) -> Void) {
        self.request = request
        self.finishCompletion = completion
        self.requestController = PKPaymentAuthorizationViewController(paymentRequest: request)
        self.delegate = delegate
        self.targetViewController = targetViewController

    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        NSLog("ApplePaymentAuthorizationViewController Validate")
        delegate.validate(payment: payment) {
            switch $0 {
            case .valid:
                self.delegate.send(paymentInformation: BSApplePayInfo(payment: payment)) {
                    if let error = $0 {
                        self.status = .failure;
                        self.error = error;
                    } else {
                        self.status = .success;
                    }
                    completion(self.status);
                };
            default:
                self.status = $0.asPKPaymentStatus()!;
                completion(self.status);
            }
        }
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect paymentMethod: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
        delegate.didSelectPaymentMethod(method: paymentMethod, completion: completion);
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        delegate.didSelectShippingContact(contact: contact, completion: completion);
    }

    func finish(with error: BSErrors? = nil) {
        self.error = error;
        self.finish();
    }

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        NSLog("Apple pay controller finish")
        controller.dismiss(animated: true) {
            if case .success = self.status {
                NSLog("Apple pay controller dismissm successfuly")
                self.finish();
                self.finishCompletion(nil)
            } else if self.status.rawValue > 1 {
                NSLog("Apple pay operation error \(self.status.rawValue)")
                self.finish(with: BSErrors.applePayOperationError);
            } else {
                self.finish(with: BSErrors.applePayCanceled);
            }
        };
    }

    deinit {
        NSLog("BSApplepayOperation deinint");
    }

    override public func execute() {
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: self.request.supportedNetworks) {
            self.finish(with: BSErrors.cantMakePaymentError);
        }

        self.requestController!.delegate = self;
        DispatchQueue.main.async {
            self.targetViewController?.present(self.requestController, animated: true, completion: nil) ?? {
                self.finish(with: BSErrors.unknown);
            }()
//            UIApplication.shared.keyWindow?.rootViewController?.present(self.requestController, animated: true, completion: nil) ?? {
//                self.finish(with: BSErrors.unknown);
//            }()
        }


    }


}


