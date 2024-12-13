//
//  BSToken.swift


import Foundation

/**
 This class holds the basic data for a BlueShap token: the server URL and the token we got from it.
 The token is the String you get from BlueSnap API when generating a new token (/services/2/payment-fields-tokens).
 The serverURL should look liker this: https://api.bluesnap.com/ meaning: it should include the https, the domain, and end with a /
 */
  public class BSToken: NSObject {
    internal var tokenStr: String! = ""
    internal var serverUrl: String! = ""
    internal var isProduction: Bool! = false

    public init(tokenStr : String!) throws {
        self.tokenStr = tokenStr
        let lastChar = "\(tokenStr.last!)"
        
        if (lastChar == "_") {
            self.serverUrl = BSApiManager.BS_SANDBOX_DOMAIN
        } else if (lastChar == "1" || lastChar == "2") {
            self.serverUrl = BSApiManager.BS_PRODUCTION_DOMAIN_PART1 + lastChar + BSApiManager.BS_PRODUCTION_DOMAIN_PART2
            self.isProduction = true
        } else {
            throw BSServiceError.illegalToken("Illegal token " + tokenStr)
        }
    }

    public init(tokenStr : String!, serverUrl : String!) throws {
        self.tokenStr = tokenStr
        let lastChar = "\(tokenStr.last!)"
        
        if (lastChar == "_") {
            self.serverUrl = serverUrl
        } else if (lastChar == "1" || lastChar == "2") {
            self.serverUrl = BSApiManager.BS_PRODUCTION_DOMAIN_PART1 + lastChar + BSApiManager.BS_PRODUCTION_DOMAIN_PART2
        } else {
            throw BSServiceError.illegalToken("Illegal token " + tokenStr)
        }
    }
    
    public func getTokenStr() -> String! {
        return self.tokenStr
    }
    
    public func getServerUrl() -> String! {
        return self.serverUrl
    }
}
