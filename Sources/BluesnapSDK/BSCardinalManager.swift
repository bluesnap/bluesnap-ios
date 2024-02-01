import Foundation
import CardinalMobile


public class BSCardinalManager: NSObject {

    internal static let SUPPORTED_CARD_VERSION = "2"
    private var session : CardinalSession!
    private var cardinalToken : String?
    private var cardinalError: Bool = false
    private var threeDSAuthResult: String = ThreeDSManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue
    public static var instance: BSCardinalManager = BSCardinalManager()
    
    override private init(){}
    
    internal func setCardinalJWT(cardinalToken: String?) {
        // reset cardinalError and threeDSAuthResult for singleton use
        setCardinalError(cardinalError: false)
        setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.AUTHENTICATION_UNAVAILABLE.rawValue)
        
        self.cardinalToken = cardinalToken
    }
    
    //Setup can be called in viewDidLoad
    internal func configureCardinal(isProduction: Bool) {
        if (!is3DSecureEnabled()){ // 3DS is disabled in merchant configuration
            NSLog("skipping since 3D Secure is disabled")
            return
        }
        
        
            
            self.session = CardinalSession()
            
            let config = CardinalSessionConfiguration()
            
            if (isProduction) {
                
                config.deploymentEnvironment = .production
            } else  {
                
                config.deploymentEnvironment = .staging
            }
            config.uiType = .both
            
        let renderType = [CardinalSessionRenderTypeOTP, CardinalSessionRenderTypeOOB, CardinalSessionRenderTypeSingleSelect, CardinalSessionRenderTypeMultiSelect]
            config.renderType = renderType
            config.enableDFSync = true
            config.collectLogs = !isProduction // don't collect logs on production
            self.session.configure(config)
            let warrnings = self.session.getWarnings();
            NSLog("Cardinal session setup warrnings \(warrnings)");
            for w in warrnings {
                NSLog("warrning  \(w.warningID ?? "No code" )  \(w.message ?? "No message") ");
            }
    }
    
    internal func setupCardinal(_ completion: @escaping () -> Void) {
        if (!is3DSecureEnabled()){ // 3DS is disabled in merchant configuration
            NSLog("skipping since 3D Secure is disabled")
            completion()
            return
        }
        
        self.session.setup(jwtString: self.cardinalToken!,
                      completed: { sessionID in
                        NSLog("cardinal setup complete")
                        completion()
                        },
                      
                      validated: { validateResponse in
                        // As defined by payments , in case of an error we continue with the flow, server side might fail TX
                        NSLog("Cardinal setup failed \(validateResponse.errorNumber) \(validateResponse.errorDescription) ");
                        self.setCardinalError(cardinalError: true)
                        completion()
                        })
        
    }
    
    public func authWith3DS(currency: String, amount: String, creditCardNumber: String? = nil, _ completion: @escaping (String, BSErrors?) -> Void) {
        if (!is3DSecureEnabled() || isCardinalError()){ // 3DS is disabled in merchant configuration or error occurred
            NSLog("skipping since 3D Secure is disabled or cardinal error")
            completion(threeDSAuthResult, nil)
            return
        }

        BSApiManager.requestAuthWith3ds(currency: currency, amount: amount, cardinalToken: cardinalToken!, completion: { response, error in
            if (error != nil) {
                NSLog("BS Server Error in 3DS Auth API call: \(String(describing: error))")
                self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
                completion(self.threeDSAuthResult, error)
            }
        
            if let response = response, let enrollmentStatus = response.enrollmentStatus, let threeDSVersion = response.threeDSVersion {
                if (enrollmentStatus == "CHALLENGE_REQUIRED") {
                    // verifying 3DS version
                    let index = threeDSVersion.index(threeDSVersion.startIndex, offsetBy: 1)
                    let firstChar = threeDSVersion[..<index]
                    
                    if (!(firstChar == BSCardinalManager.SUPPORTED_CARD_VERSION)) {
                        self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.CARD_NOT_SUPPORTED.rawValue);
                        completion(self.threeDSAuthResult, nil)
                    } else { // call process to trigger cardinal challenge
                        self.process(response: response ,creditCardNumber: creditCardNumber, completion: completion)
                    }
                    
                } else { // populate Enrollment Status as 3DS result
                    self.setThreeDSAuthResult(threeDSAuthResult: enrollmentStatus)
                    completion(self.threeDSAuthResult, nil)
                }
            } else if let response = response, let enrollmentStatus = response.enrollmentStatus {
                self.setThreeDSAuthResult(threeDSAuthResult: enrollmentStatus);
                
                NSLog("Error in getting response from 3DS Auth API call")
                completion(self.threeDSAuthResult, nil)
            } else {
           
                self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
                NSLog("Error in getting response from 3DS Auth API call")
                completion(self.threeDSAuthResult, nil)
            }

        })
        
    }
    
    private class validationDelegate: CardinalValidationDelegate {
        
        var completion :  (String, BSErrors?) -> Void
        
        init (_ completion: @escaping (String, BSErrors?) -> Void) {
            self.completion = completion
        }
        
        func cardinalSession(cardinalSession session: CardinalSession!, stepUpValidated validateResponse: CardinalResponse!, serverJWT: String!) {
            
            switch validateResponse.actionCode {
            case .success,
                 .noAction:
                BSCardinalManager.instance.processCardinalResult(resultJwt: serverJWT, completion: self.completion)
                break
                
            case .failure:
                BSCardinalManager.instance.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.AUTHENTICATION_FAILED.rawValue)
                completion(BSCardinalManager.instance.getThreeDSAuthResult(), nil)
                break
                
            case .error:
                BSCardinalManager.instance.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue)
                completion(BSCardinalManager.instance.getThreeDSAuthResult(), nil)
                break
                
            case .cancel:
                BSCardinalManager.instance.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.AUTHENTICATION_CANCELED.rawValue)
                completion(BSCardinalManager.instance.getThreeDSAuthResult(), nil)
                break
            case .timeout:
                BSCardinalManager.instance.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue)
                completion(BSCardinalManager.instance.getThreeDSAuthResult(), nil)
                break
                
            }
            
        }
        
    }
    
    private func process(response: BS3DSAuthResponse?, creditCardNumber: String?, completion: @escaping (String, BSErrors?) -> Void) {
        let delegate : validationDelegate = validationDelegate(completion)

        
        if let authResponse = response {
            
            setupCardinal {
                if let creditCardNumber = creditCardNumber { // new card mode - passing the cc number to cardinal for processing
                    
                    self.session.processBin(creditCardNumber, completed: {
                        DispatchQueue.main.async {
                            self.session.continueWith(transactionId: authResponse.transactionId!, payload: authResponse.payload!, validationDelegate:
                                delegate)
                        }
                    })
                } else { // vaulted card - skipping straight to cardinal challenge
                    self.session.continueWith(transactionId: authResponse.transactionId!, payload: authResponse.payload!, validationDelegate:
                    delegate)
                }
            }

        }
    }
    
    private func processCardinalResult(resultJwt: String, completion: @escaping (String, BSErrors?) -> Void) {
        
        BSApiManager.processCardinalResult(cardinalToken: cardinalToken!, resultJwt: resultJwt, completion: { response, error in
            if (error != nil) {
                NSLog("BS Server Error in 3DS process result API call: \(String(describing: error))")
                self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
                completion(self.threeDSAuthResult, error)
            }
            
            if let response = response, let authResult = response.authResult {
                self.setThreeDSAuthResult(threeDSAuthResult: authResult)
                completion(self.threeDSAuthResult, nil)
                
            } else {
                NSLog("Error in getting response from 3DS process result API call")
                self.setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
                completion(self.threeDSAuthResult, nil)
            }
            
        })
        
    }
    
    // Missing cardinal token - 3DS is disabled in merchant configuration
    private func is3DSecureEnabled() -> Bool {
        return (cardinalToken != nil)
    }
    
    private func isCardinalError() -> Bool {
        return cardinalError
    }
    
    private func setCardinalError(cardinalError: Bool) {
        if (cardinalError) {
            setThreeDSAuthResult(threeDSAuthResult: ThreeDSManagerResponse.THREE_DS_ERROR.rawValue);
        }
        self.cardinalError = cardinalError;
    }
    
    // for internal use only- getting the 3DS result for populating the sdkResult 
    public func getThreeDSAuthResult() -> String {
        return threeDSAuthResult
    }
    
    fileprivate func setThreeDSAuthResult(threeDSAuthResult: String) {
        self.threeDSAuthResult = threeDSAuthResult
    }
    
}


