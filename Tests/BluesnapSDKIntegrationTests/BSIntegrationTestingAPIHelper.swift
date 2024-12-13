//
//  BSIntegrationTestingAPIService.swift
//  BluesnapSDKIntegrationTests
//
//  Created by Sivani on 23/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import Foundation
import XCTest

@testable import BluesnapSDK

class BSIntegrationTestingAPIHelper {
    static var bsAPIUser: String {
        guard let credentialsURL = Bundle.module.url(forResource: "credentials", withExtension: "plist"),
              let dict = NSDictionary(contentsOfFile: credentialsURL.relativePath) as? Dictionary<String, String>
        else {
            return "USER_UNDEFINED"
        }
        
        return dict["BsAPIUser"]!
        
        //return (Bundle(for: BSApiManager.self).object(forInfoDictionaryKey: "BsAPIUser") as? String) ?? "USER_UNDEFINED"
        //return (Bundle.module.object)
    }
    
    static var bsAPIPassword: String {
        //return (Bundle(for: BSApiManager.self).object(forInfoDictionaryKey: "BsAPIPassword") as? String) ?? "PASSWORD_UNDEFINED"
        
        guard let credentialsURL = Bundle.module.url(forResource: "credentials", withExtension: "plist"),
              let dict = NSDictionary(contentsOfFile: credentialsURL.relativePath) as? Dictionary<String, String>
        else {
            return "USER_UNDEFINED"
        }
        
        return dict["BsAPIPassword"]!
    }
    
    internal static let BS_SANDBOX_TEST_USER = bsAPIUser
    internal static let BS_SANDBOX_TEST_PASSWORD = bsAPIPassword
    
    static func createToken(shopperId: Int?, completion: @escaping (BSToken?, BSErrors?) -> Void) {
        createSandboxBSToken(shopperId: shopperId, completion: { bsToken, bsError in
            
            do {
                try BlueSnapSDK.setBsToken(bsToken: bsToken)
                XCTAssertNil(bsError)
                XCTAssertNotNil(bsToken)
                completion(bsToken, bsError)
            } catch {
                NSLog("Unexpected error: \(error).")
            }
        })
        
    }
    
    static func createToken(completion: @escaping (BSToken?, BSErrors?) -> Void) {
        createToken(shopperId: nil, completion: completion)
    }
    
    /**
     Get BlueSnap Token from BlueSnap server
     Normally you will not do this from the app.
     
     - parameters:
     - user: username
     - password: password
     - completion: callback function for after the token is created; recfeives optional token and optional error
     */
    static func createSandboxBSToken(shopperId: Int?, completion: @escaping (BSToken?, BSErrors?) -> Void) {
        
        let domain: String = BSApiManager.BS_SANDBOX_DOMAIN
        
        // create request
        var urlStr = domain + "services/2/payment-fields-tokens"
        if let shopperId = shopperId {
            urlStr = urlStr + "?shopperId=\(shopperId)"
        }
        let url = NSURL(string: urlStr)!
        var request = getURLRequest(urlStr: urlStr, httpMethod: "POST", contentType: "text/xml")
        printAsCurl(request: request as URLRequest)

        
        // fire request
        
        var result: BSToken?
        var resultError: BSErrors?
        NSLog("BlueSnap; createSandboxBSToken")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            NSLog("BlueSnap; createSandboxBSToken completion")
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting BSToken - \(errorType). Error: \(error.localizedDescription)")
                resultError = .unknown
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode: Int = (httpResponse?.statusCode) {
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result = extractTokenFromResponse(httpResponse: httpResponse)
                        if let result = result {
                            NSLog("createSandboxBSToken result")
                        } else {
                            resultError = .unknown
                        }
                    } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
                        NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
                        resultError = .invalidInput
                    } else {
                        resultError = .unknown
                        NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
                    }
                } else {
                    resultError = .unknown
                    NSLog("Http error getting response for BSToken")
                }
            }
            defer {
                completion(result, resultError)
            }
        }
        task.resume()
    }
    
    
    private static func extractTokenFromResponse(httpResponse: HTTPURLResponse?) -> BSToken? {
        
        var result: BSToken?
        if let location: String = httpResponse?.allHeaderFields["Location"] as? String {
            if let lastIndexOfSlash = location.range(of: "/", options: String.CompareOptions.backwards, range: nil, locale: nil) {
                let tokenStr = String(location[lastIndexOfSlash.upperBound..<location.endIndex])
                do {
                    try result = BSToken(tokenStr: tokenStr)
                } catch {
                    NSLog("Unexpected error: \(error).")
                }
            } else {
                NSLog("Error: BS Token does not contain /")
            }
        } else {
            NSLog("Error: BS Token does not appear in response headers")
        }
        return result
    }
    
    static func createTokenizedTransaction(
        purchaseAmount: Double,
        purchaseCurrency: String,
        bsToken: BSToken!,
        completion: @escaping (_ isSuccess: Bool, _ data: Data?, _ shopperId: String?)->Void) {
        
        var requestBody = [
            "amount": "\(purchaseAmount)",
            "recurringTransaction": "ECOMMERCE",
            "softDescriptor": "MobileSDKtest",
            "currency": "\(purchaseCurrency)",
            "cardTransactionType": "AUTH_CAPTURE",
            "pfToken": "\(bsToken.getTokenStr()!)",
            ] as [String : Any]
        print("requestBody= \(requestBody)")
        
        let authorization = getBasicAuth()
        
        let urlStr = bsToken.getServerUrl() + "services/2/transactions";
        let url = NSURL(string: urlStr)!
        
        var request = getURLRequest(urlStr: urlStr, httpMethod: "POST", contentType: "application/json", requestBody: requestBody)
        
        // fire request
        
        var result : (isSuccess:Bool, data: Data?, shopperId: String?) = (isSuccess:false, data: nil, shopperId: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error calling create transaction: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        result.data = data
                        NSLog("Response body = \(result.data!)")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.isSuccess = true
                        do {
                            if let json = try JSONSerialization.jsonObject(with: result.data!, options: .allowFragments) as? [String: AnyObject] {
                                result.shopperId = String(json["vaultedShopperId"] as! Int)
                            }
                        } catch let error as NSError {
                            NSLog("Error parsing BS result on Retrieve vaulted shopper: \(error.localizedDescription)")
                            result.isSuccess = false
                        }
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                completion(result.isSuccess, result.data, result.shopperId)
                
            }
        }
        task.resume()
    }
    
    static func printAsCurl(request: URLRequest) {
        guard let url = request.url else { return }
        var curlCommand = "curl"

        // Print HTTP method if not GET
        if let method = request.httpMethod, method != "GET" {
            curlCommand += " -v -X \(method)"
        }

        // Print headers
        if let headers = request.allHTTPHeaderFields {
            for (header, value) in headers {
                // Wrap the header value in quotes in case it contains spaces or special characters
                curlCommand += " -H \"\(header): \(value)\""
            }
        }

        // Print HTTP body if it exists
        if let httpBody = request.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            // Escape double quotes in the body
            let escapedBody = bodyString.replacingOccurrences(of: "\"", with: "\\\"")
            curlCommand += " --data \"\(escapedBody)\""
        }

        // Print the URL last
        curlCommand += " \"\(url.absoluteString)\""

        print("cURL equivalent: \(curlCommand)")
    }

     
    static func createTokenizedEcpAchTransaction(
        purchaseAmount: Double,
        purchaseCurrency: String,
        paymentMethod: String,
        routingNumber: String,
        accountNumber: String,
        accountType: String,
        bsToken: BSToken!,
        completion: @escaping (_ isSuccess: Bool, _ data: Data?, _ shopperId: String?)->Void) {

        var requestBody = [
            "pfToken": "\(bsToken.getTokenStr()!)",
            "amount": "\(purchaseAmount)",
            "currency": "\(purchaseCurrency)",
            "paymentMethod": "\(paymentMethod)",
            "payerInfo":[
               "firstName": "John",
                "lastName": "Doe",
                "zip": "02453",
                "phone": "1234567890",
           ],
            "softDescriptor": "ABC COMPANY",
            "authorizedByShopper" : true,
            
            ] as [String : Any]
        print("requestBody= \(requestBody)")
        
        let authorization = getBasicAuth()
        
        let urlStr = bsToken.getServerUrl() + "services/2/alt-transactions";
        let url = NSURL(string: urlStr)!
        
        var request = getURLRequest(urlStr: urlStr, httpMethod: "POST", contentType: "application/json", requestBody: requestBody)
        
        // Convert NSMutableURLRequest to URLRequest
        let urlRequest = request as URLRequest
                
        // Print cURL command
        printAsCurl(request: urlRequest)
        // fire request
        
        var result : (isSuccess:Bool, data: Data?, shopperId: String?) = (isSuccess:false, data: nil, shopperId: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error calling create transaction: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        result.data = data
                        NSLog("Response body = \(result.data!)")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.isSuccess = true
                        do {
                            if let json = try JSONSerialization.jsonObject(with: result.data!, options: .allowFragments) as? [String: AnyObject] {
                                result.shopperId = String(json["vaultedShopperId"] as! Int)
                            }
                        } catch let error as NSError {
                            NSLog("Error parsing BS result on Retrieve vaulted shopper: \(error.localizedDescription)")
                            result.isSuccess = false
                        }
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                completion(result.isSuccess, result.data, result.shopperId)
                
            }
        }
        task.resume()
    }

    static func retrieveVaultedShopper(
        vaultedShopperId shopperId: String,
        completion: @escaping (_ isSuccess: Bool, _ data: Data?)->Void) {
        
        print("shopperId= \(shopperId)")
        let authorization = getBasicAuth()
        
        let urlStr = BSApiManager.BS_SANDBOX_DOMAIN + "services/2/vaulted-shoppers/" + shopperId;
        let url = NSURL(string: urlStr)!
        
        var request = getURLRequest(urlStr: urlStr, httpMethod: "GET", contentType: "application/json")
            
      
        // fire request
        
        var result : (isSuccess:Bool, data: Data?) = (isSuccess:false, data: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error in calling retrieve vaulted shopper: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        result.data = data
                        let StringData = String(data: data, encoding: .utf8)
                        NSLog("Response body = \(StringData ?? "")")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.isSuccess = true
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                completion(result.isSuccess, result.data)
                
            }
        }
        task.resume()
    }
    
    /**
     Build the basic authentication header from username/password
     - parameters:
     - user: username
     - password: password
     */
    private static func getBasicAuth(user: String!, password: String!) -> String {
        let loginStr = String(format: "%@:%@", user, password)
        let loginData = loginStr.data(using: String.Encoding.utf8)!
        let base64LoginStr = loginData.base64EncodedString()
        return "Basic \(base64LoginStr)"
    }
    
    /**
     Build the basic authentication header from username/password
     */
    private static func getBasicAuth() -> String {
        return getBasicAuth(user: BS_SANDBOX_TEST_USER, password: BS_SANDBOX_TEST_PASSWORD)
    }
    
    /**
     Build a basic URL Request
     - parameters:
     - urlStr: url
     - httpMethod: operationt type to request
     - ContentType: content type of the request
     */
        private static func getURLRequest(urlStr: String, httpMethod: String, contentType: String, requestBody: Any? = nil) -> NSMutableURLRequest {
            let authorization = getBasicAuth()
            let url = NSURL(string: urlStr)!
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = httpMethod
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
            //request.setValue("0", forHTTPHeaderField: "Content-Length")
            request.setValue(BSApiCaller.BLUESNAP_API_VERSION_HEADER_VAL, forHTTPHeaderField: BSApiCaller.BLUESNAP_API_VERSION_HEADER)
            request.setValue(BSApiCaller.SDK_VERSION_CODE_HEADER_VAL, forHTTPHeaderField: BSApiCaller.SDK_VERSION_CODE_HEADER)
            request.setValue(BSApiCaller.SDK_VERSION_STRING_HEADER_VAL, forHTTPHeaderField: BSApiCaller.SDK_VERSION_STRING_HEADER)
            if let requestBody = requestBody {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
                } catch let error {
                    NSLog("Error serializing request body: \(error.localizedDescription)")
                }
            }
            return request

        }

    //------------------------------------------------------
    // MARK: functions API Calls
    //------------------------------------------------------

    static func createVaultedShopper(creditCard: [String: String], set2: Bool = false, storeCard:Bool = true) -> Int? {
        var bsToken: BSToken = BluesnapSDKIntegrationTestsHelper.initBSToken(tokenStr: "_")
        var vaultedShopperId: Int = 0

        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            bsToken = BluesnapSDKIntegrationTestsHelper.initBSToken(tokenStr: token!.getTokenStr())
            NSLog("token: \(bsToken.tokenStr)")
            submitCCDetails(ccDetails: creditCard, billingDetails: BluesnapSDKIntegrationTestsHelper.getBillingDetails(add2: set2),
                    shippingDetails: BluesnapSDKIntegrationTestsHelper.getShippingDetails(add2: set2), storeCard: storeCard, completion: { error in
                semaphore.signal()
            })
        })
        semaphore.wait()

        let semaphore2 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createTokenizedTransaction(purchaseAmount: 10, purchaseCurrency: "USD", bsToken: bsToken, completion: { isSuccess, data, shopperId in
            assert(isSuccess == true, "true")
            if let shopperId = shopperId {
                vaultedShopperId = Int(shopperId)!
            } else {
                NSLog("Error: no data exists")
            }
            semaphore2.signal()
        })
        semaphore2.wait()
        return vaultedShopperId
    }



    static func submitCCDetails(ccDetails: [String: String], billingDetails: BSBillingAddressDetails?, shippingDetails: BSShippingAddressDetails?, storeCard: Bool, completion: @escaping (BSErrors?) -> Void) {
        BSApiManager.submitPurchaseDetails(ccNumber: ccDetails["ccn"], expDate: ccDetails["exp"], cvv: ccDetails["cvv"],
                last4Digits: nil, cardType: nil, billingDetails: billingDetails ?? nil, shippingDetails: shippingDetails ?? nil, storeCard: storeCard ?? nil, fraudSessionId: nil, completion: {
            (result, error) in

            XCTAssert(error == nil, "error: \(error)")
            let ccType = result.ccType
            let last4 = result.last4Digits
            let country = result.ccIssuingCountry
            NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
            assert(last4 == ccDetails["last4Digits"], "last4 should be \(ccDetails["last4Digits"])")
            assert(ccType == ccDetails["ccType"], "CC Type should be \(ccDetails["ccType"])")
            assert(country == ccDetails["issuingCountry"], "country should be \(ccDetails["issuingCountry"])")
            completion(error)
        })

    }
}
