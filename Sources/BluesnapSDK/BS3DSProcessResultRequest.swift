
import Foundation

public class BS3DSProcessResultRequest: NSObject, BSModel {
    
    var jwt: String?
    var resultJwt: String?
    
    public init(jwt: String?, resultJwt: String?) {
        self.jwt = jwt
        self.resultJwt = resultJwt
        super.init()
    }
    
    public func toJson() -> ([String: Any])! {
        var request: [String: Any] = [:]
        
        if let jwt  = self.jwt {
            request["jwt"] = jwt
        }
        if let resultJwt  = self.resultJwt {
            request["resultJwt"] = resultJwt
        }
        
        return request
        
    }
    
}
