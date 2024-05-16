import Foundation

public class BS3DSAuthRequest: NSObject, BSModel {

    var currencyCode: String?
    var amount: String?
    var jwt: String?

    public init(currencyCode: String?, amount: String?, jwt: String?) {
        self.currencyCode = currencyCode
        self.amount = amount
        self.jwt = jwt
        super.init()
    }

    public func toJson() -> ([String: Any])! {
        var request: [String: Any] = [:]

        if let currencyCode  = self.currencyCode {
            request["currency"] = currencyCode
        }
        if let amount  = self.amount {
            request["amount"] = amount
        }
        if let jwt  = self.jwt {
            request["jwt"] = jwt
        }

        return request

    }

}
